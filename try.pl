use strict;
use warnings;
use Data::Dumper;
use utf8;

use FindBin;
BEGIN { push @INC, "$FindBin::Bin/lib"; };

use Text::MeCab::Easy;

my $mt = Text::MeCab::Easy->new;
$mt->parse("昨日の晩御飯は鮭のふりかけと味噌汁だけでした。");
#$mt->print;

my $filtered = $mt->filter(part_of_speech => [qw/名詞/]);

print Dumper $filtered;

