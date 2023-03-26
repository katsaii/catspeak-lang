
//# feather use syntax-errors

run_test(function() : Test("lexer-internal-empty") constructor {
    var buff = __catspeak_create_buffer_from_string(@'');
    var lexer = new CatspeakLexer(buff);
    assertEq("", lexer.getLexeme());
    buffer_delete(buff);
});

run_test(function() : Test("lexer-internal-ascii") constructor {
    var buff = __catspeak_create_buffer_from_string(@'let a = 1;');
    var lexer = new CatspeakLexer(buff);
    lexer.__advance(); // l
    lexer.__advance(); // e
    lexer.__advance(); // t
    lexer.__advance(); //
    lexer.__advance(); // a
    assertEq("let a", lexer.getLexeme());
    lexer.__clearLexeme();
    lexer.__advance(); //
    lexer.__advance(); // =
    assertEq(" =", lexer.getLexeme());
    lexer.__clearLexeme();
    lexer.__advance(); //
    lexer.__advance(); // 1
    lexer.__advance(); // ;
    lexer.__advance(); // EOF
    lexer.__advance(); // EOF
    assertEq(" 1;", lexer.getLexeme());
    buffer_delete(buff);
});

run_test(function() : Test("lexer-internal-unicode") constructor {
    var buff = __catspeak_create_buffer_from_string(@'🙀會意字');
    var lexer = new CatspeakLexer(buff);
    lexer.__advance(); // 🙀
    lexer.__advance(); // 會
    lexer.__advance(); // 意
    assertEq("🙀會意", lexer.getLexeme());
    lexer.__clearLexeme();
    lexer.__advance(); // 字
    assertEq("字", lexer.getLexeme());
    buffer_delete(buff);
});

function TestLexer(name, src) : Test(name) constructor {
    var buff = __catspeak_create_buffer_from_string(src);
    var lexer = new CatspeakLexer(buff);
    var pos = 1;
    repeat (string_length(src)) {
        lexer.__advance();
        assertEq(string_char_at(src, pos), lexer.getLexeme());
        lexer.__clearLexeme();
        pos += 1;
    }
    buffer_delete(buff);
}

// some of the following tests sample sentences from this
// resource: https://www.cl.cam.ac.uk/~mgk25/ucs/examples/quickbrown.txt

run_test(function() : TestLexer("lexer-internal-locale-danish",
    "Quizdeltagerne spiste jordbær med fløde, mens cirkusklovnen Wolther spillede på xylofon."
) constructor { });

run_test(function() : TestLexer("lexer-internal-locale-german",
    "Falsches Üben von Xylophonmusik quält jeden größeren Zwerg"
) constructor { });

run_test(function() : TestLexer("lexer-internal-locale-greek",
    "Ξεσκεπάζω τὴν ψυχοφθόρα βδελυγμία"
) constructor { });

run_test(function() : TestLexer("lexer-internal-locale-greek-2",
    "κόσμε"
) constructor { });

run_test(function() : TestLexer("lexer-internal-locale-english",
    "The quick brown fox jumps over the lazy dog"
) constructor { });

run_test(function() : TestLexer("lexer-internal-locale-spanish",
    "El pingüino Wenceslao hizo kilómetros bajo exhaustiva lluvia y frío, añoraba a su querido cachorro."
) constructor { });

run_test(function() : TestLexer("lexer-internal-locale-french",
    "Le cœur déçu mais l'âme plutôt naïve, Louÿs rêva de crapaüter en canoë au delà des îles, près du mälström où brûlent les novæ."
) constructor { });

run_test(function() : TestLexer("lexer-internal-locale-gaelic",
    "D'fhuascail Íosa, Úrmhac na hÓighe Beannaithe, pór Éava agus Ádhaimh"
) constructor { });

run_test(function() : TestLexer("lexer-internal-locale-hungarian",
    "Árvíztűrő tükörfúrógép"
) constructor { });

run_test(function() : TestLexer("lexer-internal-locale-icelandic",
    "Sævör grét áðan því úlpan var ónýt"
) constructor { });

run_test(function() : TestLexer("lexer-internal-locale-japanese-hiragana",
    "いろはにほへとちりぬるを"
) constructor { });

run_test(function() : TestLexer("lexer-internal-locale-japanese-hiragana-2",
    "あさきゆめみしゑひもせす"
) constructor { });

run_test(function() : TestLexer("lexer-internal-locale-japanese-katakana",
    "ウヰノオクヤマ ケフコエテ アサキユメミシ ヱヒモセスン"
) constructor { });

run_test(function() : TestLexer("lexer-internal-locale-hebrew",
    "? דג סקרן שט בים מאוכזב ולפתע מצא לו חברה איך הקליטה"
) constructor { });

run_test(function() : TestLexer("lexer-internal-locale-polish",
    "Pchnąć w tę łódź jeża lub ośm skrzyń fig"
) constructor { });

run_test(function() : TestLexer("lexer-internal-locale-russian",
    "Съешь же ещё этих мягких французских булок да выпей чаю"
) constructor { });

run_test(function() : TestLexer("lexer-internal-locale-turkish",
    "Pijamalı hasta, yağız şoföre çabucak güvendi."
) constructor { });