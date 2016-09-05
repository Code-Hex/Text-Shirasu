use strict;
use warnings;
use Data::Dumper;
use utf8;

use FindBin;
BEGIN { push @INC, "$FindBin::Bin/lib"; };

use Text::MeCab::Soup;

my $mt = Text::MeCab::Soup->new;
$mt->parse("昨日の晩御飯は鮭のふりかけと味噌汁だけでした。");
#$mt->print;

my @filtered = $mt->search(type => [qw/名詞 助動詞/]);

print Dumper \@filtered;

