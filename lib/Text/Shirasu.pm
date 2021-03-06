package Text::Shirasu;

use strict;
use warnings;
use utf8;

use Exporter 'import';
use Text::MeCab;
use Carp 'croak';
use Text::Shirasu::Node;
use Text::Shirasu::Tree;
use Lingua::JA::NormalizeText;
use Encode qw/encode_utf8 decode_utf8/;

our $VERSION   = "0.0.4";
our @EXPORT_OK = (@Lingua::JA::NormalizeText::EXPORT_OK, qw/normalize_hyphen normalize_symbols/);

*nfkc                 = \&Lingua::JA::NormalizeText::nfkc;
*nfkd                 = \&Lingua::JA::NormalizeText::nfkd;
*nfc                  = \&Lingua::JA::NormalizeText::nfc;
*nfd                  = \&Lingua::JA::NormalizeText::nfd;
*decode_entities      = \&Lingua::JA::NormalizeText::decode_entities;
*alnum_z2h            = \&Lingua::JA::NormalizeText::alnum_z2h;
*alnum_h2z            = \&Lingua::JA::NormalizeText::alnum_h2z;
*space_z2h            = \&Lingua::JA::NormalizeText::space_z2h;
*space_h2z            = \&Lingua::JA::NormalizeText::space_h2z;
*katakana_z2h         = \&Lingua::JA::NormalizeText::katakana_z2h;
*katakana_h2z         = \&Lingua::JA::NormalizeText::katakana_h2z;
*katakana2hiragana    = \&Lingua::JA::NormalizeText::katakana2hiragana;
*hiragana2katakana    = \&Lingua::JA::NormalizeText::hiragana2katakana;
*dakuon_normalize     = \&Lingua::JA::NormalizeText::dakuon_normalize;
*handakuon_normalize  = \&Lingua::JA::NormalizeText::handakuon_normalize;
*all_dakuon_normalize = \&Lingua::JA::NormalizeText::all_dakuon_normalize;
*square2katakana      = \&Lingua::JA::NormalizeText::square2katakana;
*circled2kana         = \&Lingua::JA::NormalizeText::circled2kana;
*circled2kanji        = \&Lingua::JA::NormalizeText::circled2kanji;
*strip_html           = \&Lingua::JA::NormalizeText::strip_html;
*wave2tilde           = \&Lingua::JA::NormalizeText::wave2long;
*tilde2wave           = \&Lingua::JA::NormalizeText::tilde2wave;
*wavetilde2long       = \&Lingua::JA::NormalizeText::wavetilde2long;
*wave2long            = \&Lingua::JA::NormalizeText::wave2long;
*tilde2long           = \&Lingua::JA::NormalizeText::tilde2long;
*fullminus2long       = \&Lingua::JA::NormalizeText::fullminus2long;
*dashes2long          = \&Lingua::JA::NormalizeText::dashes2long;
*drawing_lines2long   = \&Lingua::JA::NormalizeText::drawing_lines2long;
*unify_long_repeats   = \&Lingua::JA::NormalizeText::unify_long_repeats;
*unify_long_spaces    = \&Lingua::JA::NormalizeText::unify_long_spaces;
*unify_whitespaces    = \&Lingua::JA::NormalizeText::unify_whitespaces;
*trim                 = \&Lingua::JA::NormalizeText::trim;
*ltrim                = \&Lingua::JA::NormalizeText::ltrim;
*rtrim                = \&Lingua::JA::NormalizeText::rtrim;
*nl2space             = \&Lingua::JA::NormalizeText::nl2space;
*unify_nl             = \&Lingua::JA::NormalizeText::unify_nl;
*tab2space            = \&Lingua::JA::NormalizeText::tab2space;
*old2new_kana         = \&Lingua::JA::NormalizeText::old2new_kana;
*remove_controls      = \&Lingua::JA::NormalizeText::remove_controls;
*remove_spaces        = \&Lingua::JA::NormalizeText::remove_spaces;
*remove_DFC           = \&Lingua::JA::NormalizeText::remove_DFC;
*old2new_kanji        = \&Lingua::JA::NormalizeText::old2new_kanji;
*decompose_parenthesized_kanji
    = \&Lingua::JA::NormalizeText::decompose_parenthesized_kanji;

=encoding utf-8

=head1 NAME

Text::Shirasu - Text::MeCab wrapped for natural language processing 

=head1 SYNOPSIS

    use utf8;
    use feature ':5.10';
    use Text::Shirasu;
    my $ts = Text::Shirasu->new(cabocha => 1); # you can use Text::CaboCha
    my $normalize = $ts->normalize("昨日の晩御飯は「鮭のふりかけ」と「味噌汁」だけでした。");
    $ts->parse($normalize);

    for my $node (@{ $ts->nodes }) {
        say $node->surface;
    }

    say $ts->join_surface;

    my $filter = $ts->filter(type => [qw/名詞 助動詞/], 記号 => [qw/括弧開 括弧閉/]);
    say $filter->join_surface;

    for my $tree (@{ $ts->trees }) {
        say $tree->surface;
    }

=head1 DESCRIPTION

Text::Shirasu is wrapped L<Text::MeCab>.  
This module is easy to normalize text and filter part of speech.  
Also to use L<Text::CaboCha> by setting the cabocha option to true.

=cut

=head1 METHODS
=cut
=head2 new

    Text::Shirasu->new(
        # If you want to use cabocha
        cabocha => 1,
        # Text::MeCab arguments
        rcfile             => $rcfile,             # Also it will be ailias as mecabrc for Text::CaboCha
        dicdir             => $dicdir,             # Also it will be ailias as mecab_dicdir for Text::CaboCha
        userdic            => $userdic,            # Also it will be ailias as mecab_userdic for Text::CaboCha
        lattice_level      => $lattice_level,
        all_morphs         => $all_morphs,
        output_format_type => $output_format_type,
        partial            => $partial,
        node_format        => $node_format,
        unk_format         => $unk_format,
        bos_format         => $bos_format,
        eos_format         => $eos_format,
        input_buffer_size  => $input_buffer_size,
        allocate_sentence  => $allocate_sentence,
        nbest              => $nbest,
        theta              => $theta,
        
        # Text::CaboCha arguments
        ne            => $ne,
        parser_model  => $parser_model_file,
        chunker_model => $chunker_model_file,
        ne_model      => $ne_tagger_model_file,
    );

=cut

sub new {
    my $class = shift;
    my %args = ref $_[0] eq 'HASH' ? %{ $_[0] } : @_;
    my %cabocha_opts;
    my $use_cabocha = delete $args{cabocha};
    if ($use_cabocha) {
        local $@;
        eval { require Text::CaboCha };
        if ($@ || $Text::CaboCha::VERSION < "0.04") {
            croak("If you want to use some functions of Text::CaboCha, you need to install Text::CaboCha >= 0.04");
        }
        # Arguments for Text::Cabocha
        for my $opt (qw/ne parser_model chunker_model ne_model/) {
            if (exists $args{$opt}) {
                $cabocha_opts{$opt} = delete $args{$opt};
            }
        }
        # Get from arguments of Text::MeCab
        for my $opt (qw/rcfile dicdir userdic/) {
            if (exists $args{$opt}) {
                if ($opt eq 'rcfile') {
                    $cabocha_opts{mecabrc} = $args{$opt};
                } else {
                    $cabocha_opts{"mecab_${opt}"} = $args{$opt};
                }
            }
        }
    }

    my $self = bless {
        mecab     => Text::MeCab->new(%args),
        nodes     => +[],
        normalize => +[qw/
                nfkc
                nfkd
                nfc
                nfd
                alnum_z2h
                space_z2h
                katakana_h2z
                decode_entities
                unify_nl
                unify_whitespaces
                unify_long_spaces
                trim
                old2new_kana
                old2new_kanji
                tab2space
                all_dakuon_normalize
                square2katakana
                circled2kana
                circled2kanji
                decompose_parenthesized_kanji
            /, \&normalize_hyphen, \&normalize_symbols
        ],
    } => $class;
    
    if ($use_cabocha) {
        $self->{trees}   = +[];
        $self->{cabocha} = Text::CaboCha->new(%cabocha_opts);
    }

    return $self;
}

=head2 parse

This method wraps the parse method of Text::MeCab.
The analysis result is saved as array reference of Text::Shirasu::Node instance in the Text::Shirasu instance.
Also, If you used cabocha mode, it save as array reference of Text::Shirasu::Tree instance in the Text::Shirasu instance when used this method.
It return Text::Shirasu instance. 

    $ts->parse("このおにぎりは「母」が握ってくれたものです。");

=cut

sub parse {
    my $self     = shift;
    my $sentence = $_[0];

    croak "Sentence has not been inputted" unless $sentence;

    my $mt = $self->{mecab};

    # initialize
    $self->{nodes} = [];
    my $node = $mt->parse($sentence);

    # when cabocha mode
    if (exists $self->{cabocha}) {
        my $ct   = $self->{cabocha};
        my $tree = $ct->parse_from_node($node);
        my $cid = 0;
        for my $token (@{ $tree->tokens }) {
            if ($token->chunk) {
                push @{ $self->{trees} }, bless {
                    cid      => $cid++,
                    link     => $token->chunk->link,
                    head_pos => $token->chunk->head_pos,
                    func_pos => $token->chunk->func_pos,
                    score    => $token->chunk->score,
                    surface  => $token->surface,
                    feature  => [ split /,/, $token->feature ],
                    ne       => $token->ne,
                }, 'Text::Shirasu::Tree';
            }
        }
    }

    for (; $node && $node->surface; $node = $node->next) {
        push @{ $self->{nodes} }, bless {
            id      => $node->id,
            surface => $node->surface,
            feature => [ split /,/, $node->feature ],
            length  => $node->length,
            rlength => $node->rlength,
            rcattr  => $node->rcattr,
            lcattr  => $node->lcattr,
            stat    => $node->stat,
            isbest  => $node->isbest,
            alpha   => $node->alpha,
            beta    => $node->beta,
            prob    => $node->prob,
            wcost   => $node->wcost,
            cost    => $node->cost,
        }, 'Text::Shirasu::Node';
    }

    return $self;
}

=head2 normalize

It will normalize text using L<Lingua::JA::NormalizeText>.  

    $ts->normalize("あ━ ”（＊）” を〰〰 ’＋１’")
    $ts->normalize("テキスト〰〰", qw/nfkc, alnum_z2h/, \&your_create_routine)

It accepts a string as the first argument, and receives the Lingua::JA::NormalizeText options and subroutines after the second argument.
If you do not specify a subroutine to be used in normalization, use the following Lingua::JA::NormalizeText options and subroutines by default.  

Please read the documentation of L<Lingua::JA::NormalizeText> for details on how each Lingua::JA::NormalizeText option works.

Lingua::JA::NormalizeText options

C<nfkc nfkd nfc nfd alnum_z2h space_z2h katakana_h2z decode_entities unify_nl unify_whitespaces unify_long_spaces trim old2new_kana old2new_kanji tab2space all_dakuon_normalize square2katakana circled2kana circled2kanji decompose_parenthesized_kanji>

Subroutines

C<normalize_hyphen normalize_symbols>

=cut

sub normalize {
    my $self = shift;
    my $text = shift;
    my $normalizer = Lingua::JA::NormalizeText->new(@_ ? @_ : @{ $self->{normalize} });
    $normalizer->normalize(utf8::is_utf8($text) ? $text : decode_utf8($text));
}

=head2 filter

Please use after parse method execution.   
Filter the surface based on the features stored in the Text::Shirasu instance.
Passing subtype to value with part of speech name as key allows you to more filter the string.

    # filtering nodes only
    $ts->filter(type => [qw/名詞/]);
    $ts->filter(type => [qw/名詞 記号/], 記号 => [qw/括弧開 括弧閉/]);

    # filtering trees only
    $ts->filter(tree => 1, node => 0, type => [qw/名詞/]);
    $ts->filter(tree => 1, node => 0, type => [qw/名詞 記号/], 記号 => [qw/括弧開 括弧閉/]);

    # filtering nodes and trees
    $ts->filter(tree => 1, type => [qw/名詞/]);
    $ts->filter(tree => 1, type => [qw/名詞 記号/], 記号 => [qw/括弧開 括弧閉/]);

=cut

sub filter {
    my $self = shift;
    my %params = ref $_[0] eq 'HASH' ? %{ $_[0] } : @_;

    # and search filter
    my @type = @{ delete $params{type} }
        or croak 'Query has not been inputted: "type"';

    # create parameter as /名詞|動詞/ or /名詞/
    my $query = encode_utf8 join '|', map { $_ } @type;

    # filtering trees
    if (delete $params{tree}) {
        $self->{trees} = [
            grep {
                $_->{feature}->[0] =~ /($query)/
                    and _sub_query( $_->{feature}->[1],  $params{decode_utf8($1)} )
            } @{ $self->{trees} }
        ];
    }

    # filtering nodes if unset "node" argument or "node => true value"
    if (!exists $params{node} || delete $params{node}) {
        $self->{nodes} = [
            grep {
                $_->{feature}->[0] =~ /($query)/
                    and _sub_query( $_->{feature}->[1],  $params{decode_utf8($1)} )
            } @{ $self->{nodes} }
        ];
    }

    return $self;
}


=head2 join_surface

Returns a string that combined the surfaces stored in the instance.
    
    $ts->join_surface

=cut

sub join_surface {
    my $self = shift;
    croak "Does not exist parsed nodes" unless exists $self->{nodes};
    return join '', map { $_->{surface} } @{ $self->{nodes} };
}

=head2 nodes

Return the array reference of the Text::Shirasu::Node instance.
    
    $ts->nodes

=cut

sub nodes { $_[0]->{nodes} }

=head2 trees

Return the array reference of the Text::Shirasu::Tree instance.

    $ts->trees

=cut

sub trees { $_[0]->{trees} }

=head2 mecab

Return the Text::MeCab instance.
    
    $ts->mecab

=cut

sub mecab { $_[0]->{mecab} }

=head2 cabocha

Return the Text::CaboCha instance.
    
    $ts->cabocha

=cut

sub cabocha { $_[0]->{cabocha} }

# private
sub _sub_query {
    my ( $subtype, $query ) = @_;

    return 1 unless ref $query eq 'ARRAY';

    my $judge = join '|', map { encode_utf8($_) } @$query;

    return $subtype =~ /$judge/;
}

1;

=head1 SUBROUTINES

These subroutines perform the following substitution.  

=head2 normalize_hyphen

    s/[˗֊‐‑‒–⁃⁻₋−]/-/g;
    s/[﹣－ｰ—―─━ー]/ー/g;
    s/[~∼∾〜〰～]//g;
    s/ー+/ー/g;

=head2 normalize_symbols

    tr/。、・「」/｡､･｢｣/;

=cut

sub normalize_hyphen {
    local $_ = shift;
    return undef unless defined $_;
    s/[˗֊‐‑‒–⁃⁻₋−]/-/g;
    s/[﹣－ｰ—―─━ー]/ー/g;
    s/[~∼∾〜〰～]//g;
    s/ー+/ー/g;
    $_;
}

sub normalize_symbols {
    local $_ = shift;
    return undef unless defined $_;
    tr/。、・「」/｡､･｢｣/;
    $_;
}

=head1 LICENSE

Copyright (C) Kei Kamikawa(Code-Hex).

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Kei Kamikawa E<lt>x00.x7f@gmail.comE<gt>

=cut
