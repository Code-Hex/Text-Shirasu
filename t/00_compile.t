use strict;
use Test::More 0.98;

use FindBin;
BEGIN { push @INC, "$FindBin::Bin/../lib"; };

use_ok $_ for qw(
    Text::MeCab::Soup
);

done_testing;

