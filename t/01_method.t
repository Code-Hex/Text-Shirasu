use strict;
use Test::More 0.98;
use utf8;
use Encode qw/encode_utf8/;

use File::Spec;
use lib File::Spec->catfile('t', 'lib');
use Text::Shirasu;

my $text = encode_utf8 "昨日の晩御飯は，鮭のふりかけと「味噌汁」だけでしたか！？";

# parse
my $ts = Text::Shirasu->new;
is $ts->parse($text)->join_surface, $text, encode_utf8("テキストのパースができてるか");

# tr
my $expected = encode_utf8 "昨日の晩御飯は,鮭のふりかけと「味噌汁」だけでしたか!?";
my $a = $ts->tr('，！？' => ',!?')->join_surface;
is $a, $expected, encode_utf8("テキストの置換ができているか");

# filter
$expected = encode_utf8 "昨日晩御飯鮭「味噌汁」でした";
my $filter = $ts->filter(type => [qw/名詞 助動詞 記号/], 記号 => [qw/括弧開 括弧閉/])->join_surface;
is $filter, $expected, encode_utf8("文字列のフィルタリングが正しく行えてるか");

done_testing;

