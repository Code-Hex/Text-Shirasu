requires 'Text::MeCab';
requires 'Text::CaboCha', '>= 0.04';
requires 'Lingua::JA::NormalizeText';

on 'test' => sub {
    requires 'Test::More';
};

