
//# feather use syntax-errors

// some of the following tests sample sentences from this resource:
// https://www.cl.cam.ac.uk/~mgk25/ucs/examples/quickbrown.txt

test_add(function () : TestLexerUTF8("lexer-locale-danish",
    "Quizdeltagerne spiste jordbær med fløde, mens cirkusklovnen Wolther spillede på xylofon."
) constructor { }, IgnorePlatform.HTML5);

test_add(function () : TestLexerUTF8("lexer-locale-german",
    "Falsches Üben von Xylophonmusik quält jeden größeren Zwerg"
) constructor { }, IgnorePlatform.HTML5);

test_add(function () : TestLexerUTF8("lexer-locale-greek",
    "Ξεσκεπάζω τὴν ψυχοφθόρα βδελυγμία"
) constructor { }, IgnorePlatform.HTML5);

test_add(function () : TestLexerUTF8("lexer-locale-greek-2",
    "κόσμε"
) constructor { }, IgnorePlatform.HTML5);

test_add(function () : TestLexerUTF8("lexer-locale-english",
    "The quick brown fox jumps over the lazy dog"
) constructor { });

test_add(function () : TestLexerUTF8("lexer-locale-spanish",
    "El pingüino Wenceslao hizo kilómetros bajo exhaustiva lluvia y frío, añoraba a su querido cachorro."
) constructor { }, IgnorePlatform.HTML5);

test_add(function () : TestLexerUTF8("lexer-locale-french",
    "Le cœur déçu mais l'âme plutôt naïve, Louÿs rêva de crapaüter en canoë au delà des îles, près du mälström où brûlent les novæ."
) constructor { }, IgnorePlatform.HTML5);

test_add(function () : TestLexerUTF8("lexer-locale-gaelic",
    "D'fhuascail Íosa, Úrmhac na hÓighe Beannaithe, pór Éava agus Ádhaimh"
) constructor { }, IgnorePlatform.HTML5);

test_add(function () : TestLexerUTF8("lexer-locale-hungarian",
    "Árvíztűrő tükörfúrógép"
) constructor { }, IgnorePlatform.HTML5);

test_add(function () : TestLexerUTF8("lexer-locale-icelandic",
    "Sævör grét áðan því úlpan var ónýt"
) constructor { }, IgnorePlatform.HTML5);

test_add(function () : TestLexerUTF8("lexer-locale-japanese-hiragana",
    "いろはにほへとちりぬるを"
) constructor { }, IgnorePlatform.HTML5);

test_add(function () : TestLexerUTF8("lexer-locale-japanese-hiragana-2",
    "あさきゆめみしゑひもせす"
) constructor { }, IgnorePlatform.HTML5);

test_add(function () : TestLexerUTF8("lexer-locale-japanese-katakana",
    "ウヰノオクヤマ ケフコエテ アサキユメミシ ヱヒモセスン"
) constructor { }, IgnorePlatform.HTML5);

test_add(function () : TestLexerUTF8("lexer-locale-hebrew",
    "? דג סקרן שט בים מאוכזב ולפתע מצא לו חברה איך הקליטה"
) constructor { }, IgnorePlatform.HTML5);

test_add(function () : TestLexerUTF8("lexer-locale-polish",
    "Pchnąć w tę łódź jeża lub ośm skrzyń fig"
) constructor { }, IgnorePlatform.HTML5);

test_add(function () : TestLexerUTF8("lexer-locale-russian",
    "Съешь же ещё этих мягких французских булок да выпей чаю"
) constructor { }, IgnorePlatform.HTML5);

test_add(function () : TestLexerUTF8("lexer-locale-turkish",
    "Pijamalı hasta, yağız şoföre çabucak güvendi."
) constructor { }, IgnorePlatform.HTML5);