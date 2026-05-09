//! "Meow" is the code name for the built-in Catspeak programming language,
//! loosely inspired by syntax from JavaScript, GML, and others.
//!
//! This module contains the lexer and parser for Catspeak, responsible for
//! converting source code from individual characters into clusters of
//! characters called[tokens](https://en.wikipedia.org/wiki/Lexical_analysis#Lexical_token_and_lexical_tokenization),
//! and then further into an executable Catspeak cartridge.
//!
//! @advanced

//# feather use syntax-errors

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
    MINUS,
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
    /// @experimental
    CASE,
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
    ASSIGN_MINUS,
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
/// @experimental
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
function CatspeakLexer(
    buff, offset = undefined, size = undefined
) : CatspeakUTF8Scanner(buff, offset, size) constructor {
    /// @ignore
    value = undefined;
    /// @ignore
    hasValue = false;
    /// @ignore
    peeked = undefined;

    /// Returns the actual value representation of the most recent token
    /// emitted by the `peek`, `next`, or `nextWithWhitespace` methods.
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
            if (!__catspeak_char_is_digit_hex(charNext)) {
                // colour literals must start with a digit
                return CatspeakToken.ERROR;
            }
            var digitStack = ds_stack_create();
            while (!isEndOfFile) {
                if (__catspeak_char_is_digit_hex(charNext)) {
                    ds_stack_push(digitStack, __catspeak_char_hex_to_dec(charNext));
                    advanceChar();
                } else if (charNext == ord("_")) {
                    advanceChar();
                } else {
                    break;
                }
            }
            if (charCurr == ord("_")) {
                // binary literals must not end with an underscore
                return CatspeakToken.ERROR;
            }
            var digitCount = ds_stack_size(digitStack);
            var cR = 0;
            var cG = 0;
            var cB = 0;
            var cA = 0;
            if (digitCount == 3) {
                // #RGB
                cB = ds_stack_pop(digitStack);
                cB = cB | (cB << 4);
                cG = ds_stack_pop(digitStack);
                cG = cG | (cG << 4);
                cR = ds_stack_pop(digitStack);
                cR = cR | (cR << 4);
            } else if (digitCount == 4) {
                // #RGBA
                cA = ds_stack_pop(digitStack);
                cA = cA | (cA << 4);
                cB = ds_stack_pop(digitStack);
                cB = cB | (cB << 4);
                cG = ds_stack_pop(digitStack);
                cG = cG | (cG << 4);
                cR = ds_stack_pop(digitStack);
                cR = cR | (cR << 4);
            } else if (digitCount == 6) {
                // #RRGGBB
                cB = ds_stack_pop(digitStack);
                cB = cB | (ds_stack_pop(digitStack) << 4);
                cG = ds_stack_pop(digitStack);
                cG = cG | (ds_stack_pop(digitStack) << 4);
                cR = ds_stack_pop(digitStack);
                cR = cR | (ds_stack_pop(digitStack) << 4);
            } else if (digitCount == 8) {
                // #RRGGBBAA
                cA = ds_stack_pop(digitStack);
                cA = cA | (ds_stack_pop(digitStack) << 4);
                cB = ds_stack_pop(digitStack);
                cB = cB | (ds_stack_pop(digitStack) << 4);
                cG = ds_stack_pop(digitStack);
                cG = cG | (ds_stack_pop(digitStack) << 4);
                cR = ds_stack_pop(digitStack);
                cR = cR | (ds_stack_pop(digitStack) << 4);
            } else {
                // invalid format
                return CatspeakToken.ERROR;
            }
            ds_stack_destroy(digitStack);
            value = cR | (cG << 8) | (cB << 16) | (cA << 24);
            hasValue = true;
        } else if (
            charCurr_ == ord("0") &&
            (charNext_ == ord("b") || charNext_ == ord("B"))
        ) {
            // binary literals
            advanceChar();
            if (!__catspeak_char_is_digit_binary(charNext)) {
                // binary literals must start with a digit
                return CatspeakToken.ERROR;
            }
            var digitStack = ds_stack_create();
            while (!isEndOfFile) {
                if (__catspeak_char_is_digit_binary(charNext)) {
                    ds_stack_push(digitStack, __catspeak_char_binary_to_dec(charNext));
                    advanceChar();
                } else if (charNext == ord("_")) {
                    advanceChar();
                } else {
                    break;
                }
            }
            if (charCurr == ord("_")) {
                // binary literals must not end with an underscore
                return CatspeakToken.ERROR;
            }
            value = 0;
            var pow = 0;
            while (!ds_stack_empty(digitStack)) {
                value += power(2, pow) * ds_stack_pop(digitStack);
                pow += 1;
            }
            ds_stack_destroy(digitStack);
            hasValue = true;
        } else if (
            charCurr_ == ord("0") &&
            (charNext_ == ord("x") || charNext_ == ord("X"))
        ) {
            // hex literals
            // TODO :: some way to avoid code duplication between all these digit parsers
            advanceChar();
            if (!__catspeak_char_is_digit_hex(charNext)) {
                // binary literals must start with a digit
                return CatspeakToken.ERROR;
            }
            var digitStack = ds_stack_create();
            while (!isEndOfFile) {
                if (__catspeak_char_is_digit_hex(charNext)) {
                    ds_stack_push(digitStack, __catspeak_char_hex_to_dec(charNext));
                    advanceChar();
                } else if (charNext == ord("_")) {
                    advanceChar();
                } else {
                    break;
                }
            }
            if (charCurr == ord("_")) {
                // binary literals must not end with an underscore
                return CatspeakToken.ERROR;
            }
            value = 0;
            var pow = 0;
            while (!ds_stack_empty(digitStack)) {
                value += power(16, pow) * ds_stack_pop(digitStack);
                pow += 1;
            }
            ds_stack_destroy(digitStack);
            hasValue = true;
        } else {
            // plain ol' numbers
            var digits = "";
            var lexemeOffset = 0;
            var hasDecimal = false;
            while (!isEndOfFile) {
                if (__catspeak_char_is_digit(charNext)) {
                    advanceChar();
                } else if (charNext == ord("_")) {
                    if (charCurr == ord(".")) {
                        // literals must not have an underscore besides a decimal points
                        return CatspeakToken.ERROR;
                    }
                    digits += getLexeme(lexemeOffset);
                    lexemeOffset = advanceChar();
                } else if (!hasDecimal && charNext == ord(".")) {
                    if (charCurr == ord("_")) {
                        // literals must not have an underscore besides a decimal points
                        return CatspeakToken.ERROR;
                    }
                    advanceChar();
                    hasDecimal = true;
                    if (!__catspeak_char_is_digit(charNext)) {
                        return CatspeakToken.ERROR;
                    }
                } else {
                    break;
                }
            }
            if (charCurr == ord("_")) {
                // literals must not end with an underscore
                return CatspeakToken.ERROR;
            }
            digits += getLexeme(lexemeOffset);
            value = real(digits);
            hasValue = true;
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
    static __completeMinus = function () {
        var charNext_ = charNext;
        if (charNext_ == ord("=")) {
            advanceChar();
            return CatspeakToken.ASSIGN_MINUS;
        } else if (charNext_ == ord("-")) {
            // comments
            do {
                advanceChar();
            } until (
                isEndOfFile ||
                charNext == ord("\n") ||
                charNext == ord("\r")
            );
            return CatspeakToken.COMMENT;
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
        __keywords[$ "case"] = CatspeakToken.CASE;
        __keywords[$ "fun"] = CatspeakToken.FUN;
        __keywords[$ "new"] = CatspeakToken.NEW;
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
                __catspeak_char_is_alpha(char_) ||
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
        __asciiCodepage[@ ord("-")] = CatspeakToken.MINUS;
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
        __lexerLookup[@ CatspeakToken.MINUS] = __completeMinus;
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
function __catspeak_char_is_alpha(char_) {
    gml_pragma("forceinline");
    return (
        char_ >= ord("a") && char_ <= ord("z") ||
        char_ >= ord("A") && char_ <= ord("Z") ||
        char_ == ord("_")
    );
}

/// @ignore
function __catspeak_char_is_alphanum(char_) {
    gml_pragma("forceinline");
    return (
        __catspeak_char_is_alpha(char_) ||
        __catspeak_char_is_digit(char_)
    );
}

/// @ignore
function __catspeak_char_is_digit(char_) {
    gml_pragma("forceinline");
    return char_ >= ord("0") && char_ <= ord("9");
}

/// @ignore
function __catspeak_char_is_digit_binary(char_) {
    gml_pragma("forceinline");
    return char_ == ord("0") || char_ == ord("1");
}

/// @ignore
function __catspeak_char_binary_to_dec(char_) {
    gml_pragma("forceinline");
    return char_ == ord("0") ? 0 : 1;
}

/// @ignore
function __catspeak_char_is_digit_hex(char_) {
    gml_pragma("forceinline");
    return char_ >= ord("a") && char_ <= ord("f") ||
            char_ >= ord("A") && char_ <= ord("F") ||
            char_ >= ord("0") && char_ <= ord("9");
}

/// @ignore
function __catspeak_char_hex_to_dec(char_) {
    if (char_ >= ord("0") && char_ <= ord("9")) {
        return char_ - ord("0");
    }
    if (char_ >= ord("a") && char_ <= ord("f")) {
        return char_ - ord("a") + 10;
    }
    return char_ - ord("A") + 10;
}

/// Consumes tokens produced by a `CatspeakLexer`, transforming the program
/// they represent into a Catspeak cartridge. This cartridge can be further
/// compiled into a callable GML function using a combination of
/// `CatspeakCartReader` and `CatspeakGenGML`. (Though, it's probably best
/// if you stick to using the stable `CatspeakCtx` API!)
///
/// @experimental
///
/// @param {Struct.CatspeakCartWriter} cartWriter
///   The writer for the cartridge to emit.
///
/// @param {Struct.CatspeakLexer} lexer_
///   The lexer to consume tokens from.
function CatspeakParser(cartWriter, lexer_) constructor {
    __catspeak_assert_instanceof(cartWriter, CatspeakCartWriter, "invalid cart writer");
    __catspeak_assert_instanceof(lexer_, CatspeakLexer, "invalid lexer");

    /// @ignore
    ir = cartWriter;
    /// @ignore
    lexer = lexer_;
    /// @ignore
    funcs = array_create(4, undefined);
    /// @ignore
    funcTop = -1;
    /// @ignore
    isAlive = true;
    __pushFunc();

    /// @ignore
    static __pushFunc = function () {
        ir.pushFunction();
        funcTop += 1;
        funcs[@ funcTop] = {
            blocks : array_create(8, undefined),
            blockTop : -1,
            unwindDepth : 0,
        };
        __pushBlock();
    };

    /// @ignore
    static __popFunc = function (argc = 0) {
        __popBlock();
        ir.emitUnwindLanding(__getLabelReturn());
        funcs[@ funcTop] = undefined;
        funcTop -= 1;
        return ir.popFunction(argc);
    };

    /// @ignore
    static __pushBlock = function () {
        var func = funcs[funcTop];
        func.blockTop += 1;
        func.blocks[@ func.blockTop] = {
            vars : { },
            // used to track the number of statements to pop in `__popBlock`
            stackSize : ir.getStackSize(),
        };
    };

    /// @ignore
    static __popBlock = function () {
        var func = funcs[funcTop];
        var exprCount = ir.getStackSize() - func.blocks[func.blockTop].stackSize;
        func.blocks[@ func.blockTop] = undefined;
        func.blockTop -= 1;
        if (exprCount != 1) {
            ir.emitSequence(exprCount);
        }
    };

    /// @ignore
    static __allocLocal = function (name) {
        var func = funcs[funcTop];
        var block = func.blocks[func.blockTop];
        var idx = ir.getFreshVar();
        block.vars[$ name] = idx;
        return idx;
    };

    /// @ignore
    static __findLocal = function (name) {
        var func = funcs[funcTop];
        for (var i = func.blockTop; i >= 0; i -= 1) {
            var block = func.blocks[i];
            var idx = block.vars[$ name];
            if (idx != undefined) {
                return idx;
            }
        }
        return undefined;
    };

    /// @ignore
    static __getLabelReturn = function () { return 0 };

    /// @ignore
    static __getLabelContinue = function () { return 1 };

    /// @ignore
    static __getLabelBreak = function () { return 2 };

    /// @ignore
    static __err = function (msg = "no message") {
        var token = lexer.next();
        var tokenStr;
        if (token == CatspeakToken.EOF) {
            tokenStr = "end of file";
        } else if (token == CatspeakToken.SEMICOLON) {
            tokenStr = "line break ';'";
        } else {
            tokenStr = "token '" + lexer.getLexeme() + "' (" + string(token) + ")";
        }
        __catspeak_error(msg + ", got " + tokenStr);
    };

    /// @ignore
    static __expect = function (expect, msg = "no message") {
        if (expect == lexer.peek()) {
            return lexer.next();
        }
        __err(msg);
    };

    /// Parses single a top-level statement, adding any relevant parse
    /// information to the cartridge.
    ///
    /// @example
    ///   Creates a new `CatspeakParser` from a cart writer `writer`, and
    ///   parses a `lexer` to completion.
    ///
    ///   ```gml
    ///   var parser = new CatspeakParser(writer, lexer);
    ///   do {
    ///     var keepParsing = parser.parseOnce() == undefined;
    ///   } until (!keepParsing);
    ///   ```
    ///
    /// @return {Real}
    ///   `undefined` if there is still more data left to parse, or a number
    ///   representing the compiled function, if the parser has reached the
    ///   end of the file.
    static parseOnce = function () {
        __catspeak_assert(isAlive, "parser has expired");
        if (lexer.peek() == CatspeakToken.EOF) {
            return __popFunc();
        }
        try {
            __parseStatement();
        } catch (ex) {
            catspeak_location_trace(ex, lexer.getLocationStart(), ir.path);
            throw ex;
        }
        return undefined;
    };

    /// @ignore
    static __parseStatement = function () {
        var peeked = lexer.peek();
        if (peeked == CatspeakToken.SEMICOLON) {
            lexer.next();
            return;
        } else if (peeked == CatspeakToken.LET) {
            lexer.next();
            __expect(CatspeakToken.IDENT, "expected identifier after 'let' keyword");
            var idx = __allocLocal(lexer.getValue());
            var dbg = undefined;
            if (lexer.peek() == CatspeakToken.ASSIGN) {
                lexer.next();
                dbg = lexer.getLocationStart();
                __parseExpression();
            } else {
                ir.emitConstUndefined();
            }
            ir.emitSetLocal(ord("="), idx, dbg);
        } else {
            __parseExpression();
        }
    };

    /// @ignore
    static __parseStatements = function (keyword) {
        if (lexer.peek() != CatspeakToken.BRACE_LEFT) {
            __err(__catspeak_cat(
                "expected opening '{' at the start of '", keyword, "' block"
            ));
        }
        lexer.next();
        var peeked = lexer.peek();
        while (peeked != CatspeakToken.BRACE_RIGHT && peeked != CatspeakToken.EOF) {
            __parseStatement();
            peeked = lexer.peek();
        }
        if (lexer.peek() != CatspeakToken.BRACE_RIGHT) {
            __err(__catspeak_cat(
                "expected closing '}' after '", keyword, "' block"
            ));
        }
        lexer.next();
    };

    /// @ignore
    static __parseExpression = function () {
        var peeked = lexer.peek();
        if (
            peeked > CatspeakToken.__EXPR_BEGIN__ &&
            peeked < CatspeakToken.__EXPR_END__
        ) {
            var dbg = lexer.getLocationStart();
            lexer.next();
            if (peeked == CatspeakToken.RETURN) {
                peeked = lexer.peek();
                if (
                    peeked == CatspeakToken.SEMICOLON ||
                    peeked == CatspeakToken.BRACE_RIGHT ||
                    peeked == CatspeakToken.LET
                ) {
                    ir.emitConstUndefined();
                } else {
                    __parseExpression();
                }
                ir.emitUnwind(__getLabelReturn(), dbg);
            } else if (peeked == CatspeakToken.CONTINUE) {
                __catspeak_error_unimplemented("continue");
                ir.emitConstUndefined();
                ir.emitUnwind(__getLabelContinue(), dbg);
            } else if (peeked == CatspeakToken.BREAK) {
                peeked = lexer.peek();
                if (
                    peeked == CatspeakToken.SEMICOLON ||
                    peeked == CatspeakToken.BRACE_RIGHT ||
                    peeked == CatspeakToken.LET
                ) {
                    ir.emitConstUndefined();
                } else {
                    __parseExpression();
                }
                ir.emitUnwind(__getLabelBreak(), dbg);
            } else if (peeked == CatspeakToken.THROW) {
                __parseExpression();
                ir.emitThrow(dbg);
            } else {
                __catspeak_error_bug();
            }
        } else {
            __parseCatch();
        }
    };

    /// @ignore
    static __parseCatch = function () {
        __parseExpressionBlock();
        if (lexer.peek() == CatspeakToken.CATCH) {
            var dbg = lexer.getLocationStart();
            lexer.next();
            var idx;
            if (lexer.peek() == CatspeakToken.IDENT) {
                lexer.next();
                var name = lexer.getValue();
                idx = __findLocal(name);
            } else {
                idx = ir.getFreshVar();
            }
            __pushBlock();
            __parseStatements("catch");
            __popBlock();
            ir.emitCatch(idx, dbg);
        }
    };

    /// @ignore
    static __parseExpressionBlock = function () {
        var peeked = lexer.peek();
        if (
            peeked > CatspeakToken.__BLOCKEXPR_BEGIN__ &&
            peeked < CatspeakToken.__BLOCKEXPR_END__
        ) {
            var dbg = lexer.getLocationStart();
            lexer.next();
            if (peeked == CatspeakToken.DO) {
                __pushBlock();
                __parseStatements("do");
                __popBlock();
            } else if (peeked == CatspeakToken.IF) {
                __parseCondition();
                __pushBlock();
                __parseStatements("if");
                __popBlock();
                if (lexer.peek() == CatspeakToken.ELSE) {
                    lexer.next();
                    if (lexer.peek() == CatspeakToken.IF) {
                        // for `else if` support
                        __parseExpressionBlock();
                    } else {
                        __pushBlock();
                        __parseStatements("else");
                        __popBlock();
                    }
                } else {
                    ir.emitConstUndefined();
                }
                ir.emitIfThenElse(dbg);
            } else if (peeked == CatspeakToken.WHILE) {
                __parseExpression();
                __pushBlock();
                __parseStatements("while");
                __popBlock();
                ir.emitUnwindLanding(__getLabelContinue());
                ir.emitLoop(dbg);
                ir.emitUnwindLanding(__getLabelBreak());
            } else if (peeked == CatspeakToken.FOR) {
                __catspeak_error_unimplemented("for loops");
            } else if (peeked == CatspeakToken.LOOP) {
                __pushBlock();
                __parseStatements("loop");
                __popBlock();
                ir.emitUnwindLanding(__getLabelContinue());
                ir.emitLoopInf(dbg);
                ir.emitUnwindLanding(__getLabelBreak());
            } else if (peeked == CatspeakToken.WITH) {
                __parseExpression();
                __pushBlock();
                __parseStatements("with");
                __popBlock();
                ir.emitUnwindLanding(__getLabelContinue());
                ir.emitLoopWith(dbg);
                ir.emitUnwindLanding(__getLabelBreak());
            } else if (peeked == CatspeakToken.MATCH) {
                __pushBlock();
                __parseCondition();
                var caseVar = ir.getFreshVar(dbg);
                ir.emitSetLocal(ord("="), caseVar, dbg);
                if (lexer.peek() != CatspeakToken.BRACE_LEFT) {
                    __err(__catspeak_cat(
                        "expected opening '{' at the start of 'match' block"
                    ));
                }
                lexer.next();
                var seenCases = 0;
                var peeked = lexer.peek();
                while (peeked != CatspeakToken.BRACE_RIGHT && peeked != CatspeakToken.EOF) {
                    lexer.next();
                    seenCases += 1;
                    if (peeked == CatspeakToken.CASE) {
                        __parseCondition();
                        ir.emitGetLocal(caseVar);
                        ir.emitEqual();
                        __parseStatements("case");
                    } else if (peeked == CatspeakToken.ELSE) {
                        ir.emitConstNumber(true);
                        __parseStatements("else");
                    } else {
                        __err(__catspeak_cat(
                            "expected either 'case' or 'else' in 'match' block"
                        ));
                    }
                    peeked = lexer.peek();
                }
                __expect(CatspeakToken.BRACE_RIGHT, "expected closing '}' after 'match' block");
                lexer.next();
                ir.emitConstUndefined();
                repeat (seenCases) {
                    ir.emitIfThenElse();
                }
                __popBlock();
            } else if (peeked == CatspeakToken.FUN) {
                __pushFunc();
                var argc = 0;
                if (lexer.peek() != CatspeakToken.BRACE_LEFT) {
                    __expect(CatspeakToken.PAREN_LEFT, "expected opening '(' after 'fun' keyword");
                    var peeked = lexer.peek();
                    var expectIdent = true;
                    while (expectIdent && peeked != CatspeakToken.PAREN_RIGHT) {
                        // parse args
                        __expect(CatspeakToken.IDENT, "expected identifier");
                        __allocLocal(lexer.getValue());
                        argc += 1;
                        peeked = lexer.peek();
                        expectIdent = peeked == CatspeakToken.COMMA;
                        if (expectIdent) {
                            lexer.next();
                            peeked = lexer.peek();
                        }
                    }
                    __expect(CatspeakToken.PAREN_RIGHT, "expected closing ')' after function arguments");
                }
                __parseStatements("fun");
                ir.emitClosure(__popFunc(argc), dbg);
            } else if (peeked == CatspeakToken.IMPL) {
                __catspeak_error_unimplemented("impl blocks");
            } else {
                __catspeak_error_bug();
            }
        } else {
            __parseCondition();
        }
    };
    
    /// @ignore
    static __parseCondition = function () {
        __parseOpLogicalOR();
    };

    /// @ignore
    static __parseOpLogicalOR = function () {
        __parseOpLogicalAND();
        while (true) {
            var peeked = lexer.peek();
            if (
                peeked > CatspeakToken.__OP_OR_BEGIN__ &&
                peeked < CatspeakToken.__OP_OR_END__
            ) {
                var dbg = lexer.getLocationStart();
                lexer.next();
                __parseOpLogicalAND();
                if (peeked == CatspeakToken.OR) {
                    ir.emitOr(dbg);
                } else if (peeked == CatspeakToken.XOR) {
                    ir.emitXor(dbg);
                } else {
                    __catspeak_error_bug();
                }
            } else {
                break;
            }
        }
    };

    /// @ignore
    static __parseOpLogicalAND = function () {
        __parseOpPipe();
        while (true) {
            var peeked = lexer.peek();
            if (peeked == CatspeakToken.AND) {
                var dbg = lexer.getLocationStart();
                lexer.next();
                __parseOpPipe();
                ir.emitAnd(dbg);
            } else {
                break;
            }
        }
    };

    /// @ignore
    static __parseOpPipe = function () {
        __parseOpEquality();
        while (true) {
            var peeked = lexer.peek();
            if (
                peeked > CatspeakToken.__OP_PIPE_BEGIN__ &&
                peeked < CatspeakToken.__OP_PIPE_END__
            ) {
                var dbg = lexer.getLocationStart();
                lexer.next();
                if (peeked == CatspeakToken.PIPE_LEFT) {
                    __parseOpEquality();
                    ir.emitCall(1, dbg);
                } else if (peeked == CatspeakToken.PIPE_RIGHT) {
                    __pushBlock();
                    var temp = ir.getFreshVar(dbg);
                    ir.emitSetLocal(ord("="), temp, dbg);
                    __parseOpEquality();
                    ir.emitGetLocal(temp, dbg);
                    ir.emitCall(1, dbg);
                    __popBlock();
                } else {
                    __catspeak_error_bug();
                }
                
            } else {
                break;
            }
        }
    };

    /// @ignore
    static __parseOpEquality = function () {
        __parseOpRelational();
        while (true) {
            var peeked = lexer.peek();
            if (
                peeked > CatspeakToken.__OP_EQUAL_BEGIN__ &&
                peeked < CatspeakToken.__OP_EQUAL_END__
            ) {
                var dbg = lexer.getLocationStart();
                lexer.next();
                __parseOpRelational();
                if (peeked == CatspeakToken.EQUAL) {
                    ir.emitEqual(dbg);
                } else if (peeked == CatspeakToken.NOT_EQUAL) {
                    ir.emitNotEqual(dbg);
                } else {
                    __catspeak_error_bug();
                }
            } else {
                break;
            }
        }
    };

    /// @ignore
    static __parseOpRelational = function () {
        __parseOpBitwise();
        while (true) {
            var peeked = lexer.peek();
            if (
                peeked > CatspeakToken.__OP_RELATE_BEGIN__ &&
                peeked < CatspeakToken.__OP_RELATE_END__
            ) {
                var dbg = lexer.getLocationStart();
                lexer.next();
                __parseOpBitwise();
                if (peeked == CatspeakToken.LESS) {
                    ir.emitLessThan(dbg);
                } else if (peeked == CatspeakToken.LESS_EQUAL) {
                    ir.emitLessThanOrEqualTo(dbg);
                } else if (peeked == CatspeakToken.GREATER) {
                    ir.emitGreaterThan(dbg);
                } else if (peeked == CatspeakToken.GREATER_EQUAL) {
                    ir.emitGreaterThanOrEqualTo(dbg);
                } else {
                    __catspeak_error_bug();
                }
            } else {
                break;
            }
        }
    };

    /// @ignore
    static __parseOpBitwise = function () {
        __parseOpAdd();
        while (true) {
            var peeked = lexer.peek();
            if (
                peeked > CatspeakToken.__OP_BITWISE_BEGIN__ &&
                peeked < CatspeakToken.__OP_BITWISE_END__
            ) {
                var dbg = lexer.getLocationStart();
                lexer.next();
                __parseOpAdd();
                if (peeked == CatspeakToken.AND) {
                    ir.emitBitwiseAnd(dbg);
                } else if (peeked == CatspeakToken.OR) {
                    ir.emitBitwiseOr(dbg);
                } else if (peeked == CatspeakToken.XOR) {
                    ir.emitBitwiseXor(dbg);
                } else if (peeked == CatspeakToken.SHIFT_LEFT) {
                    ir.emitBitwiseShiftLeft(dbg);
                } else if (peeked == CatspeakToken.SHIFT_RIGHT) {
                    ir.emitBitwiseShiftRight(dbg);
                } else {
                    __catspeak_error_bug();
                }
            } else {
                break;
            }
        }
    };

    /// @ignore
    static __parseOpAdd = function () {
        __parseOpMultiply();
        while (true) {
            var peeked = lexer.peek();
            if (
                peeked > CatspeakToken.__OP_ADD_BEGIN__ &&
                peeked < CatspeakToken.__OP_ADD_END__
            ) {
                var dbg = lexer.getLocationStart();
                lexer.next();
                __parseOpMultiply();
                if (peeked == CatspeakToken.PLUS) {
                    ir.emitAdd(dbg);
                } else if (peeked == CatspeakToken.MINUS) {
                    ir.emitSubtract(dbg);
                } else {
                    __catspeak_error_bug();
                }
            } else {
                break;
            }
        }
    };

    /// @ignore
    static __parseOpMultiply = function () {
        __parseOpUnary();
        while (true) {
            var peeked = lexer.peek();
            if (
                peeked > CatspeakToken.__OP_MULT_BEGIN__ &&
                peeked < CatspeakToken.__OP_MULT_END__
            ) {
                var dbg = lexer.getLocationStart();
                lexer.next();
                __parseOpUnary();
                if (peeked == CatspeakToken.MULTIPLY) {
                    ir.emitMultiply(dbg);
                } else if (peeked == CatspeakToken.DIVIDE) {
                    ir.emitDivide(dbg);
                } else if (peeked == CatspeakToken.DIVIDE_INT) {
                    ir.emitDivideInt(dbg);
                } else if (peeked == CatspeakToken.REMAINDER) {
                    ir.emitRemainder(dbg);
                } else {
                    __catspeak_error_bug();
                }
            } else {
                break;
            }
        }
    };

    /// @ignore
    static __parseOpUnary = function () {
        var peeked = lexer.peek();
        if (
            peeked > CatspeakToken.__OP_UNARY_BEGIN__ &&
            peeked < CatspeakToken.__OP_UNARY_END__
        ) {
            var dbg = lexer.getLocationStart();
            lexer.next();
            __parseIndex();
            if (peeked == CatspeakToken.PLUS) {
                ir.emitPositive(dbg);
            } else if (peeked == CatspeakToken.MINUS) {
                ir.emitNegative(dbg);
            } else if (peeked == CatspeakToken.NOT) {
                ir.emitNot(dbg);
            } else if (peeked == CatspeakToken.BITWISE_NOT) {
                ir.emitBitwiseNot(dbg);
            } else {
                __catspeak_error_bug();
            }
        } else {
            __parseIndex();
        }
    };

    /// @ignore
    static __parseIndex = function () {
        __parsePrimary();
        while (true) {
            var peeked = lexer.peek();
            if (peeked == CatspeakToken.PAREN_LEFT) {
                var dbg = lexer.getLocationStart();
                lexer.next();
                var n = 0;
                peeked = lexer.peek();
                var expectExpr = true;
                while (expectExpr && peeked != CatspeakToken.PAREN_RIGHT) {
                    __parseExpression();
                    n += 1;
                    peeked = lexer.peek();
                    expectExpr = peeked == CatspeakToken.COMMA;
                    if (expectExpr) {
                        lexer.next();
                        peeked = lexer.peek();
                    }
                }
                __expect(CatspeakToken.PAREN_RIGHT, "expected closing ')' after call expression");
                ir.emitCall(n, dbg);
            } else if (peeked == CatspeakToken.BOX_LEFT || peeked == CatspeakToken.DOT) {
                var dbg = lexer.getLocationStart();
                lexer.next();
                if (peeked == CatspeakToken.BOX_LEFT) {
                    __parseExpression();
                    __expect(CatspeakToken.BOX_RIGHT, "expected closing ']' after index expression");
                } else {
                    __expect(CatspeakToken.IDENT, "expected identifier after '.' index expression");
                    ir.emitConstString(lexer.getValue());
                }
                var op = __parseAssignOp();
                if (op == undefined) {
                    // get
                    ir.emitGetIndex(dbg);
                } else {
                    // set
                    __parseExpression();
                    ir.emitSetIndex(op, dbg);
                }
            } else {
                break;
            }
        }
    };

    /// @ignore
    static __parsePrimary = function () {
        var peeked = lexer.peek();
        var dbg = lexer.getLocationStart();
        if (peeked == CatspeakToken.NUMBER) {
            lexer.next();
            ir.emitConstNumber(lexer.getValue(), dbg);
        } else if (peeked == CatspeakToken.STRING) {
            lexer.next();
            ir.emitConstString(lexer.getValue(), dbg);
        } else if (peeked == CatspeakToken.UNDEFINED) {
            lexer.next();
            ir.emitConstUndefined(dbg);
        } else if (peeked == CatspeakToken.IDENT) {
            lexer.next();
            var name = lexer.getValue();
            var idx = __findLocal(name);
            var op = __parseAssignOp();
            if (op == undefined) {
                // get
                if (idx == undefined) {
                    ir.emitGlobal();
                    ir.emitGetIndexString(name, dbg);
                } else {
                    ir.emitGetLocal(idx, dbg);
                }
            } else {
                // set
                if (idx == undefined) {
                    ir.emitGlobal();
                    __parseExpression();
                    ir.emitSetIndexString(op, name, dbg);
                } else {
                    __parseExpression();
                    ir.emitSetLocal(op, idx, dbg);
                }
            }
        } else if (peeked == CatspeakToken.SELF) {
            lexer.next();
            ir.emitSelf();
        } else if (peeked == CatspeakToken.OTHER) {
            lexer.next();
            ir.emitOther();
        } else if (peeked == CatspeakToken.PAREN_LEFT) {
            lexer.next();
            __parseExpression();
            __expect(CatspeakToken.PAREN_RIGHT, "expected closing ')' after group expression");
        } else if (peeked == CatspeakToken.BOX_LEFT) {
            lexer.next();
            var n = 0;
            peeked = lexer.peek();
            var expectExpr = true;
            while (expectExpr && peeked != CatspeakToken.BOX_RIGHT) {
                __parseExpression();
                n += 1;
                peeked = lexer.peek();
                expectExpr = peeked == CatspeakToken.COMMA;
                if (expectExpr) {
                    lexer.next();
                    peeked = lexer.peek();
                }
            }
            __expect(CatspeakToken.BOX_RIGHT, "expected closing ']' after array literal");
            ir.emitArray(n, dbg);
        } else if (peeked == CatspeakToken.BRACE_LEFT) {
            lexer.next();
            var n = 0;
            peeked = lexer.peek();
            var expectExpr = true;
            while (expectExpr && peeked != CatspeakToken.BRACE_RIGHT) {
                // struct keys
                var key = lexer.peek();
                var keyDbg = lexer.getLocationStart();
                var keyValue = undefined;
                if (key == CatspeakToken.BOX_LEFT) {
                    lexer.next();
                    __parseExpression();
                    __expect(CatspeakToken.BOX_RIGHT, "expected closing ']' after computed struct key");
                } else if (
                    key == CatspeakToken.IDENT ||
                    key == CatspeakToken.STRING ||
                    key == CatspeakToken.NUMBER ||
                    key == CatspeakToken.UNDEFINED
                ) {
                    lexer.next();
                    keyValue = lexer.getValue();
                    ir.emitConstString(keyValue, keyDbg);
                } else {
                    __err("expected identifier or value as struct key");
                }
                // struct values
                if (lexer.peek() == CatspeakToken.COLON) {
                    lexer.next();
                    __parseExpression();
                } else if (key == CatspeakToken.IDENT) {
                    var idx = __findLocal(keyValue);
                    if (idx != undefined) {
                        ir.emitGetLocal(idx, keyDbg);
                    } else {
                        ir.emitGlobal();
                        ir.emitGetIndexString(keyValue, keyDbg);
                    }
                } else {
                    __err("expected ':' between key and value of struct literal");
                }
                n += 2;
                peeked = lexer.peek();
                expectExpr = peeked == CatspeakToken.COMMA;
                if (expectExpr) {
                    lexer.next();
                    peeked = lexer.peek();
                }
            }
            __expect(CatspeakToken.BRACE_RIGHT, "expected closing '}' after struct literal");
            ir.emitStruct(n, dbg);
        } else {
            __err("unexpected end of expression, expected one of: '(', '[' or '{'");
        }
    };

    /// @ignore
    static __parseAssignOp = function () {
        var peeked = lexer.peek();
        if (
            peeked > CatspeakToken.__OP_ASSIGN_BEGIN__ &&
            peeked < CatspeakToken.__OP_ASSIGN_END__
        ) {
            lexer.next();
            if (peeked == CatspeakToken.ASSIGN) {
                return ord("=");
            } else if (peeked == CatspeakToken.ASSIGN_MULTIPLY) {
                return ord("*");
            } else if (peeked == CatspeakToken.ASSIGN_DIVIDE) {
                return ord("/");
            } else if (peeked == CatspeakToken.ASSIGN_PLUS) {
                return ord("+");
            } else if (peeked == CatspeakToken.ASSIGN_MINUS) {
                return ord("-");
            } else {
                __catspeak_error_bug();
            }
        }
        return undefined;
    };
}