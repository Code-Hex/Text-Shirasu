package Text::Shirasu;

use strict;
use warnings;
use utf8;

use Carp 'croak';
use Encode;
use Text::MeCab;

our $VERSION = "0.0.1";

use constant DEBUG => 1;

=encoding utf-8

=head1 NAME

Text::Shirasu - Text::MeCab wrapper

=head1 SYNOPSIS

    use utf8;
    use feature ':5.10';
    use Text::Shirasu;
    my $ts = Text::Shirasu->new; # this parameter same as Text::MeCab
    my $parse = $ts->parse("昨日の晩御飯は「鮭のふりかけ」と「味噌汁」だけでした。");

    my $tr = $parse->tr('。' => '.');
    say $tr->join_surface;
    
    my $filter = $parse->filter(type => [qw/名詞 助動詞/], 記号 => [qw/括弧開 括弧閉/]);
    say $filter->join_surface;

=head1 DESCRIPTION

Text::Shirasu is wrapped L<Text::MeCab>.  
This module has functions filter, replacement, etc...

=cut

sub new {
    my $class = shift;
    my %args = ref $_[0] eq 'HASH' ? %{$_[0]} : @_;
    return bless {
        mecab  => Text::MeCab->new(%args),
        result => +[]
    } => $class;
}

=head2 parse

    $ts->parse("このおにぎりは「母」が握ってくれたものです。");

Text::MeCab の parse メソッドをラッピングしています。
parse メソッドは実行結果をオブジェクト内に保存し、オブジェクトを返します。
用意されている他のメソッドを使用すると結果を上書きして再びオブジェクト内に保存されることに注意してください。
=cut

sub parse {
    my $self = shift;
    my $sentence = utf8::is_utf8($_[0]) ? encode_utf8($_[0]) : $_[0];

    my $mt = $self->{mecab};

    # initialize
    $self->{result} = [];

    for (my $node = $mt->parse($sentence); $node && $node->surface; $node = $node->next) {
        push @{$self->{result}}, {
            id      => $node->id,
            surface => $node->surface,
            feature => [split /,/, $node->feature],
            length  => $node->length,
            rlength => $node->rlength,
            lcattr  => $node->lcattr,
            stat    => $node->stat,
            isbest  => $node->isbest,
            alpha   => $node->alpha,
            beta    => $node->beta,
            prob    => $node->prob,
            wcost   => $node->wcost,
            cost    => $node->cost,
        };
    }

    return $self;
}

=head2 tr

    $ts->tr('，！？' => ',!?');

Perl の tr と同じように parse メソッド実行後にオブジェクト内に保存されている surface の文字列を置換します。
=cut

sub tr {
    my $self = shift;
    my %params = ref $_[0] eq 'HASH' ? 
        map { utf8::is_utf8($_) ? encode_utf8($_) : $_ } %{$_[0]} :
        map { utf8::is_utf8($_) ? encode_utf8($_) : $_ } @_;

    my @keys = keys %params;

    if (@keys == 1) {
        my $key = shift @keys;
        @keys = map { encode_utf8($_) } split //, decode_utf8($key);
        my @vals = map { encode_utf8($_) } split //, decode_utf8($params{$key});
        
        %params = map { $keys[$_] => $vals[$_] } 0 .. $#keys;
    }

    my $query = join '|', @keys;

    # replacement
    $_->{surface} =~ s/($query)/$params{$1}/g for @{ $self->{result} };

    return $self;
}

=head2 filter
    
    $ts->filter(type => [qw/名詞/]);
    $ts->filter(type => [qw/名詞 記号/], 記号 => [qw/括弧開 括弧閉/]);

parse メソッド実行後にオブジェクト内に保存されている surface を feature の情報を利用して条件をもとに絞り込みます。
type をキーに欲しい品詞の情報を渡します。さらにその品詞の中から細かく絞り込みたい時は、その品詞名をキーにして、細かい情報を渡します。

=cut

sub filter {
    my $self = shift;
    my %params = ref $_[0] eq 'HASH' ? %{$_[0]} : @_;

    # and filter
    my @type = map { utf8::is_utf8($_) ? encode_utf8($_) : $_ } @{ delete $params{type} } 
                    or croak 'Does not input query: "type"';

    # making parameter as /名詞|動詞/ or /名詞/
    my $query = join '|', @type;

    $self->{result} = [ 
        grep {
            $_->{feature}->[0] =~ /($query)/
            and _sub_query($_->{feature}->[1], $params{decode_utf8($1)})
        } @{$self->{result}}
    ];

    return $self;
}

=head2 join_surface
    
    $ts->join_surface()

オブジェクト内に保存されている surface を全て結合した文字列を返します。

=cut

sub join_surface {
    my $self = shift;
    croak "Does not exist parsed results" unless exists $self->{result};
    return join '', map { $_->{surface} } @{$self->{result}};
}

=head2 result
    
    $ts->result

parse メソッドで入手した情報を格納したデータを返します。
tr や filter メソッドを利用すると result 内の surface の情報が変化します。  

=cut
sub result { $_[0]->{result} }

=head2 mecab
    
    $ts->mecab

Text::MeCab のオブジェクトを利用することができます。  

=cut
sub mecab  { $_[0]->{mecab}  }

=head2 result_dump
    
    $ts->result_dump()

オブジェクト内に保存されている result 内のデータ構造を Data::Dumper を用いて表示します。

=cut

sub result_dump {
    my $self = shift;
    local $Data::Dumper::Sortkeys = 1;
    $self->_print(Data::Dumper::Dumper($self->{result}) => DEBUG);
}

sub _print {
    my $self = shift;
    my ($msg, $level) = @_;
    my $fh = $level && $level >= DEBUG ? *STDERR : *STDOUT;
    print {$fh} $msg;
}

# sub routine
sub _sub_query {
    my ($subtype, $query) = @_;

    return 1 unless ref $query eq 'ARRAY';

    my $judge = join '|', map { encode_utf8($_) } @$query;
    
    return $subtype =~ /$judge/;
}


1;

=head1 LICENSE

Copyright (C) Kei Kamikawa(Code-Hex).

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Kei Kamikawa E<lt>x00.x7f@gmail.comE<gt>

=cut