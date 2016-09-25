package Text::Shirasu;

use strict;
use warnings;
use utf8;

use Carp ();
use Encode;
use Text::MeCab;

our $VERSION = "0.0.1";

use constant Type => 0;

sub mecab  { $_[0]->{mecab}  }
sub result { $_[0]->{result} }

sub new {
    my $class = shift;
    my %args = ref $_[0] eq 'HASH' ? %{$_[0]} : @_;
    return bless {
        mecab  => Text::MeCab->new(%args),
        result => +[]
    } => $class;
}

sub parse {
    my ($self, $sentence) = @_;

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

    # replace
    for (@{ $self->{result} }) {
        # Is it faster eval...!?
        $_->{surface} =~ s/($query)/$params{$1}/g;
    }

    return $self;
}

sub search {
    my $self = shift;
    my %params = ref $_[0] eq 'HASH' ? %{$_[0]} : @_;

    # and search
    my @type = map { utf8::is_utf8($_) ? encode_utf8($_) : $_ } @{ delete $params{type} } 
                    or Carp::croak 'Does not input search query: "type"';

    # making parameter as /名詞|動詞/ or /名詞/
    my $query = join '|', @type;

    $self->{result} = [ 
        grep {
            $_->{feature}->[ Type ] =~ /($query)/
            and _sub_query($_->{feature}->[1], $params{decode_utf8($1)})
        } @{$self->{result}}
    ];

    return $self;
}

sub join_surface {
    my $self = shift;
    Carp::croak "Does not exist parsed results" unless exists $self->{result};
    return join '', map { $_->{surface} } @{$self->{result}};
}

sub print {
    my $self = shift;
    my ($msg, $level) = @_;
    my $fh = $level && $level >= 1 ? *STDERR : *STDOUT;
    print {$fh} $msg;
}

sub result_dump {
    my $self = shift;
    local $Data::Dumper::Sortkeys = 1;
    my $dumper = Data::Dumper::Dumper($self->{result});
    $self->print($dumper, 1);
}

# sub routine
sub _sub_query {
    my ($subtype, $query) = @_;

    return 1 unless ref $query eq 'ARRAY';

    my $judge = @{$query} > 1 ?
                join '|', map { encode_utf8($_) } @{$query}
                : encode_utf8(shift @{$query});
    
    return $subtype =~ /$judge/;
}


1;
__END__

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
    
    my $search = $parse->search(type => [qw/名詞 助動詞/], 記号 => [qw/括弧開 括弧閉/]);
    say $search->join_surface;

=head1 DESCRIPTION

Text::Shirasu wrapped L<Text::MeCab>.  
This module has functions filter, replacement, etc...

=head1 LICENSE

Copyright (C) Kei Kamikawa(Code-Hex).

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Kei Kamikawa E<lt>x00.x7f@gmail.comE<gt>

=cut