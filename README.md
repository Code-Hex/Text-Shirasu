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
    
    my $filter = $parse->filter(type => [qw/名詞 助動詞/], 記号 => [qw/括弧開 括弧閉/]);
    say $filter->join_surface;

# DESCRIPTION

Text::Shirasu is wrapped [Text::MeCab](https://metacpan.org/pod/Text::MeCab).  
This module has functions filter, replacement, etc...

## parse

    $ts->parse("このおにぎりは「母」が握ってくれたものです。");

Text::MeCab の parse メソッドをラッピングしています。
parse メソッドは実行結果をオブジェクト内に保存し、オブジェクトを返します。
用意されている他のメソッドを使用すると結果を上書きして再びオブジェクト内に保存されることに注意してください。

## tr

    $ts->tr('，！？' => ',!?');

Perl の tr と同じように parse メソッド実行後にオブジェクト内に保存されている surface の文字列を置換します。

## filter

    $ts->filter(type => [qw/名詞/]);
    $ts->filter(type => [qw/名詞 記号/], 記号 => [qw/括弧開 括弧閉/]);

parse メソッド実行後にオブジェクト内に保存されている surface を feature の情報を利用して条件をもとに絞り込みます。
type をキーに欲しい品詞の情報を渡します。さらにその品詞の中から細かく絞り込みたい時は、その品詞名をキーにして、細かい情報を渡します。

## join\_surface

    $ts->join_surface()

オブジェクト内に保存されている surface を全て結合した文字列を返します。

## result

    $ts->result

parse メソッドで入手した情報を格納したデータを返します。
tr や filter メソッドを利用すると result 内の surface の情報が変化します。  

## mecab

    $ts->mecab

Text::MeCab のオブジェクトを利用することができます。  

## result\_dump

    $ts->result_dump()

オブジェクト内に保存されている result 内のデータ構造を Data::Dumper を用いて表示します。

# LICENSE

Copyright (C) Kei Kamikawa(Code-Hex).

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Kei Kamikawa <x00.x7f@gmail.com>
