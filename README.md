# NAME

Text::Shirasu - Text::MeCab wrapper

# SYNOPSIS

    use utf8;
    use feature ':5.10';
    use Text::Shirasu;
    my $ts = Text::Shirasu->new; # this parameter same as Text::MeCab
    my $parse = $ts->parse("昨日の晩御飯は「鮭のふりかけ」と「味噌汁」だけでした。");

    my $tr = $parse->tr('。' => '.');
    say $tr->join_surface;
    
    my $search = $parse->search(type => [qw/名詞 助動詞/], 記号 => [qw/括弧開 括弧閉/]);
    say $search->join_surface;

# DESCRIPTION

Text::Shirasu wrapped [Text::MeCab](https://metacpan.org/pod/Text::MeCab).  
This module has functions filter, replacement, etc...

# LICENSE

Copyright (C) Kei Kamikawa(Code-Hex).

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Kei Kamikawa <x00.x7f@gmail.com>
