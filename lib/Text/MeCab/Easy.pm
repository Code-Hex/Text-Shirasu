package Text::MeCab::Easy;

use strict;
use warnings;
use utf8;
use v5.10;

use Encode;
use Text::MeCab;

our $VERSION = "0.01";

sub mecab  { $_[0]->{mecab}  }
sub parsed { $_[0]->{parsed} }

sub new {
    my $class = shift;
    my %args = ref $_[0] eq 'HASH' ? %{$_[0]} : @_;
    return bless {
        mecab  => Text::MeCab->new(%args),
        parsed => []
    }, $class;
}

sub parse {
    my ($self, $sentence) = @_;

    my $mt = $self->{mecab};

    # initialize
    $self->{parsed} = [];

    for (my $node = $mt->parse($sentence); $node && $node->surface; $node = $node->next) {
        push @{$self->{parsed}}, {
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

sub filter {
    my $self = shift;
    my %params = ref $_[0] eq 'HASH' ? %{$_[0]} : @_;

    # filter by part of speech
    my $judge = @{$params{part_of_speech}} > 1 ? join '|', map { encode_utf8($_) } @{$params{part_of_speech}}
                    : encode_utf8(shift @{$params{part_of_speech}});

    return [grep { $_->{feature}->[0] =~ /$judge/ } @{$self->{parsed}}];
}

sub print {
    my $self = shift;

    print "\n";
    for my $data (@{$self->{parsed}}) {
        printf "%s:\t%s\n", $data->{surface}, join ',', @{$data->{feature}};
    }
    print "\n";
}

sub dumper {
    my $self = shift;
    local $Data::Dumper::Sortkeys = 1;
    local $Data::Dumper::Indent = 1;
    my $dumper = Data::Dumper::Dumper($self->{parsed});

    print $dumper;
}


1;
__END__

=encoding utf-8

=head1 NAME

Text::MeCab::Easy - It's new $module

=head1 SYNOPSIS

    use Text::MeCab::Easy;

=head1 DESCRIPTION

Text::MeCab::Easy is ...

=head1 LICENSE

Copyright (C) K.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

K E<lt>x00.x7f@gmail.comE<gt>

=cut

