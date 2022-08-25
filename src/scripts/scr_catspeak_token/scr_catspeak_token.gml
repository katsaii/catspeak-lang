//! Boilerplate for the `CatspeakToken` enum.

//# feather use syntax-errors

/// Represents a kind of Catspeak token.
enum CatspeakToken {
    PAREN_LEFT,
    PAREN_RIGHT,
    BOX_LEFT,
    BOX_RIGHT,
    BRACE_LEFT,
    BRACE_RIGHT,
    DOT,
    COLON,
    COMMA,
    ASSIGN,
    IF,
    ELSE,
    WHILE,
    FOR,
    LET,
    FUN,
    BREAK,
    CONTINUE,
    RETURN,
    IDENT,
    STRING,
    FLOAT,
    INT,
    INT_HEX,
    INT_BIN,
    WHITESPACE,
    COMMENT,
    EOL,
    BOF,
    EOF,
    OTHER,
    __OPERATORS_BEGIN__,
    DISJUNCTION,
    CONJUNCTION,
    COMPARISON,
    ADDITION,
    MULTIPLICATION,
    DIVISION,
    __OPERATORS_END__,
}

/// Gets the name for a value of `CatspeakToken`.
/// Will return `<unknown>` if the value is unexpected.
///
/// @param {Enum.CatspeakToken} value
///   The value of `CatspeakToken` to convert.
///
/// @return {String}
function catspeak_token_show(value) {
    switch (value) {
    case CatspeakToken.PAREN_LEFT:
        return "PAREN_LEFT";
    case CatspeakToken.PAREN_RIGHT:
        return "PAREN_RIGHT";
    case CatspeakToken.BOX_LEFT:
        return "BOX_LEFT";
    case CatspeakToken.BOX_RIGHT:
        return "BOX_RIGHT";
    case CatspeakToken.BRACE_LEFT:
        return "BRACE_LEFT";
    case CatspeakToken.BRACE_RIGHT:
        return "BRACE_RIGHT";
    case CatspeakToken.DOT:
        return "DOT";
    case CatspeakToken.COLON:
        return "COLON";
    case CatspeakToken.COMMA:
        return "COMMA";
    case CatspeakToken.ASSIGN:
        return "ASSIGN";
    case CatspeakToken.IF:
        return "IF";
    case CatspeakToken.ELSE:
        return "ELSE";
    case CatspeakToken.WHILE:
        return "WHILE";
    case CatspeakToken.FOR:
        return "FOR";
    case CatspeakToken.LET:
        return "LET";
    case CatspeakToken.FUN:
        return "FUN";
    case CatspeakToken.BREAK:
        return "BREAK";
    case CatspeakToken.CONTINUE:
        return "CONTINUE";
    case CatspeakToken.RETURN:
        return "RETURN";
    case CatspeakToken.IDENT:
        return "IDENT";
    case CatspeakToken.STRING:
        return "STRING";
    case CatspeakToken.FLOAT:
        return "FLOAT";
    case CatspeakToken.INT:
        return "INT";
    case CatspeakToken.INT_HEX:
        return "INT_HEX";
    case CatspeakToken.INT_BIN:
        return "INT_BIN";
    case CatspeakToken.WHITESPACE:
        return "WHITESPACE";
    case CatspeakToken.COMMENT:
        return "COMMENT";
    case CatspeakToken.EOL:
        return "EOL";
    case CatspeakToken.BOF:
        return "BOF";
    case CatspeakToken.EOF:
        return "EOF";
    case CatspeakToken.OTHER:
        return "OTHER";
    case CatspeakToken.DISJUNCTION:
        return "DISJUNCTION";
    case CatspeakToken.CONJUNCTION:
        return "CONJUNCTION";
    case CatspeakToken.COMPARISON:
        return "COMPARISON";
    case CatspeakToken.ADDITION:
        return "ADDITION";
    case CatspeakToken.MULTIPLICATION:
        return "MULTIPLICATION";
    case CatspeakToken.DIVISION:
        return "DIVISION";
    }
    return "<unknown>";
}

/// Parses a string into a value of `CatspeakToken`.
/// Will return `undefined` if the value cannot be parsed.
///
/// @param {Any} str
///   The string to parse.
///
/// @return {Enum.CatspeakToken}
function catspeak_token_read(str) {
    switch (str) {
    case "PAREN_LEFT":
        return CatspeakToken.PAREN_LEFT;
    case "PAREN_RIGHT":
        return CatspeakToken.PAREN_RIGHT;
    case "BOX_LEFT":
        return CatspeakToken.BOX_LEFT;
    case "BOX_RIGHT":
        return CatspeakToken.BOX_RIGHT;
    case "BRACE_LEFT":
        return CatspeakToken.BRACE_LEFT;
    case "BRACE_RIGHT":
        return CatspeakToken.BRACE_RIGHT;
    case "DOT":
        return CatspeakToken.DOT;
    case "COLON":
        return CatspeakToken.COLON;
    case "COMMA":
        return CatspeakToken.COMMA;
    case "ASSIGN":
        return CatspeakToken.ASSIGN;
    case "IF":
        return CatspeakToken.IF;
    case "ELSE":
        return CatspeakToken.ELSE;
    case "WHILE":
        return CatspeakToken.WHILE;
    case "FOR":
        return CatspeakToken.FOR;
    case "LET":
        return CatspeakToken.LET;
    case "FUN":
        return CatspeakToken.FUN;
    case "BREAK":
        return CatspeakToken.BREAK;
    case "CONTINUE":
        return CatspeakToken.CONTINUE;
    case "RETURN":
        return CatspeakToken.RETURN;
    case "IDENT":
        return CatspeakToken.IDENT;
    case "STRING":
        return CatspeakToken.STRING;
    case "FLOAT":
        return CatspeakToken.FLOAT;
    case "INT":
        return CatspeakToken.INT;
    case "INT_HEX":
        return CatspeakToken.INT_HEX;
    case "INT_BIN":
        return CatspeakToken.INT_BIN;
    case "WHITESPACE":
        return CatspeakToken.WHITESPACE;
    case "COMMENT":
        return CatspeakToken.COMMENT;
    case "EOL":
        return CatspeakToken.EOL;
    case "BOF":
        return CatspeakToken.BOF;
    case "EOF":
        return CatspeakToken.EOF;
    case "OTHER":
        return CatspeakToken.OTHER;
    case "DISJUNCTION":
        return CatspeakToken.DISJUNCTION;
    case "CONJUNCTION":
        return CatspeakToken.CONJUNCTION;
    case "COMPARISON":
        return CatspeakToken.COMPARISON;
    case "ADDITION":
        return CatspeakToken.ADDITION;
    case "MULTIPLICATION":
        return CatspeakToken.MULTIPLICATION;
    case "DIVISION":
        return CatspeakToken.DIVISION;
    }
    return undefined;
}

/// Returns whether a Catspeak token is a valid operator.
///
/// @param {Enum.CatspeakToken} token
///   The ID of the token to check.
function catspeak_token_is_operator(token) {
    return token > CatspeakToken.__OPERATORS_BEGIN__
            && token < CatspeakToken.__OPERATORS_END__;
}
