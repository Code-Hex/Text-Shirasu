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
          map { encode_utf8($_) } %{$_[0]}
        : map { encode_utf8($_) } @_;

    my @keys = keys %params;

    for (@{ $self->{result} }) {
        # Is it faster eval...!?
        for my $key (@keys) {
            $_->{surface} =~ s/$key/$params{$key}/g;
        }
    }

    return $self;
}

sub search {
    my $self = shift;
    my %params = ref $_[0] eq 'HASH' ? %{$_[0]} : @_;

    # and search
    my $type = delete $params{type} or Carp::croak 'Does not input search query: "type"';

    # making parameter as /名詞|動詞/ or /名詞/
    my $judge = @$type > 1 ?
                join '|', map { encode_utf8($_) } @$type
                : encode_utf8(shift @$type);

    $self->{result} = [ 
        grep {
            $_->{feature}->[ Type ] =~ /($judge)/
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

    print "\n";
    printf "%s:\t%s\n", $_->{surface}, join ',', @{$_->{feature}} for @{$self->{result}};
    print "\n";
}

sub dumper {
    my $self = shift;
    local $Data::Dumper::Sortkeys = 1;
    local $Data::Dumper::Indent = 1;
    my $dumper = Data::Dumper::Dumper($self->{result});

    print $dumper;
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
    use Text::Shirasu;
    my $ts = Text::Shirasu->new; # this parameter is same as Text::MeCab
    my $parse = $ts->parse("昨日の晩御飯は「鮭のふりかけ」と「味噌汁」だけでした。");

    use Data::Dumper;
    my $search = $parse->search(type => [qw/名詞 助動詞/], 記号 => [qw/括弧開 括弧閉/]);
    print Dumper $search->result;

    my $tr = $parse->parse('。' => '.');
    print Dumper $tr->result;

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