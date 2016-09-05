package Text::MeCab::Soup;

use strict;
use warnings;
use utf8;

use Carp;
use Encode;
use Text::MeCab;
use Contextual::Return;

our $VERSION = "0.01";

use constant FEATURE_TABLE => {
    'type'    => 0,
    'subtype' => 1
};

sub mecab  { $_[0]->{mecab}  }
sub result { $_[0]->{result} }

sub new {
    my $class = shift;
    my %args = ref $_[0] eq 'HASH' ? %{$_[0]} : @_;
    return bless {
        mecab  => Text::MeCab->new(%args),
        result => []
    }, $class;
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

sub search {
    my $self = shift;
    my %params = ref $_[0] eq 'HASH' ? %{$_[0]} : @_;

    # AND search
    my $type = delete $params{type} or Carp::croak "Does not input search query: \"type\"";

    # Making parameter as /名詞|動詞/ or /名詞/
    my $judge = @$type > 1 ?
                join '|', map { encode_utf8($_) } @$type
                : encode_utf8(shift @$type);

    $self->{result} = [ 
        grep {
            $_->{feature}->[ FEATURE_TABLE->{type} ] =~ /($judge)/
            and _sub_query($_->{feature}->[1], $params{decode_utf8($1)})
        } @{$self->{result}}
    ];

    return 
        OBJREF  { $self }
        DEFAULT { $self->{result} };
}

sub _sub_query {
    my ($subtype, $query) = @_;

    return 1 unless ref $query eq 'ARRAY';

    my $judge = @{$query} > 1 ?
                join '|', map { encode_utf8($_) } @{$query}
                : encode_utf8(shift @{$query});
    
    return $subtype =~ /$judge/;
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


1;
__END__

=encoding utf-8

=head1 NAME

Text::MeCab::Soup - It's new $module

=head1 SYNOPSIS

    use Data::Dumper;
    use Text::MeCab::Soup;
    my $mt = Text::MeCab::Soup->new;
    $mt->parse("昨日の晩御飯は鮭のふりかけと味噌汁だけでした。");

    my $filtered = $mt->filter(type => [qw/名詞 助動詞/]);
    print Dumper $filtered;

=head1 DESCRIPTION

Text::MeCab::Soup is ...

=head1 LICENSE

Copyright (C) K.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

K E<lt>x00.x7f@gmail.comE<gt>

=cut

