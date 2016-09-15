# NAME

Text::Shirasu - It's new $module

# SYNOPSIS

    use utf8;
    use Text::Shirasu;
    my $mt = Text::Shirasu->new;
    my $parse = $mt->parse("昨日の晩御飯は「鮭のふりかけ」と「味噌汁」だけでした。");

    my $search = $parse->search(type => [qw/名詞 助動詞/], 記号 => [qw/括弧開 括弧閉/]);
    print Dumper $search->result;

# DESCRIPTION

Text::Shirasu is ...

# LICENSE

Copyright (C) K.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

K <x00.x7f@gmail.com>
