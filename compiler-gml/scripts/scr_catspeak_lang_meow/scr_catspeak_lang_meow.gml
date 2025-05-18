//! "Meow" is the code name for the Catspeak programming language, loosely
//! inspired by syntax from JavaScript, GML, and Rust.
//!
//! This module contains the parser for this language.

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