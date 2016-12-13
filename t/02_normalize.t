use Test::More;
use utf8;
use Encode qw/encode_utf8/;
use File::Spec;
use lib File::Spec->catfile('t', 'lib');
use Text::Shirasu;

my $ts = Text::Shirasu->new;

subtest 'normalize' => sub {
	is $ts->normalize("０１２３４５６７８９"), "0123456789", "z2h normalize number";
	is $ts->normalize(encode_utf8 "０１２３４５６７８９"), "0123456789", "z(encode_utf8)2h normalize number";
	is $ts->normalize("ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ"), "ABCDEFGHIJKLMNOPQRSTUVWXYZ", "z2h normalize uppercase alphabet";
	is $ts->normalize(encode_utf8 "ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ"), "ABCDEFGHIJKLMNOPQRSTUVWXYZ", "z(encode_utf8)2h normalize uppercase alphabet";
	is $ts->normalize("ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ"), "abcdefghijklmnopqrstuvwxyz", "z2h normalize lowercase alphabet";
	is $ts->normalize(encode_utf8 "ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ"), "abcdefghijklmnopqrstuvwxyz", "z(encode_utf8)2h normalize lowercase alphabet";
	# ”’
	is $ts->normalize("！＂＃＄％＆＇（）＊＋，－．／：；＜＞？＠［￥］＾＿｀｛｜｝"), "!\"#\$%&'()*+,-./:;<>?@[¥]^_`{|}", "z2h normalize symbols";
	is $ts->normalize(encode_utf8 "！＂＃＄％＆＇（）＊＋，－．／：；＜＞？＠［￥］＾＿｀｛｜｝"), "!\"#\$%&'()*+,-./:;<>?@[¥]^_`{|}", "z(encode_utf8)2h normalize symbols";
	is $ts->normalize("＝。、・「」"), "=｡､･｢｣", "z2h normalize symbols second turn";
	is $ts->normalize(encode_utf8 "＝。、・「」"), "=｡､･｢｣", "z2h normalize symbols second turn(encode_utf8)";
	is $ts->normalize(" ああ "), "ああ", "trim spaces";
	is $ts->normalize(encode_utf8 " ああ "), "ああ", "trim spaces(encode_utf8)";
	is $ts->normalize("　ああ　"), "ああ", "trim spaces";
	is $ts->normalize(encode_utf8 "　ああ　"), "ああ", "trim spaces(encode_utf8)";
	is $ts->normalize("お、俺の━ （＊） を掘らないで〰〰 ＋１"), "お､俺のー (*) を掘らないで +1", "complex normalize";
};

done_testing;