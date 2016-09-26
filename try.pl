use strict;
use warnings;
use Data::Dumper;
use utf8;
use v5.10;

use FindBin;
BEGIN { push @INC, "$FindBin::Bin/lib"; };

use Text::Shirasu;

my $mt = Text::Shirasu->new;
$mt->parse("昨日の晩御飯は，鮭のふりかけと「味噌汁」だけでしたか！？");
#$mt->print;

print $mt->join_surface."\n\n";
say $mt->tr('，！？' => ',!?')->join_surface;

say $mt->filter(type => [qw/名詞 助動詞 記号/], 記号 => [qw/括弧開 括弧閉/])->join_surface;
$mt->result_dump;

