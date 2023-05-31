
//# feather use syntax-errors

test_add(function() : TestCodegenGMLResult("codegen-gml-value-int",
    "1 ; 2 ; 3 ; 4", 4
) constructor { });

test_add(function() : TestCodegenGMLResult("codegen-gml-value-string",
    @'"hello world"', "hello world"
) constructor { });

test_add(function() : TestCodegenGMLResult("codegen-gml-value-string-2",
    @'"hello" "( •̀ ω •́ )✧(⊙x⊙;)(⊙_⊙;)(⊙_⊙;)◉_◉ΒβΘ ΡάᾱὺΏὠ⨊⩓⩓↪◶"',
    "( •̀ ω •́ )✧(⊙x⊙;)(⊙_⊙;)(⊙_⊙;)◉_◉ΒβΘ ΡάᾱὺΏὠ⨊⩓⩓↪◶"
) constructor { });

test_add(function() : TestCodegenGMLResult("codegen-gml-value-string-3",
    @'"( •̀ ω •́ )✧(⊙x⊙;)(⊙_⊙;)(⊙_⊙;)◉_◉ΒβΘ ΡάᾱὺΏὠ⨊⩓⩓↪◶" "hello"',
    "hello"
) constructor { });

test_add(function() : TestCodegenGML("codegen-gml-value-fun",
    @'let a = fun { let b = "hiiiii"; b } ; a'
) constructor {
    var a = self.gmlFunc();
    assertEq("hiiiii", a());
});

test_add(function() : TestCodegenGMLResult("codegen-gml-value-block",
    @'
        let a = do{
          let b;
          b = 54
          b
        }
        a
    ',
    54
) constructor { });

test_add(function() : TestCodegenGMLResult("codegen-gml-value-block-2",
    @'
        let a = do{ }
        a
    ',
    undefined
) constructor { });

test_add(function() : TestCodegenGML("codegen-gml-value-self",
    @'let a = self; a'
) constructor {
    self.gmlFunc.setSelf(self);
    assertEq(self, self.gmlFunc());
});