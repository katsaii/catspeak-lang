from dataclasses import dataclass

@dataclass
class TokenKind: pass

class Whitespace(TokenKind): pass
class Comment(TokenKind): pass
class Keyword(TokenKind): pass
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
        ret = self.peek(n)
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

def is_digit(x):
    return x in { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "_" }

def is_hexnum(x):
    return is_digit(x) or x.lower() in { "a", "b", "c", "d", "e", "f" }

def is_binnum(x):
    return x in { "0", "1" }

def has_digits(lexeme):
    return any(not (ch in { "_", "." }) for ch in lexeme)

def tokenise_gml(input_):
    keyword_database = set("""
        begin end if then else while do for break continue
        with until repeat exit and or xor not return mod
        div switch case default var globalvar enum function
        try catch finally throw static new delete constructor
    """.split())
    value_database = set("""
        true false NaN infinity undefined self other global
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
                lexeme = lex.advance_while(is_hexnum)
                yield (Other() if lexeme == "#" else Value()), lexeme
        elif lex.peek().isalpha() or lex.peek() == "_":
            # keywords and identifiers
            ident = lex.advance_while(lambda x: x.isalnum() or x == "_")
            kind = Variable()
            if ident in keyword_database:
                kind = Keyword()
            elif ident in value_database:
                kind = Value()
            elif ident == ident.upper():
                kind = MacroName()
            elif ident[:1].isupper():
                kind = TypeName()
            elif lex.peek() == "(":
                kind = FunctionName()
            yield kind, ident
        elif lex.peek() == "\"":
            lexeme = lex.advance()
            skip = False
            while not lex.is_empty():
                if lex.peek() in { "\n", "\r" }:
                    break
                ch = lex.advance()
                lexeme += ch
                if skip:
                    skip = False
                    continue
                elif ch == "\\":
                    skip = True
                elif ch == "\"":
                    break
            yield Value(), lexeme
        elif lex.peek(2) in { "@\"", "@'" }:
            lex.advance()
            terminator = lex.advance()
            yield Value(), f"@{terminator}" + lex.advance_until_terminated_by(terminator)
        elif lex.peek(2) in { "0x", "0X" }:
            prefix = lex.advance(2)
            yield Value(), prefix + lex.advance_while(is_hexnum)
        elif lex.peek(2) in { "0b", "0B" }:
            prefix = lex.advance(2)
            yield Value(), prefix + lex.advance_while(is_binnum)
        elif is_digit(lex.peek()) or lex.peek() == ".":
            lexeme = lex.advance_while(is_digit)
            if lex.peek() == ".":
                lexeme += lex.advance()
                lexeme += lex.advance_while(is_digit)
            yield (Value() if has_digits(lexeme) else Other()), lexeme
        else:
            yield Other(), lex.advance()

def tokenise_meow(input_):
    keyword_database = set("""
        if else while do break continue
        with and or xor return
        match case let fun
        catch finally throw new
    """.split())
    value_database = set("""
        true false undefined self
    """.split())
    lex = Tokeniser(input_)
    while not lex.is_empty():
        if lex.peek().isspace():
            yield Whitespace(), lex.advance_while(lambda x: x.isspace())
        elif lex.peek(2) == "--":
            yield Comment(), lex.advance_while(
                lambda x: not (x in { "\n", "\r" })
            )
        elif lex.peek().isalpha() or lex.peek() == "_":
            # keywords and identifiers
            ident = lex.advance_while(lambda x: x.isalnum() or x == "_")
            kind = Variable()
            if ident in keyword_database:
                kind = Keyword()
            elif ident in value_database:
                kind = Value()
            elif ident[:1].isupper():
                kind = TypeName()
            elif lex.peek() == "(":
                kind = FunctionName()
            yield kind, ident
        elif lex.peek() == "`":
            lexeme = lex.advance()
            while not lex.is_empty():
                if lex.peek() in { "\n", "\r" }:
                    break
                ch = lex.advance()
                lexeme += ch
                if ch == "`":
                    break
            yield Variable(), lexeme
        elif lex.peek() == "\"":
            lexeme = lex.advance()
            skip = False
            while not lex.is_empty():
                if lex.peek() in { "\n", "\r" }:
                    break
                ch = lex.advance()
                lexeme += ch
                if skip:
                    skip = False
                    continue
                elif ch == "\\":
                    skip = True
                elif ch == "\"":
                    break
            yield Value(), lexeme
        elif lex.peek() == "'":
            lexeme = lex.advance()
            skip = False
            while not lex.is_empty():
                if lex.peek() in { "\n", "\r" }:
                    break
                ch = lex.advance()
                lexeme += ch
                if skip:
                    skip = False
                    continue
                elif ch == "\\":
                    skip = True
                elif ch == "'":
                    break
            yield Value(), lexeme
        elif lex.peek(2) in { "0x", "0X" }:
            prefix = lex.advance(2)
            yield Value(), prefix + lex.advance_while(is_hexnum)
        elif lex.peek(2) in { "0b", "0B" }:
            prefix = lex.advance(2)
            yield Value(), prefix + lex.advance_while(is_binnum)
        elif is_digit(lex.peek()) or lex.peek() == ".":
            lexeme = lex.advance_while(is_digit)
            if lex.peek() == ".":
                lexeme += lex.advance()
                lexeme += lex.advance_while(is_digit)
            yield (Value() if has_digits(lexeme) else Other()), lexeme
        else:
            yield Other(), lex.advance()