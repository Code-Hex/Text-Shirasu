use strict;
use warnings;
use Data::Dumper;
use utf8;
use v5.10;
use Encode;

use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/lib"; };

use Text::Shirasu;

my $ts = Text::Shirasu->new; # this parameter same as Text::MeCab
my $parse = $ts->parse("昨日の晩御飯は「鮭のふりかけ」と「味噌汁」だけでした。");

for my $node (@{ $ts->nodes }) {
    say $node->surface;
    say Dumper $node->feature;
}

my $filter = $parse->filter(type => [qw/名詞 助動詞/], 記号 => [qw/括弧開 括弧閉/]);
say $filter->join_surface;