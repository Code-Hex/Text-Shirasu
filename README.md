# NAME

Text::MeCab::Soup - It's new $module

# SYNOPSIS

    use Data::Dumper;
    use Text::MeCab::Soup;
    my $mt = Text::MeCab::Soup->new;
    $mt->parse("昨日の晩御飯は鮭のふりかけと味噌汁だけでした。");

    my $filtered = $mt->filter(type => [qw/名詞 助動詞/]);
    print Dumper $filtered;

# DESCRIPTION

Text::MeCab::Soup is ...

# LICENSE

Copyright (C) K.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

K <x00.x7f@gmail.com>
