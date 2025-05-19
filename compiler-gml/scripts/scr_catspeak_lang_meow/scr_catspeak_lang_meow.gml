//! "Meow" is the code name for the Catspeak programming language, loosely
//! inspired by syntax from JavaScript, GML, and Rust.
//!
//! This module contains the parser for this language.

//# feather use syntax-errors

var buff = catspeak_util_buffer_create_from_string(@'
    let `abcdef$` = @"this is a test script ""but do quotes work?"""
    "normal string, no escapes"
    "normal string, yes\tescapes \"\n"
');
var lexer = new CatspeakLexer(buff);
while lexer.nextWithWhitespace() != CatspeakToken.EOF {
    var lexeme = lexer.getLexeme();
    var value = lexer.getValue();
    value = is_string(value) ? value : string(value);
    show_debug_message("token: '" + lexeme + "' = " + value);
}
show_message("see output");

/// A token in Catspeak is a series of characters with meaning, usually
/// separated by whitespace. These meanings are represented by unique
/// elements of the `CatspeakToken` enum.
///
/// @example
///   Some examples of tokens in Catspeak, and their meanings:
///   - `if`   (is a `CatspeakToken.IF`)
///   - `else` (is a `CatspeakToken.ELSE`)
///   - `12.3` (is a `CatspeakToken.NUMBER`)
///   - `+`    (is a `CatspeakToken.PLUS`)
enum CatspeakToken {
    /// End of the file.
    EOF = 0,
    COLON,
    COLON_COLON,
    COMMA,
    ARROW,
    /// @ignore
    __TERMINAL_BEGIN__,
    SELF,
    OTHER,
    /// Reserved in case of argument array access.
    ///
    /// @experimental
    PARAMS,
    /// Reserved in case of argument array access.
    ///
    /// @experimental
    PARAMS_COUNT,
    /// Represents a variable name.
    ///
    /// This can either be an alphanumeric name, or a so-called
    /// "raw identifier" wrapped in backticks `` ` ``.
    IDENT,
    /// Represents a numeric value. This could be one of:
    ///  - integer:           `1`, `2`, `5`
    ///  - float:             `1.25`, `0.5`
    ///  - character:         `'A'`, `'0'`, `'\n'`
    ///  - boolean:           `true` or `false`
    NUMBER,
    /// Represents a string value. This could be one of:
    ///  - string literal:    `"hello world"`
    ///  - verbatim literal:  `@"\(0_0)/ no escapes!"`
    STRING,
    /// Represents the `undefined` value in GML. Logically boring.
    UNDEFINED,
    /// @ignore
    __TERMINAL_END__,
    /// @ignore
    __INDEX_BEGIN__,
    PAREN_LEFT,
    PAREN_RIGHT,
    BOX_LEFT,
    BOX_RIGHT,
    BRACE_LEFT,
    BRACE_RIGHT,
    DOT,
    NEW,
    /// @ignore
    __INDEX_END__,
    /// @ignore
    __OP_MULT_BEGIN__,
    REMAINDER,
    MULTIPLY,
    DIVIDE,
    DIVIDE_INT,
    /// @ignore
    __OP_MULT_END__,
    /// @ignore
    __OP_UNARY_BEGIN__,
    /// @ignore
    __OP_ADD_BEGIN__,
    SUBTRACT,
    PLUS,
    /// @ignore
    __OP_ADD_END__,
    NOT,
    BITWISE_NOT,
    /// @ignore
    __OP_UNARY_END__,
    /// @ignore
    __OP_BITWISE_BEGIN__,
    BITWISE_AND,
    BITWISE_XOR,
    BITWISE_OR,
    SHIFT_RIGHT,
    SHIFT_LEFT,
    /// @ignore
    __OP_BITWISE_END__,
    /// @ignore
    __OP_RELATE_BEGIN__,
    GREATER,
    GREATER_EQUAL,
    LESS,
    LESS_EQUAL,
    /// @ignore
    __OP_RELATE_END__,
    /// @ignore
    __OP_EQUAL_BEGIN__,
    EQUAL,
    NOT_EQUAL,
    /// @ignore
    __OP_EQUAL_END__,
    /// @ignore
    __OP_PIPE_BEGIN__,
    PIPE_RIGHT,
    PIPE_LEFT,
    /// @ignore
    __OP_PIPE_END__,
    AND,
    /// @ignore
    __OP_OR_BEGIN__,
    OR,
    XOR,
    /// @ignore
    __OP_OR_END__,
    /// @ignore
    __BLOCKEXPR_BEGIN__,
    DO,
    IF,
    ELSE,
    WHILE,
    /// Reserved in case of for loops.
    ///
    /// @experimental
    FOR,
    /// Reserved in case of infinite loops.
    ///
    /// @experimental
    LOOP,
    WITH,
    /// @experimental
    MATCH,
    FUN,
    /// Reserved in case of constructors.
    ///
    /// @experimental
    IMPL,
    /// @ignore
    __BLOCKEXPR_END__,
    CATCH,
    /// @ignore
    __OP_ASSIGN_BEGIN__,
    ASSIGN,
    ASSIGN_MULTIPLY,
    ASSIGN_DIVIDE,
    ASSIGN_SUBTRACT,
    ASSIGN_PLUS,
    /// @ignore
    __OP_ASSIGN_END__,
    /// @ignore
    __EXPR_BEGIN__,
    RETURN,
    CONTINUE,
    BREAK,
    THROW,
    /// @ignore
    __EXPR_END__,
    /// @ignore
    __STMT_BEGIN__,
    SEMICOLON,
    LET,
    /// @ignore
    __STMT_END__,
    /// Represents a sequence of non-breaking whitespace characters.
    WHITESPACE,
    COMMENT,
    /// Represents any other unrecognised character.
    ///
    /// @remark
    ///   If the compiler encounters a token of this type, it will typically
    ///   raise an exception. This likely indicates that a Catspeak script has
    ///   a syntax error somewhere.
    ERROR,
    /// @ignore
    __SIZE__,
}

/// Responsible for tokenising the contents of a GML buffer. This can be used
/// for syntax highlighting in a programming game which uses Catspeak.
///
/// @warning
///   The lexer does not take ownership of its buffer, so you must make sure
///   to delete the buffer once the lexer is complete. Failure to do this will
///   result in leaking memory.
///
/// @param {Id.Buffer} buff
///   The ID of the GML buffer to use.
///
/// @param {Real} [offset]
///   The offset in the buffer to start parsing from. Defaults to 0.
///
/// @param {Real} [size]
///   The length of the buffer input. Any characters beyond this limit
///   will be treated as the end of the file. Defaults to `infinity`.
function CatspeakLexer(buff, offset = undefined, size = undefined)
        : CatspeakUTF8Scanner(buff, offset, size) constructor {
    /// @ignore
    value = undefined;
    /// @ignore
    hasValue = false;
    /// @ignore
    peeked = undefined;

    /// Returns the actual value representation of the most recent token
    /// emitted by the `next` or `nextWithWhitespace` methods.
    ///
    /// @remark
    ///   Unlike `getLexeme` this value is not always a string. For numeric
    ///   literals, the value will be converted into an integer or real.
    ///
    /// @return {Any}
    static getValue = function () {
        if (hasValue) {
            return value;
        }
        value = getLexeme();
        hasValue = true;
        return value;
    };

    /// Advances the lexer and returns the next type of `CatspeakToken`. This
    /// includes additional whitespace and comment tokens.
    ///
    /// @remark
    ///   To get the string content of the token, you should use the
    ///   `getLexeme` method.
    ///
    /// @example
    ///   Iterates through all tokens of a buffer containing Catspeak code,
    ///   printing each non-whitespace token out as a debug message.
    ///
    ///   ```gml
    ///   var lexer = new CatspeakLexerV3(buff);
    ///   do {
    ///     var token = lexer.nextWithWhitespace();
    ///     if (token != CatspeakToken.WHITESPACE) {
    ///       show_debug_message(lexer.getLexeme());
    ///     }
    ///   } until (token == CatspeakToken.EOF);
    ///   ```
    ///
    /// @return {Enum.CatspeakToken}
    static nextWithWhitespace = function () {
        clearLexeme();
        hasValue = false;
        if (isEndOfFile) {
            return CatspeakToken.EOF;
        }
        advanceChar();
        var charCurr_ = charCurr;
        var token = charCurr_ < 0xFF ? __asciiCodepage[charCurr_] : CatspeakToken.ERROR;
        var sublexer = __lexerLookup[token];
        if (sublexer != undefined) {
            token = sublexer() ?? token;
        }
        return token;
    };

    /// @ignore
    static __completeWhitespace = function () {
        while (__catspeak_char_is_whitespace(charNext)) {
            advanceChar();
        }
    };

    /// @ignore
    static __completeIdent = function () {
        if (charCurr == ord("`")) {
            // raw identifiers
            if (charNext == ord("`")) { // empty raw string
                return CatspeakToken.ERROR;
            }
            while (
                !isEndOfFile && charNext != ord("`") &&
                !__catspeak_char_is_whitespace(charNext)
            ) {
                advanceChar();
            }
            if (charNext != ord("`")) { // unterminated raw string
                return CatspeakToken.ERROR;
            }
            advanceChar();
            value = getLexeme(1, 1); // trim off the backticks ``
            hasValue = true;
        } else {
            while (__catspeak_char_is_alphanum(charNext)) {
                advanceChar();
            }
            value = getLexeme();
            hasValue = true;
            var keyword = __keywords[$ value];
            if (keyword != undefined) {
                return keyword;
            }
            var literal = __literals[$ value];
            if (literal != undefined) {
                value = literal;
                return CatspeakToken.NUMBER;
            }
            if (value == "undefined") {
                value = undefined;
                return CatspeakToken.UNDEFINED;
            }
        }
    };

    /// @ignore
    static __completeNumber = function () {
        var charCurr_ = charCurr;
        var charNext_ = charNext;
        if (charCurr_ == ord("'")) {
            // char literals
            advanceChar();
            if (charNext != ord("'")) { // unterminated char literal
                return CatspeakToken.ERROR;
            }
            advanceChar();
            value = charNext_;
            hasValue = true;
        } else if (charCurr_ == ord("#")) {
            // colour literals
            // TODO
        } else if (
            charCurr_ == ord("0") &&
            (charNext_ == ord("b") || charNext_ == ord("B"))
        ) {
            // binary literals
            // TODO
        } else if (
            charCurr_ == ord("0") &&
            (charNext_ == ord("x") || charNext_ == ord("X"))
        ) {
            // hex literals
            // TODO
        } else {
            // plain ol' numbers
            // TODO
        }
    };

    /// @ignore
    static __completeString = function () {
        if (charCurr == ord("@")) {
            if (charNext != ord("\"")) { // malformed verbatim string
                return CatspeakToken.ERROR;
            }
            advanceChar();
            value = "";
            var lexemeOffset = 2;
            while (!isEndOfFile) {
                if (charNext == ord("\"")) {
                    value += getLexeme(lexemeOffset); // trim off the quotes
                    lexemeOffset = advanceChar();
                    if (charNext != ord("\"")) {
                        hasValue = true;
                        break;
                    }
                    // juxtaposed verbatim strings escape quotes @"""" == "\""
                }
                advanceChar();
            }
            if (!hasValue) { // unterminated verbatim string
                return CatspeakToken.ERROR;
            }
        } else {
            // plain ol' strings
            value = "";
            var lexemeOffset = 1;
            while (!isEndOfFile) {
                var charNext_ = charNext;
                if (charNext_ == ord("\\")) {
                    // process escapes
                    value += getLexeme(lexemeOffset);
                    lexemeOffset = advanceChar();
                    charNext_ = charNext;
                    if (__catspeak_char_is_whitespace(charNext_)) {
                        // remove whitespace
                        lexemeOffset = advanceChar();
                        while (__catspeak_char_is_whitespace(charNext)) {
                            lexemeOffset = advanceChar();
                        }
                        continue;
                    } else if (charNext_ < 0xFF) {
                        var replacement = __escapes[charNext_];
                        if (replacement != undefined) {
                            value += replacement;
                            lexemeOffset = advanceChar();
                            continue;
                        }
                    }
                } else if (charNext_ == ord("\"")) {
                    value += getLexeme(lexemeOffset); // trim off the quotes
                    lexemeOffset = advanceChar();
                    hasValue = true;
                    break;
                }
                advanceChar();
            }
            if (!hasValue) { // unterminated string
                return CatspeakToken.ERROR;
            }
        }
    };

    /// @ignore
    static __completeColon = function () {
        if (charNext == ord(":")) {
            advanceChar();
            return CatspeakToken.COLON_COLON;
        }
    };

    /// @ignore
    static __completeAssign = function () {
        if (charNext == ord("=")) {
            advanceChar();
            return CatspeakToken.EQUAL;
        }
    };

    /// @ignore
    static __completeMultiply = function () {
        if (charNext == ord("=")) {
            advanceChar();
            return CatspeakToken.ASSIGN_MULTIPLY;
        }
    };

    /// @ignore
    static __completeDivide = function () {
        var charNext_ = charNext;
        if (charNext_ == ord("=")) {
            advanceChar();
            return CatspeakToken.ASSIGN_DIVIDE;
        } else if (charNext_ == ord("/")) {
            advanceChar();
            return CatspeakToken.DIVIDE_INT;
        }
    };

    /// @ignore
    static __completePlus = function () {
        if (charNext == ord("=")) {
            advanceChar();
            return CatspeakToken.ASSIGN_PLUS;
        }
    };

    /// @ignore
    static __completeSubtract = function () {
        var charNext_ = charNext;
        if (charNext_ == ord("=")) {
            advanceChar();
            return CatspeakToken.ASSIGN_SUBTRACT;
        } else if (charNext_ == ord("-")) {
            // comments
            do {
                advanceChar();
            } until (
                isEndOfFile ||
                charNext == ord("\n") ||
                charNext == ord("\r")
            );
        }
    };

    /// @ignore
    static __completeNot = function () {
        if (charNext == ord("=")) {
            advanceChar();
            return CatspeakToken.NOT_EQUAL;
        }
    };

    /// @ignore
    static __completeGreater = function () {
        var charNext_ = charNext;
        if (charNext_ == ord("=")) {
            advanceChar();
            return CatspeakToken.GREATER_EQUAL;
        } else if (charNext_ == ord(">")) {
            advanceChar();
            return CatspeakToken.SHIFT_RIGHT;
        }
    };

    /// @ignore
    static __completeLess = function () {
        var charNext_ = charNext;
        if (charNext_ == ord("=")) {
            advanceChar();
            return CatspeakToken.LESS_EQUAL;
        } else if (charNext_ == ord("<")) {
            advanceChar();
            return CatspeakToken.SHIFT_LEFT;
        } else if (charNext_ == ord("|")) {
            advanceChar();
            return CatspeakToken.PIPE_LEFT;
        }
    };

    /// @ignore
    static __completeBitwiseOr = function () {
        if (charNext == ord(">")) {
            advanceChar();
            return CatspeakToken.PIPE_RIGHT;
        }
    };

    /// Advances the lexer and returns the next `CatspeakToken`, ignoring any
    /// comments, whitespace, and line continuations.
    ///
    /// @remark
    ///   To get the string content of the token, you should use the
    ///   `getLexeme` method.
    ///
    /// @example
    ///   Iterates through all tokens of a buffer containing Catspeak code,
    ///   printing each token out as a debug message.
    ///
    ///   ```gml
    ///   var lexer = new CatspeakLexerV3(buff);
    ///   do {
    ///     var token = lexer.next();
    ///     show_debug_message(lexer.getLexeme());
    ///   } until (token == CatspeakToken.EOF);
    ///   ```
    ///
    /// @return {Enum.CatspeakToken}
    static next = function () {
        if (peeked != undefined) {
            var token = peeked;
            peeked = undefined;
            return token;
        }
        while (true) {
            var token = nextWithWhitespace();
            if (token == CatspeakToken.WHITESPACE
                    || token == CatspeakToken.COMMENT) {
                continue;
            }
            return token;
        }
    };

    /// Peeks at the next non-whitespace character without advancing the lexer.
    ///
    /// @example
    ///   Iterates through all tokens of a buffer containing Catspeak code,
    ///   printing each token out as a debug message.
    ///
    ///   ```gml
    ///   var lexer = new CatspeakLexerV3(buff);
    ///   while (lexer.peek() != CatspeakToken.EOF) {
    ///     lexer.next();
    ///     show_debug_message(lexer.getLexeme());
    ///   }
    ///   ```
    ///
    /// @return {Enum.CatspeakToken}
    static peek = function () {
        peeked ??= next();
        return peeked;
    };

    /// @ignore
    static __keywords = undefined;
    if (__keywords == undefined) {
        __keywords = { };
        __keywords[$ "self"] = CatspeakToken.SELF;
        __keywords[$ "other"] = CatspeakToken.OTHER;
        __keywords[$ "params"] = CatspeakToken.PARAMS;
        __keywords[$ "and"] = CatspeakToken.AND;
        __keywords[$ "or"] = CatspeakToken.OR;
        __keywords[$ "xor"] = CatspeakToken.XOR;
        __keywords[$ "do"] = CatspeakToken.DO;
        __keywords[$ "if"] = CatspeakToken.IF;
        __keywords[$ "else"] = CatspeakToken.ELSE;
        __keywords[$ "while"] = CatspeakToken.WHILE;
        __keywords[$ "for"] = CatspeakToken.FOR;
        __keywords[$ "loop"] = CatspeakToken.LOOP;
        __keywords[$ "with"] = CatspeakToken.WITH;
        __keywords[$ "match"] = CatspeakToken.MATCH;
        __keywords[$ "fun"] = CatspeakToken.FUN;
        __keywords[$ "impl"] = CatspeakToken.IMPL;
        __keywords[$ "catch"] = CatspeakToken.CATCH;
        __keywords[$ "return"] = CatspeakToken.RETURN;
        __keywords[$ "continue"] = CatspeakToken.CONTINUE;
        __keywords[$ "break"] = CatspeakToken.BREAK;
        __keywords[$ "throw"] = CatspeakToken.THROW;
        __keywords[$ "let"] = CatspeakToken.LET;
    }

    /// @ignore
    static __literals = undefined;
    if (__literals == undefined) {
        __literals = { };
        __literals[$ "true"] = true;
        __literals[$ "false"] = false;
        __literals[$ "NaN"] = NaN;
        __literals[$ "infinity"] = infinity;
    }

    /// @ignore
    static __escapes = undefined;
    if (__escapes == undefined) {
        __escapes = array_create(0xFF, undefined);
        __escapes[@ ord("t")] = "\t";
        __escapes[@ ord("n")] = "\n";
        __escapes[@ ord("v")] = "\v";
        __escapes[@ ord("f")] = "\f";
        __escapes[@ ord("r")] = "\r";
    }

    /// @ignore
    static __asciiCodepage = undefined;
    if (__asciiCodepage == undefined) {
        __asciiCodepage = array_create(0xFF, CatspeakToken.ERROR);
        for (var char_ = array_length(__asciiCodepage) - 1; char_ >= 0; char_ -= 1) {
            var charToken;
            if (__catspeak_char_is_whitespace(char_)) {
                charToken = CatspeakToken.WHITESPACE;
            } else if (
                __catspeak_char_is_alphanum(char_) ||
                char_ == ord("`") // raw identifiers
            ) {
                charToken = CatspeakToken.IDENT;
            } else if (
                char_ >= ord("0") && char_ <= ord("9") ||
                char_ == ord("'") || // character literals
                char_ == ord("#")    // colour literals
            ) {
                charToken = CatspeakToken.NUMBER;
            } else if (char_ == ord("\"") || char_ == ord("@")) {
                charToken = CatspeakToken.STRING;
            } else {
                continue;
            }
            __asciiCodepage[@ char_] = charToken;
        }
        __asciiCodepage[@ ord("(")] = CatspeakToken.PAREN_LEFT;
        __asciiCodepage[@ ord(")")] = CatspeakToken.PAREN_RIGHT;
        __asciiCodepage[@ ord("[")] = CatspeakToken.BOX_LEFT;
        __asciiCodepage[@ ord("]")] = CatspeakToken.BOX_RIGHT;
        __asciiCodepage[@ ord("{")] = CatspeakToken.BRACE_LEFT;
        __asciiCodepage[@ ord("}")] = CatspeakToken.BRACE_RIGHT;
        __asciiCodepage[@ ord(";")] = CatspeakToken.SEMICOLON;
        __asciiCodepage[@ ord(":")] = CatspeakToken.COLON;
        __asciiCodepage[@ ord(",")] = CatspeakToken.COMMA;
        __asciiCodepage[@ ord(".")] = CatspeakToken.DOT;
        __asciiCodepage[@ ord("=")] = CatspeakToken.ASSIGN;
        __asciiCodepage[@ ord("*")] = CatspeakToken.MULTIPLY;
        __asciiCodepage[@ ord("/")] = CatspeakToken.DIVIDE;
        __asciiCodepage[@ ord("%")] = CatspeakToken.REMAINDER;
        __asciiCodepage[@ ord("+")] = CatspeakToken.PLUS;
        __asciiCodepage[@ ord("-")] = CatspeakToken.SUBTRACT;
        __asciiCodepage[@ ord("!")] = CatspeakToken.NOT;
        __asciiCodepage[@ ord(">")] = CatspeakToken.GREATER;
        __asciiCodepage[@ ord("<")] = CatspeakToken.LESS;
        __asciiCodepage[@ ord("~")] = CatspeakToken.BITWISE_NOT;
        __asciiCodepage[@ ord("&")] = CatspeakToken.BITWISE_AND;
        __asciiCodepage[@ ord("^")] = CatspeakToken.BITWISE_XOR;
        __asciiCodepage[@ ord("|")] = CatspeakToken.BITWISE_OR;
    }

    /// @ignore
    static __lexerLookup = undefined;
    if (__lexerLookup == undefined) {
        __lexerLookup = array_create(CatspeakToken.__SIZE__, undefined);
        __lexerLookup[@ CatspeakToken.WHITESPACE] = __completeWhitespace;
        __lexerLookup[@ CatspeakToken.IDENT] = __completeIdent;
        __lexerLookup[@ CatspeakToken.NUMBER] = __completeNumber;
        __lexerLookup[@ CatspeakToken.STRING] = __completeString;
        __lexerLookup[@ CatspeakToken.COLON] = __completeColon;
        __lexerLookup[@ CatspeakToken.ASSIGN] = __completeAssign;
        __lexerLookup[@ CatspeakToken.MULTIPLY] = __completeMultiply;
        __lexerLookup[@ CatspeakToken.DIVIDE] = __completeDivide;
        __lexerLookup[@ CatspeakToken.PLUS] = __completePlus;
        __lexerLookup[@ CatspeakToken.SUBTRACT] = __completeSubtract;
        __lexerLookup[@ CatspeakToken.NOT] = __completeNot;
        __lexerLookup[@ CatspeakToken.GREATER] = __completeGreater;
        __lexerLookup[@ CatspeakToken.LESS] = __completeLess;
        __lexerLookup[@ CatspeakToken.BITWISE_OR] = __completeBitwiseOr;
    }
}

/// @ignore
function __catspeak_char_is_whitespace(char_) {
    gml_pragma("forceinline");
    return (
        // CHARACTER TABULATION ('\t') = 0x09
        // LINE FEED            ('\n') = 0x0A
        // LINE TABULATION      ('\v') = 0x0B
        // FORM FEED            ('\f') = 0x0C
        // CARRIAGE RETURN      ('\r') = 0x0D
        char_ >= 0x09 && char_ <= 0x0D ||
        char_ == 0x20 || // SPACE (' ')
        char_ == 0x85    // NEXT LINE
    );
}

/// @ignore
function __catspeak_char_is_alphanum(char_) {
    gml_pragma("forceinline");
    return (
        char_ >= ord("a") && char_ <= ord("z") ||
        char_ >= ord("Z") && char_ <= ord("Z") ||
        char_ == ord("_")
    );
}