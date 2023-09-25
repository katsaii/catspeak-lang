from dataclasses import dataclass

@dataclass
class TokenKind: pass

class Whitespace(TokenKind): pass
class Comment(TokenKind): pass
class Keyword(TokenKind): pass
class Comment(TokenKind): pass
class Value(TokenKind): pass
class Variable(TokenKind): pass
class FunctionName(TokenKind): pass
class TypeName(TokenKind): pass
class MacroName(TokenKind): pass
class Other(TokenKind): pass

@dataclass
class Tokeniser():
    src : str = ""

    def is_empty(self):
        return self.src == ""

    def advance(self, n=1):
        ret = self.peek()
        self.src = self.src[n:]
        return ret

    def advance_while(self, condition):
        src = self.src
        n = 0
        while not self.is_empty() and condition(self.peek()):
            self.advance()
            n += 1
        return src[:n]

    def advance_until_terminated_by(self, terminator):
        src = self.src
        n = 0
        while not self.is_empty() and self.peek(len(terminator)) != terminator:
            self.advance()
            n += 1
        self.advance(len(terminator))
        n += len(terminator)
        return src[:n]

    def peek(self, n=1):
        return self.src[:n]

def tokenise_gml(input_):
    keyword_database = set("""
        begin end if then else while do for break continue
        with until repeat exit and or xor not return mod
        div switch case default var globalvar enum function
        try catch finally throw static new delete constructor
    """.split())
    lex = Tokeniser(input_)
    while not lex.is_empty():
        if lex.peek().isspace():
            yield Whitespace(), lex.advance_while(lambda x: x.isspace())
        elif lex.peek(2) == "//":
            yield Comment(), lex.advance_while(
                lambda x: not (x in { "\n", "\r" })
            )
        elif lex.peek(2) == "/*":
            lex.advance(2)
            yield Comment(), "/*" + lex.advance_until_terminated_by("*/")
        elif lex.peek() == "#":
            # pre-processor directives and CSS colour literals
            found = False
            for directive in ["#macro", "#line", "#region", "#endregion"]:
                if lex.peek(len(directive)) == directive:
                    yield Keyword(), lex.advance(len(directive))
                    found = True
                    break
            if not found:
                # TODO: colour literals
                yield Other(), lex.advance()
        elif lex.peek().isalpha():
            # keywords and identifiers
            ident = lex.advance_while(lambda x: x.isalnum() or x == "_")
            kind = Variable()
            if ident in keyword_database:
                kind = Keyword()
            elif lex.peek() == "(":
                kind = FunctionName()
            elif all(x.isupper() for x in ident):
                kind = MacroName()
            elif ident[:1].isupper():
                kind = TypeName()
            yield kind, ident
        else:
            yield Other(), lex.advance()