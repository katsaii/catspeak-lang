//! Boilerplate for the [CatspeakToken] enum.

// NOTE: AVOID EDITING THIS FILE, IT HAS BEEN AUTOMATICALLY GENERATED!

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
    BREAK_LINE,
    CONTINUE_LINE,
    DO,
    IT,
    IF,
    ELSE,
    WHILE,
    FOR,
    LOOP,
    LET,
    FUN,
    BREAK,
    CONTINUE,
    RETURN,
    AND,
    OR,
    NEW,
    IMPL,
    SELF,
    IDENT,
    STRING,
    NUMBER,
    WHITESPACE,
    COMMENT,
    EOL,
    BOF,
    EOF,
    OTHER,
    __OPERATORS_BEGIN__,
    OP_LOW,
    OP_OR,
    OP_AND,
    OP_COMP,
    OP_ADD,
    OP_MUL,
    OP_DIV,
    OP_HIGH,
    __OPERATORS_END__,
}

/// Gets the name for a value of [CatspeakToken].
/// Will return `<unknown>` if the value is unexpected.
///
/// @param {Enum.CatspeakToken} value
///   The value of [CatspeakToken] to convert.
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
    case CatspeakToken.BREAK_LINE:
        return "BREAK_LINE";
    case CatspeakToken.CONTINUE_LINE:
        return "CONTINUE_LINE";
    case CatspeakToken.DO:
        return "DO";
    case CatspeakToken.IT:
        return "IT";
    case CatspeakToken.IF:
        return "IF";
    case CatspeakToken.ELSE:
        return "ELSE";
    case CatspeakToken.WHILE:
        return "WHILE";
    case CatspeakToken.FOR:
        return "FOR";
    case CatspeakToken.LOOP:
        return "LOOP";
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
    case CatspeakToken.AND:
        return "AND";
    case CatspeakToken.OR:
        return "OR";
    case CatspeakToken.NEW:
        return "NEW";
    case CatspeakToken.IMPL:
        return "IMPL";
    case CatspeakToken.SELF:
        return "SELF";
    case CatspeakToken.IDENT:
        return "IDENT";
    case CatspeakToken.STRING:
        return "STRING";
    case CatspeakToken.NUMBER:
        return "NUMBER";
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
    case CatspeakToken.OP_LOW:
        return "OP_LOW";
    case CatspeakToken.OP_OR:
        return "OP_OR";
    case CatspeakToken.OP_AND:
        return "OP_AND";
    case CatspeakToken.OP_COMP:
        return "OP_COMP";
    case CatspeakToken.OP_ADD:
        return "OP_ADD";
    case CatspeakToken.OP_MUL:
        return "OP_MUL";
    case CatspeakToken.OP_DIV:
        return "OP_DIV";
    case CatspeakToken.OP_HIGH:
        return "OP_HIGH";
    }
    return "<unknown>";
}