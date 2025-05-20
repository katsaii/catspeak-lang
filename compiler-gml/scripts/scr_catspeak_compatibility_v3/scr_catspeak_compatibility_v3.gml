//! Contains a simple compatibility layer for help with converting projects
//! from Catspeak 3 to Catspeak 4.

//# feather use syntax-errors

// CATSPEAK 3 //

/// Determines whether sanity checks and unsafe developer features are enabled
/// at runtime.
///
/// @deprecated {4.0.0}
///   Debug info is embedded by default now.
///
/// Debug mode is enabled by default, but you can disable these checks by
/// defining a configuration macro, and setting it to `false`:
/// ```gml
/// #macro Release:CATSPEAK_DEBUG_MODE false
/// ```
///
/// @warning
///   Although disabling this macro may give a noticable performance boost, it
///   will also result in **undefined behaviour** and **cryptic error messages**
///   if an error occurs.
///
///   If you are getting errors in your game, and you suspect Catspeak may be
///   the cause, make sure to re-enable debug mode if you have it disabled.
///
/// @return {Bool}
#macro CATSPEAK_DEBUG_MODE true

/// @ignore
///
/// @deprecated {4.0.0}
///
/// @param {String} src
/// @return {Id.Buffer}
function __catspeak_create_buffer_from_string(src) {
    return catspeak_util_buffer_create_from_string(src);
}

/// @ignore
///
/// @deprecated {4.0.0}
function __catspeak_location_show(location, filepath) {
    gml_pragma("forceinline");
    return catspeak_location_show(location, filepath);
}

/// @ignore
///
/// @deprecated {4.0.0}
function __catspeak_location_show_ext(location, filepath) {
    var msg = __catspeak_location_show(location, filepath);
    if (argument_count > 2) {
        msg += " -- ";
        for (var i = 2; i < argument_count; i += 1) {
            msg += __catspeak_string(argument[i]);
        }
    }
    return msg;
}

/// Gets the line component of a Catspeak source location. This is stored as a
/// 20-bit unsigned integer within the least-significant bits of the supplied
/// Catspeak location handle.
///
/// @deprecated {4.0.0}
///   Use `catspeak_location_get_line` instead.
///
/// @param {Real} location
///   A 32-bit integer representing the diagnostic information of a Catspeak
///   program.
///
/// @returns {Real}
function catspeak_location_get_row(location) {
    gml_pragma("forceinline");
    return catspeak_location_get_line(location);
}

/// At times, Catspeak creates a lot of garbage which tends to have a longer
/// lifetime than is typically expected.
///
/// Calling this function forces Catspeak to collect that garbage.
///
/// @deprecated {4.0.0}
function catspeak_collect() {
    if (CATSPEAK_DEBUG_MODE) {
        __catspeak_check_init();
    }
    var pool = global.__catspeakAllocPool;
    var poolSize = array_length(pool)-1;
    for (var i = poolSize; i >= 0; i -= 1) {
        var weakRef = pool[i];
        if (weak_ref_alive(weakRef)) {
            continue;
        }
        weakRef.adapter.destroy(weakRef.ds);
        array_delete(pool, i, 1);
    }
}

/// "adapter" here is a struct with two fields: "create" and "destroy" which
/// indicates how to construct and destruct the resource once the owner gets
/// collected.
///
/// "owner" is a struct whose lifetime determines whether the resource needs
/// to be collected as well. Once "owner" gets collected by the garbage
/// collector, any resources it owns will eventually get collected as well.
///
/// @ignore
///
/// @deprecated {4.0.0}
///
/// @param {Struct} owner
/// @param {Struct} adapter
/// @return {Any}
function __catspeak_alloc(owner, adapter) {
    var pool = global.__catspeakAllocPool;
    var poolMax = array_length(pool) - 1;
    if (poolMax >= 0) {
        repeat (3) { // the number of retries until a new resource is created
            var i = irandom(poolMax);
            var weakRef = pool[i];
            if (weak_ref_alive(weakRef)) {
                continue;
            }
            weakRef.adapter.destroy(weakRef.ds);
            var newWeakRef = weak_ref_create(owner);
            var resource = adapter.create();
            newWeakRef.adapter = adapter;
            newWeakRef.ds = resource;
            pool[@ i] = newWeakRef;
            return resource;
        }
    }
    var weakRef = weak_ref_create(owner);
    var resource = adapter.create();
    weakRef.adapter = adapter;
    weakRef.ds = resource;
    array_push(pool, weakRef);
    return resource;
}

/// @ignore
///
/// @deprecated {4.0.0}
///
/// @param {Struct} owner
function __catspeak_alloc_ds_map(owner) {
    gml_pragma("forceinline");
    return __catspeak_alloc(owner, global.__catspeakAllocDSMapAdapter);
}

/// @ignore
///
/// @deprecated {4.0.0}
///
/// @param {Struct} owner
function __catspeak_alloc_ds_list(owner) {
    gml_pragma("forceinline");
    return __catspeak_alloc(owner, global.__catspeakAllocDSListAdapter);
}

/// @ignore
///
/// @deprecated {4.0.0}
///
/// @param {Struct} owner
function __catspeak_alloc_ds_stack(owner) {
    gml_pragma("forceinline");
    return __catspeak_alloc(owner, global.__catspeakAllocDSStackAdapter);
}

/// @ignore
///
/// @deprecated {4.0.0}
///
/// @param {Struct} owner
function __catspeak_alloc_ds_priority(owner) {
    gml_pragma("forceinline");
    return __catspeak_alloc(owner, global.__catspeakAllocDSPriorityAdapter);
}

/// @ignore
///
/// @deprecated {4.0.0}
function __catspeak_init_alloc() {
    /// @ignore
    global.__catspeakAllocPool = [];
    /// @ignore
    global.__catspeakAllocDSMapAdapter = {
        create : ds_map_create,
        destroy : ds_map_destroy,
    };
    /// @ignore
    global.__catspeakAllocDSListAdapter = {
        create : ds_list_create,
        destroy : ds_list_destroy,
    };
    /// @ignore
    global.__catspeakAllocDSStackAdapter = {
        create : ds_stack_create,
        destroy : ds_stack_destroy,
    };
    /// @ignore
    global.__catspeakAllocDSPriorityAdapter = {
        create : ds_priority_create,
        destroy : ds_priority_destroy,
    };
}


/// @ignore
///
/// @deprecated {4.0.0}
function __catspeak_init_lexer_keywords() {
    var keywords = __catspeak_keywords_create();
    global.__catspeakConfig.keywords = keywords;
    return keywords;
}
/// @ignore
///
/// @deprecated {4.0.0}
function __catspeak_init_lexer() {
    // initialise map from character to token type
    /// @ignore
    //global.__catspeakChar2Token = __catspeak_init_lexer_codepage();
    /// @ignore
    global.__catspeakString2Token = __catspeak_init_lexer_keywords();
}

/// @ignore
///
/// @deprecated {4.0.0}
///
/// @return {Struct}
function __catspeak_keywords_create() {
    var keywords = { };
    keywords[$ "and"] = CatspeakTokenV3.AND;
    keywords[$ "or"] = CatspeakTokenV3.OR;
    keywords[$ "xor"] = CatspeakTokenV3.XOR;
    keywords[$ "do"] = CatspeakTokenV3.DO;
    keywords[$ "if"] = CatspeakTokenV3.IF;
    keywords[$ "else"] = CatspeakTokenV3.ELSE;
    keywords[$ "catch"] = CatspeakTokenV3.CATCH;
    keywords[$ "while"] = CatspeakTokenV3.WHILE;
    keywords[$ "for"] = CatspeakTokenV3.FOR;
    keywords[$ "loop"] = CatspeakTokenV3.LOOP;
    keywords[$ "with"] = CatspeakTokenV3.WITH;
    keywords[$ "match"] = CatspeakTokenV3.MATCH;
    keywords[$ "let"] = CatspeakTokenV3.LET;
    keywords[$ "fun"] = CatspeakTokenV3.FUN;
    keywords[$ "params"] = CatspeakTokenV3.PARAMS;
    keywords[$ "break"] = CatspeakTokenV3.BREAK;
    keywords[$ "continue"] = CatspeakTokenV3.CONTINUE;
    keywords[$ "return"] = CatspeakTokenV3.RETURN;
    keywords[$ "throw"] = CatspeakTokenV3.THROW;
    keywords[$ "new"] = CatspeakTokenV3.NEW;
    keywords[$ "impl"] = CatspeakTokenV3.IMPL;
    keywords[$ "self"] = CatspeakTokenV3.SELF;
    keywords[$ "other"] = CatspeakTokenV3.OTHER;
    return keywords;
}

/// @ignore
///
/// @deprecated {4.0.0}
function __catspeak_keywords_rename(keywords, currentName, newName) {
    if (!variable_struct_exists(keywords, currentName)) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_error_silent(
                "no keyword with the name '", currentName, "' exists"
            );
        }
        return;
    }
    var token = keywords[$ currentName];
    variable_struct_remove(keywords, currentName);
    keywords[$ newName] = token;
}

/// @ignore
///
/// @deprecated {4.0.0}
///
/// @remark
///   This is an O(n) operation. This means that it's slow, and should only
///   be used for debugging purposes.
function __catspeak_keywords_find_name(keywords, token) {
    if (CATSPEAK_DEBUG_MODE) {
        __catspeak_check_arg("keywords", keywords, is_struct);
        __catspeak_check_arg(
                "token", token, __catspeak_is_token, "CatspeakTokenV3");
    }
    var variables = variable_struct_get_names(keywords);
    var variableCount = array_length(variables);
    for (var i = 0; i < variableCount; i += 1) {
        var variable = variables[i];
        if (keywords[$ variable] == token) {
            return variable;
        }
    }
    return undefined;
}

/// A token in Catspeak is a series of characters with meaning, usually
/// separated by whitespace. These meanings are represented by unique
/// elements of the `CatspeakTokenV3` enum.
///
/// @deprecated {4.0.0}
///   Use `CatspeakToken` instead.
///
/// @example
///   Some examples of tokens in Catspeak, and their meanings:
///   - `if`   (is a `CatspeakTokenV3.IF`)
///   - `else` (is a `CatspeakTokenV3.ELSE`)
///   - `12.3` (is a `CatspeakTokenV3.VALUE`)
///   - `+`    (is a `CatspeakTokenV3.PLUS`)
enum CatspeakTokenV3 {
    /// The `(` character.
    PAREN_LEFT = CatspeakToken.PAREN_LEFT,
    /// The `)` character.
    PAREN_RIGHT = CatspeakToken.PAREN_RIGHT,
    /// The `[` character.
    BOX_LEFT = CatspeakToken.BOX_LEFT,
    /// The `]` character.
    BOX_RIGHT = CatspeakToken.BOX_RIGHT,
    /// The `{` character.
    BRACE_LEFT = CatspeakToken.BRACE_LEFT,
    /// The `}` character.
    BRACE_RIGHT = CatspeakToken.BRACE_RIGHT,
    /// The `:` character.
    COLON = CatspeakToken.COLON,
    /// The `;` character.
    SEMICOLON = CatspeakToken.SEMICOLON,
    /// The `,` character.
    COMMA = CatspeakToken.COMMA,
    /// The `.` operator.
    DOT = CatspeakToken.DOT,
    /// The `=>` operator.
    ARROW = CatspeakToken.ARROW,
    /// @ignore
    __OP_ASSIGN_BEGIN__ = CatspeakToken.ASSIGN,
    /// The `=` operator.
    ASSIGN = CatspeakToken.ASSIGN,
    /// The `*=` operator.
    ASSIGN_MULTIPLY = CatspeakToken.ASSIGN_MULTIPLY,
    /// The `/=` operator.
    ASSIGN_DIVIDE = CatspeakToken.ASSIGN_DIVIDE,
    /// The `-=` operator.
    ASSIGN_SUBTRACT = CatspeakToken.ASSIGN_SUBTRACT,
    /// The `+=` operator.
    ASSIGN_PLUS = CatspeakToken.ASSIGN_PLUS,
    /// @ignore
    __OP_BEGIN__ = CatspeakToken.REMAINDER,
    /// The remainder `%` operator.
    REMAINDER = CatspeakToken.REMAINDER,
    /// The `*` operator.
    MULTIPLY = CatspeakToken.MULTIPLY,
    /// The `/` operator.
    DIVIDE = CatspeakToken.DIVIDE,
    /// The integer division `//` operator.
    DIVIDE_INT = CatspeakToken.DIVIDE_INT,
    /// The `-` operator.
    SUBTRACT = CatspeakToken.SUBTRACT,
    /// The `+` operator.
    PLUS = CatspeakToken.PLUS,
    /// The relational `==` operator.
    EQUAL = CatspeakToken.EQUAL,
    /// The relational `!=` operator.
    NOT_EQUAL = CatspeakToken.NOT_EQUAL,
    /// The relational `>` operator.
    GREATER = CatspeakToken.GREATER,
    /// The relational `>=` operator.
    GREATER_EQUAL = CatspeakToken.GREATER_EQUAL,
    /// The relational `<` operator.
    LESS = CatspeakToken.LESS,
    /// The relational `<=` operator.
    LESS_EQUAL = CatspeakToken.LESS_EQUAL,
    /// The logical negation `!` operator.
    NOT = CatspeakToken.NOT,
    /// The bitwise negation `~` operator.
    BITWISE_NOT = CatspeakToken.BITWISE_NOT,
    /// The bitwise right shift `>>` operator.
    SHIFT_RIGHT = CatspeakToken.SHIFT_RIGHT,
    /// The bitwise left shift `<<` operator.
    SHIFT_LEFT = CatspeakToken.SHIFT_LEFT,
    /// The bitwise and `&` operator.
    BITWISE_AND = CatspeakToken.BITWISE_AND,
    /// The bitwise xor `^` operator.
    BITWISE_XOR = CatspeakToken.BITWISE_XOR,
    /// The bitwise or `|` operator.
    BITWISE_OR = CatspeakToken.BITWISE_OR,
    /// The logical `and` operator.
    AND = CatspeakToken.AND,
    /// The logical `or` operator.
    OR = CatspeakToken.OR,
    /// The logical `xor` operator.
    XOR = CatspeakToken.XOR,
    /// The functional pipe right `|>` operator.
    PIPE_RIGHT = CatspeakToken.PIPE_RIGHT,
    /// The functional pipe left `<|` operator.
    PIPE_LEFT = CatspeakToken.PIPE_LEFT,
    /// The `do` keyword.
    DO = CatspeakToken.DO,
    /// The `if` keyword.
    IF = CatspeakToken.IF,
    /// The `else` keyword.
    ELSE = CatspeakToken.ELSE,
    /// The `catch` keyword.
    CATCH = CatspeakToken.CATCH,
    /// The `while` keyword.
    WHILE = CatspeakToken.WHILE,
    /// The `for` keyword.
    ///
    /// @experimental
    FOR = CatspeakToken.FOR,
    /// The `loop` keyword.
    ///
    /// @experimental
    LOOP = CatspeakToken.LOOP,
    /// The `with` keyword.
    ///
    /// @experimental
    WITH = CatspeakToken.WITH,
    /// The `match` keyword.
    ///
    /// @experimental
    MATCH = CatspeakToken.MATCH,
    /// The `let` keyword.
    LET = CatspeakToken.LET,
    /// The `fun` keyword.
    FUN = CatspeakToken.FUN,
    /// The `break` keyword.
    BREAK = CatspeakToken.BREAK,
    /// The `continue` keyword.
    CONTINUE = CatspeakToken.CONTINUE,
    /// The `return` keyword.
    RETURN = CatspeakToken.RETURN,
    /// The `throw` keyword.
    THROW = CatspeakToken.THROW,
    /// The `new` keyword.
    NEW = CatspeakToken.NEW,
    /// The `impl` keyword.
    ///
    /// @experimental
    IMPL = CatspeakToken.IMPL,
    /// The `self` keyword.
    ///
    /// @experimental
    SELF = CatspeakToken.SELF,
    /// The `params` keyword.
    ///
    /// @experimental
    PARAMS = CatspeakToken.PARAMS,
    /// The `params_count` keyword.
    ///
    /// @experimental
    PARAMS_COUNT = CatspeakToken.PARAMS_COUNT,
    /// Represents a variable name.
    IDENT = CatspeakToken.IDENT,
    /// Represents a GML value. This could be one of:
    ///  - string literal:    `"hello world"`
    ///  - verbatim literal:  `@"\(0_0)/ no escapes!"`
    ///  - integer:           `1`, `2`, `5`
    ///  - float:             `1.25`, `0.5`
    ///  - character:         `'A'`, `'0'`, `'\n'`
    ///  - boolean:           `true` or `false`
    ///  - `undefined`
    //VALUE = CatspeakToken.NUMBER,
    VALUE_NUMBER = CatspeakToken.NUMBER,
    VALUE_STRING = CatspeakToken.STRING,
    VALUE_UNDEFINED = CatspeakToken.UNDEFINED,
    /// Represents a sequence of non-breaking whitespace characters.
    WHITESPACE = CatspeakToken.WHITESPACE,
    /// Represents a comment.
    COMMENT = CatspeakToken.COMMENT,
    /// Represents the end of the file.
    EOF = CatspeakToken.EOF,
    /// Represents any other unrecognised character.
    ///
    /// @remark
    ///   If the compiler encounters a token of this type, it will typically
    ///   raise an exception. This likely indicates that a Catspeak script has
    ///   a syntax error somewhere.
    OTHER = CatspeakToken.ERROR,
    /// @ignore
    __SIZE__ = CatspeakToken.__SIZE__,
}

/// @ignore
///
/// @deprecated {4.0.0}
function __catspeak_is_token(val) {
    // the user can modify what keywords are, so just check
    // that they've used one of the enum types instead of a
    // random ass value
    return is_numeric(val) && (
        val >= 0 && val < CatspeakTokenV3.__SIZE__
    );
}

/// Responsible for tokenising the contents of a GML buffer. This can be used
/// for syntax highlighting in a programming game which uses Catspeak.
///
/// @deprecated {4.0.0}
///   Use `CatspeakLexer` instead.
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
///
/// @param {Struct} [keywords]
///   A struct whose keys map to the corresponding Catspeak tokens they
///   represent. Defaults to the vanilla set of Catspeak keywords.
function CatspeakLexerV3(
    buff, offset=0, size=infinity, keywords=undefined
) : CatspeakLexer(buff, offset, size) constructor {
    /// @ignore
    self.__keywords = keywords ?? global.__catspeakString2Token;
    /// @ignore
    self.__nextUTF8Char = __nextChar;
    /// @ignore
    self.__advance = advanceChar;
    /// @ignore
    self.__clearLexeme = clearLexeme;
}

/// @ignore
///
/// @deprecated {4.0.0}
///   Use `__catspeak_char_is_alphanum` instead.
function __catspeak_char_is_alphanumeric(char) {
    gml_pragma("forceinline");
    return __catspeak_char_is_alphanum(char);
}