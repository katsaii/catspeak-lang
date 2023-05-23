
//# feather use syntax-errors

test_add(function() : TestCodegenGMLResult("codegen-gml-value-int",
    "1 2 3 4", 4
) constructor { });

test_add(function() : TestCodegenGMLResult("codegen-gml-value-string",
    @'"hello world"', "hello world"
) constructor { });

test_add(function() : TestCodegenGMLResult("codegen-gml-value-string-2",
    @'"hello" "( •̀ ω •́ )✧(⊙x⊙;)(⊙_⊙;)(⊙_⊙;)◉_◉ΒβΘ ΡάᾱὺΏὠ⨊⩓⩓↪◶"',
    "( •̀ ω •́ )✧(⊙x⊙;)(⊙_⊙;)(⊙_⊙;)◉_◉ΒβΘ ΡάᾱὺΏὠ⨊⩓⩓↪◶"
) constructor { });

test_add(function() : TestCodegenGMLResult("codegen-gml-value-string-2",
    @'"( •̀ ω •́ )✧(⊙x⊙;)(⊙_⊙;)(⊙_⊙;)◉_◉ΒβΘ ΡάᾱὺΏὠ⨊⩓⩓↪◶" "hello"',
    "hello"
) constructor { });