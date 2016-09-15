# NAME

Text::Shirasu - Text::MeCab wrapper

# SYNOPSIS

    use utf8;
    use Text::Shirasu;
    my $ts = Text::Shirasu->new;
    my $parse = $ts->parse("昨日の晩御飯は「鮭のふりかけ」と「味噌汁」だけでした。");

    use Data::Dumper;
    my $search = $parse->search(type => [qw/名詞 助動詞/], 記号 => [qw/括弧開 括弧閉/]);
    print Dumper $search->result;

    my $tr = $parse->parse('。' => '.');
    print Dumper $tr->result;

# DESCRIPTION

Text::Shirasu wrapped [Text::MeCab](https://metacpan.org/pod/Text::MeCab).  
This module has functions filter, replacement, etc...

# LICENSE

Copyright (C) Kei Kamikawa(Code-Hex).

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Kei Kamikawa <x00.x7f@gmail.com>
