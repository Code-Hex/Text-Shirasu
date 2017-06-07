package Text::Shirasu::Tree;

=encoding utf-8

=head1 NAME

Text::Shirasu::Tree - Shirasu Node Object for CaboCha

=head1 SYNOPSIS

    use utf8;
    use feature ':5.10';
    use Text::Shirasu;
    my $ts = Text::Shirasu->new;
    $ts->load_cabocha;
    
    $ts->parse_cabocha("昨日の晩御飯は「鮭のふりかけ」と「味噌汁」だけでした。");

    for my $node (@{ $ts->trees }) {
        say $node->cid;
        say $node->link;
        say $node->head_pos;
        say $node->func_pos;
        say $node->score;
        say $node->surface;
        say for @{ $node->feature };
        say $node->ne;
    }

=head1 DESCRIPTION

Text::Shirasu::CaboChaNode like L<Text::CaboCha::Token>.

=cut

sub cid      { $_[0]->{cid}      }
sub link     { $_[0]->{link}     }
sub head_pos { $_[0]->{head_pos} }
sub func_pos { $_[0]->{func_pos} }
sub score    { $_[0]->{score}    }
sub surface  { $_[0]->{surface}  }
sub feature  { $_[0]->{feature}  }
sub ne       { $_[0]->{ne}       }

=head1 SEE ALSO

L<Text::Shirasu>

=head1 AUTHOR

Kei Kamikawa E<lt>x00.x7f@gmail.comE<gt>

=cut
1;
