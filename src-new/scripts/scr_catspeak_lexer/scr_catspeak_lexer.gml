//! Responsible for the lexical analysis stage of the Catspeak compiler.

//# feather use syntax-errors

/// A token in Catspeak is a series of characters with meaning, usually
/// separated by whitespace.
///
/// For example, these are all valid tokens:
///   - `if`   (is a `CatspeakToken.IF`)
///   - `else` (is a `CatspeakToken.ELSE`)
///   - `12.3` (is a `CatspeakToken.NUMBER`)
///   - `+`    (is a `CatspeakToken.OP_ADD`)
enum CatspeakToken {
    PAREN_LEFT, PAREN_RIGHT,
    BOX_LEFT, BOX_RIGHT,
    BRACE_LEFT, BRACE_RIGHT,
    DOT, COLON, COMMA, ASSIGN, BREAK_LINE, CONTINUE_LINE,
    DO, IT, IF, ELSE, WHILE, FOR, LOOP, LET, FUN, BREAK, CONTINUE, RETURN,
    AND, OR,
    NEW, IMPL, SELF,
    IDENT, STRING, NUMBER,
    WHITESPACE, COMMENT,
    EOL, BOF, EOF, OTHER,
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
    __SIZE__
}

/// Tokenises the contents of a GML buffer. The lexer does not take ownership
/// of this buffer, but it may mutate it so beware. Therefore you should make
/// sure to delete the buffer once parsing is complete.
///
/// @param {Id.Buffer} buff
/// @param {Real} offset
/// @param {Real} size
///
/// @ignore
function __CatspeakLexer(buff, offset, size) constructor {
    
}