package Text::Shirasu;

use strict;
use warnings;
use utf8;
use Exporter 'import';
use Text::MeCab;
use Carp 'croak';
use Data::Dumper;
use Text::Shirasu::Node;
use Lingua::JA::NormalizeText;
use Encode qw/encode_utf8 decode_utf8/;

our $VERSION   = "0.0.1";
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

Text::Shirasu - Text::MeCab wrapper

=head1 SYNOPSIS

    use utf8;
    use feature ':5.10';
    use Text::Shirasu;
    my $ts = Text::Shirasu->new; # this parameter same as Text::MeCab
    my $parse = $ts->parse("昨日の晩御飯は「鮭のふりかけ」と「味噌汁」だけでした。");

    for (@{ $ts->nodes }) {
        say $ts->surface;
    }

    say $tr->join_surface;
    
    my $filter = $parse->filter(type => [qw/名詞 助動詞/], 記号 => [qw/括弧開 括弧閉/]);
    say $filter->join_surface;

=head1 DESCRIPTION

Text::Shirasu is wrapped L<Text::MeCab>.  
This module has functions filter, replacement, etc...

=cut

sub new {
    my $class = shift;
    my %args = ref $_[0] eq 'HASH' ? %{ $_[0] } : @_;
    return bless {
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
}

=head2 parse

    $ts->parse("このおにぎりは「母」が握ってくれたものです。");

Text::MeCab の parse メソッドをラッピングしています。
parse メソッドは実行結果をオブジェクト内に保存し、オブジェクトを返します。
用意されている他のメソッドを使用すると結果を上書きして再びオブジェクト内に保存されることに注意してください。
=cut

sub parse {
    my $self     = shift;
    my $sentence = $_[0];

    croak "Sentence has not been inputted" unless $sentence;

    my $mt = $self->{mecab};

    # initialize
    $self->{nodes} = [];

    for (my $node = $mt->parse($sentence); $node && $node->surface; $node = $node->next) {
        push @{ $self->{nodes} }, bless {
            id      => $node->id,
            surface => $node->surface,
            feature => [ split /,/, $node->feature ],
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
        }, 'Text::Shirasu::Node';
    }

    return $self;
}

=head2 normalize
    
    $ts->normalize("あ━ ”（＊）” を〰〰 ’＋１’")
    $ts->normalize("テキスト〰〰", qw/nfkc, alnum_z2h/, \&your_create_routine)

Lingua::JA::NormalizeText を用いてテキストの正規化を行います.
=cut

sub normalize {
    my $self = shift;
    my $text = shift;
    my $normalizer = Lingua::JA::NormalizeText->new(@_ ? @_ : @{ $self->{normalize} });
    $normalizer->normalize(utf8::is_utf8($text) ? $text : decode_utf8($text));
}

=head2 filter
    
    $ts->filter(type => [qw/名詞/]);
    $ts->filter(type => [qw/名詞 記号/], 記号 => [qw/括弧開 括弧閉/]);

parse メソッド実行後にオブジェクト内に保存されている surface を feature の情報を利用して条件をもとに絞り込みます。
type をキーに欲しい品詞の情報を渡します。さらにその品詞の中から細かく絞り込みたい時は、その品詞名をキーにして、細かい情報を渡します。

=cut

sub filter {
    my $self = shift;
    my %params = ref $_[0] eq 'HASH' ? %{ $_[0] } : @_;

    # and search filter
    my @type = @{ delete $params{type} }
        or croak 'Query has not been inputted: "type"';

    # create parameter as /名詞|動詞/ or /名詞/
    my $query = join '|', @type;
    $query = encode_utf8($query) if utf8::is_utf8 $query;

    $self->{nodes} = [
        grep {
            $_->{feature}->[0] =~ /($query)/
                and _sub_query( $_->{feature}->[1], $params{$1} )
        } @{ $self->{nodes} }
    ];

    return $self;
}

=head2 join_surface
    
    $ts->join_surface()

オブジェクト内に保存されている surface を全て結合した文字列を返します。

=cut

sub join_surface {
    my $self = shift;
    croak "Does not exist parsed nodes" unless exists $self->{nodes};
    return join '', map { $_->{surface} } @{ $self->{nodes} };
}

=head2 nodes
    
    $ts->nodes

parse メソッドで入手した情報を格納したデータを返します。
tr や filter メソッドを利用すると nodes 内の surface の情報が変化します。  

=cut

sub nodes { $_[0]->{nodes} }

=head2 mecab
    
    $ts->mecab

Text::MeCab のオブジェクトを利用することができます。  

=cut

sub mecab { $_[0]->{mecab} }

=head2 nodes_dump
    
    $ts->nodes_dump(<FH>)

オブジェクト内に保存されている nodes 内のデータ構造を Data::Dumper を用いて表示します。

=cut

sub nodes_dump {
    my $self = shift;
    my $fh = defined( $_[0] ) && ref( \$_[0] ) eq "GLOB" ? $_[0] : *STDOUT;
    local $Data::Dumper::Sortkeys = 1;
    print {$fh} Data::Dumper::Dumper( $self->{nodes} );
}

# sub routines
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

# private
sub _sub_query {
    my ( $subtype, $query ) = @_;

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
