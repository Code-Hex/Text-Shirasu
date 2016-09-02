package Text::MeCab::Easy;

use strict;
use warnings;
use v5.10;

use Encode;
use Text::MeCab;

our $VERSION = "0.01";

sub mecab    { $_[0]->{mecab}    }
sub surfaces { $_[0]->{surfaces} }
sub features { $_[0]->{features} }

sub new {
    my $class = shift;
    my %args = ref $_[0] eq 'HASH' ? %{$_[0]} : @_;
    return bless {
        mecab => Text::MeCab->new(%args),
        surfaces => [],
        features => []
    }, $class;
}

sub parse {
    my ($self, $sentence) = @_;

    my $mt = $self->{mecab};

    # initialize
    $self->{surfaces} = [];
    $self->{features} = [];

    for (my $node = $mt->parse($sentence); $node && $node->surface; $node = $node->next) {
        push @{$self->{surfaces}}, $node->surface;
        push @{$self->{features}}, [split /,/, $node->feature];
    }

    return $self;
}

sub filter {
    my $self = shift;

    # filter by part of speech
    my $judge = @_ > 1 ? join '|', map { encode_utf8($_) } @_ : encode_utf8(shift);

    my $cnt = @{$self->{surfaces}};
    my $surfaces = [];
    my $features = [];

    for my $i (0 .. $cnt) {
        if ($self->{features}->[$i]->[0] =~ /$judge/) {
            push @$surfaces, $self->{surfaces}->[$i];
            push @$features, $self->{features}->[$i];
        }
    }

    return ($surfaces, $features);
}

sub dumper {
    my $self = shift;

    my $cnt = @{$self->{surfaces}};

    print "\n";
    for my $i (0 .. $cnt) {
        printf "%s:\t%s\n", $self->{surfaces}->[$i], join ',', @{$self->{features}};
    }
    print "\n";
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

