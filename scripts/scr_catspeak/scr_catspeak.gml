/* Catspeak Core Compiler
 * ----------------------
 * Kat @katsaii
 */

/// @desc Creates a new Catspeak session.
function catspeak_session_create() {
    return {
        sourceQueue : [],
        currentSource : undefined,
        errorHandler : undefined,
        runtime : new __CatspeakVM()
    };
}

/// @desc Destroys an existing catspeak session.
/// @param {struct} session The Catspeak session to destroy.
function catspeak_session_destroy(_session) {
    buffer_delete(_session.currentSource.buff);
    var source_queue = _session.sourceQueue;
    for (var i = array_length(source_queue) - 1; i >= 0; i -= 1) {
        var source = source_queue[i];
        buffer_delete(source.buff);
    }
    variable_struct_remove(_session, "sourceQueue");
    variable_struct_remove(_session, "currentSource");
    variable_struct_remove(_session, "errorHandler");
    variable_struct_remove(_session, "runtime");
}

/// @desc Returns whether this Catspeak session is processing.
/// @param {struct} session The Catspeak session to consider.
function catspeak_session_in_progress(_session) {
    return _session.currentSource != undefined || _session.runtime.inProgress();
}

/// @desc Rewinds this Catspeak session back to the start of the program.
/// @param {struct} session The Catspeak session to rewind.
function catspeak_session_rewind(_session, _f) {
    _session.runtime.rewind();
}

/// @desc Returns the current variable workspace for this Catspeak session.
/// @param {struct} session The Catspeak session to consider.
function catspeak_session_get_workspace(_session) {
    return _session.runtime.getWorkspace();
}

/// @desc Sets the error handler for this Catspeak session.
/// @param {struct} session The Catspeak session to consider.
/// @param {script} method_or_script_id The id of the script to execute upon receiving a Catspeak error.
function catspeak_session_set_error_handler(_session, _f) {
    _session.errorHandler = _f;
}

/// @desc Sets the error handler for this Catspeak session.
/// @param {struct} session The Catspeak session to consider.
/// @param {script} method_or_script_id The id of the script to execute upon receiving a result.
function catspeak_session_set_result_handler(_session, _f) {
    _session.runtime.setOption(__CatspeakVMOption.RESULT_HANDLER, _f);
}

/// @desc Sets a function to call on popped expression statementes.
/// @param {struct} session The Catspeak session to consider.
/// @param {script} method_or_script_id The id of the script to execute upon popping an expression statement.
function catspeak_session_set_expression_statement_handler(_session, _f) {
    _session.runtime.setOption(__CatspeakVMOption.POP_HANDLER, _f);
}

/// @desc Enables access to global variables from within Catspeak.
/// @param {struct} session The Catspeak session to consider.
/// @param {bool} enable Whether to enable this option.
function catspeak_session_enable_global_access(_session, _enable) {
    _session.runtime.setOption(__CatspeakVMOption.GLOBAL_VISIBILITY, _enable);
}

/// @desc Enables access to instance variables from within Catspeak.
/// @param {struct} session The Catspeak session to consider.
/// @param {bool} enable Whether to enable this option.
function catspeak_session_enable_instance_access(_session, _enable) {
    _session.runtime.setOption(__CatspeakVMOption.INSTANCE_VISIBILITY, _enable);
}

/// @desc Inserts a new read-only global variable into the interface.
/// @param {struct} session The Catspeak session to consider.
/// @param {string} name The name of the variable.
/// @param {value} value The value of the variable.
function catspeak_session_add_constant(_session, _name, _value) {
    _session.runtime.addConstant(_name, _value);
}

/// @desc Inserts a new function into to the interface.
/// @param {struct} session The Catspeak session to consider.
/// @param {string} name The name of the function.
/// @param {value} method_or_script_id The reference to the function.
function catspeak_session_add_function(_session, _name, _value) {
    _session.runtime.addFunction(_name, _value);
}

/// @desc Adds a new piece of source code to the current Catspeak session.
/// @param {struct} session The Catspeak session to consider.
/// @param {string} src The source code to compiler and evaluate.
function catspeak_session_add_source(_session, _src) {
    var src_size = string_byte_length(_src);
    var src_buff = buffer_create(src_size, buffer_fixed, 1);
    buffer_write(src_buff, buffer_text, _src);
    buffer_seek(src_buff, buffer_seek_start, 0);
    var src_scanner = new __CatspeakScanner(src_buff);
    var src_lexer = new __CatspeakLexer(src_scanner);
    var src_chunk = new __CatspeakChunk();
    var src_compiler = new __CatspeakCompiler(src_lexer, src_chunk);
    var source = {
        buff : src_buff,
        chunk : src_chunk,
        compiler : src_compiler
    };
    if (_session.currentSource == undefined) {
        _session.currentSource = source;
    } else {
        array_insert(_session.sourceQueue, 0, source);
    }
}

/// @desc Discards a recently queued piece of source code.
/// @param {struct} session The Catspeak session to consider.
function catspeak_session_discard_source(_session) {
    buffer_delete(_session.currentSource.buff);
    var source_queue = _session.sourceQueue;
    if (array_length(source_queue) > 0) {
        _session.currentSource = array_pop(source_queue);
    } else {
        _session.currentSource = undefined;
    }
}

/// @desc Performs a single update step for the compiler.
/// @param {struct} session The Catspeak session to consider.
function catspeak_session_update(_session) {
    static handle_catspeak_error = function(_e, _f) {
        if (instanceof(_e) == "__CatspeakError") {
            if (_f != undefined) {
                _f(_e);
            }
        } else {
            throw _e;
        }
    };
    var source = _session.currentSource;
    var runtime = _session.runtime;
    if (source != undefined) {
        var compiler = source.compiler;
        try {
            compiler.generateCode();
        } catch (_e) {
            handle_catspeak_error(_e, _session.errorHandler);
            // discard this chunk since it's spicy
            catspeak_session_discard_source(_session);
        }
        if not (compiler.inProgress()) {
            // start progress on the new compiler
            runtime.addChunk(source.chunk);
            catspeak_session_discard_source(_session);
        }
    } else {
        try {
            runtime.computeProgram();
        } catch (_e) {
            handle_catspeak_error(_e, _session.errorHandler);
        }
    }
}

/// @desc Represents a Catspeak error.
/// @param {vector} pos The vector holding the row and column numbers.
/// @param {string} msg The error message.
function __CatspeakError(_pos, _msg) constructor {
    pos = _pos;
    reason = is_string(_msg) ? _msg : string(_msg);
    /// @desc Displays the content of this error.
    static toString = function() {
        return "Fatal Error at (row. " + string(pos[0]) + ", col. " + string(pos[1]) + "): " + reason;
    }
}

/// @desc Represents a kind of token.
enum __CatspeakToken {
    PAREN_LEFT,
    PAREN_RIGHT,
    BOX_LEFT,
    BOX_RIGHT,
    BRACE_LEFT,
    BRACE_RIGHT,
    DOT, // used for accessing members
    COLON, // function application operator, `f (a + b)` is equivalent to `f : a + b`
    SEMICOLON, // statement terminator
    __OPERATORS_BEGIN__,
    DISJUNCTION,
    CONJUNCTION,
    COMPARISON,
    ADDITION,
    MULTIPLICATION,
    DIVISION,
    __OPERATORS_END__,
    SET,
    IF,
    ELSE,
    WHILE,
    PRINT,
    RUN,
    RETURN,
    IDENTIFIER,
    STRING,
    NUMBER,
    WHITESPACE,
    COMMENT,
    EOL,
    BOF,
    EOF,
    OTHER
}

/// @desc Displays the token as a string.
/// @param {__CatspeakToken} kind The token kind to display.
function __catspeak_token_render(_kind) {
    switch (_kind) {
    case __CatspeakToken.PAREN_LEFT: return "PAREN_LEFT";
    case __CatspeakToken.PAREN_RIGHT: return "PAREN_RIGHT";
    case __CatspeakToken.BOX_LEFT: return "BOX_LEFT";
    case __CatspeakToken.BOX_RIGHT: return "BOX_RIGHT";
    case __CatspeakToken.BRACE_LEFT: return "BRACE_LEFT";
    case __CatspeakToken.BRACE_RIGHT: return "BRACE_RIGHT";
    case __CatspeakToken.DOT: return "DOT";
    case __CatspeakToken.COLON: return "COLON";
    case __CatspeakToken.SEMICOLON: return "SEMICOLON";
    case __CatspeakToken.DISJUNCTION: return "DISJUNCTION";
    case __CatspeakToken.CONJUNCTION: return "CONJUNCTION";
    case __CatspeakToken.COMPARISON: return "COMPARISON";
    case __CatspeakToken.ADDITION: return "ADDITION";
    case __CatspeakToken.MULTIPLICATION: return "MULTIPLICATION";
    case __CatspeakToken.DIVISION: return "DIVISION";
    case __CatspeakToken.SET: return "SET";
    case __CatspeakToken.IF: return "IF";
    case __CatspeakToken.ELSE: return "ELSE";
    case __CatspeakToken.WHILE: return "WHILE";
    case __CatspeakToken.PRINT: return "PRINT";
    case __CatspeakToken.RUN: return "RUN";
    case __CatspeakToken.RETURN: return "RETURN";
    case __CatspeakToken.IDENTIFIER: return "IDENTIFIER";
    case __CatspeakToken.STRING: return "STRING";
    case __CatspeakToken.NUMBER: return "NUMBER";
    case __CatspeakToken.WHITESPACE: return "WHITESPACE";
    case __CatspeakToken.COMMENT: return "COMMENT";
    case __CatspeakToken.EOL: return "EOL";
    case __CatspeakToken.BOF: return "BOF";
    case __CatspeakToken.EOF: return "EOF";
    case __CatspeakToken.OTHER: return "OTHER";
    default: return "<unknown>";
    }
}

/// @desc Returns whether a token is a valid operator.
/// @param {__CatspeakToken} token The token to check.
function __catspeak_token_is_operator(_token) {
    return _token > __CatspeakToken.__OPERATORS_BEGIN__
            && _token < __CatspeakToken.__OPERATORS_END__;
}

/// @desc Returns whether a byte is a valid newline character.
/// @param {real} byte The byte to check.
function __catspeak_byte_is_newline(_byte) {
    switch (_byte) {
    case ord("\n"):
    case ord("\r"):
        return true;
    default:
        return false;
    }
}

/// @desc Returns whether a byte is NOT a valid newline character.
/// @param {real} byte The byte to check.
function __catspeak_byte_is_not_newline(_byte) {
    return !__catspeak_byte_is_newline(_byte);
}

/// @desc Returns whether a byte is a valid quote character.
/// @param {real} byte The byte to check.
function __catspeak_byte_is_quote(_byte) {
    return _byte == ord("\"");
}

/// @desc Returns whether a byte is NOT a valid quote character.
/// @param {real} byte The byte to check.
function __catspeak_byte_is_not_quote(_byte) {
    return !__catspeak_byte_is_quote(_byte);
}

/// @desc Returns whether a byte is a valid quote character.
/// @param {real} byte The byte to check.
function __catspeak_byte_is_accent(_byte) {
    return _byte == ord("`");
}

/// @desc Returns whether a byte is NOT a valid quote character.
/// @param {real} byte The byte to check.
function __catspeak_byte_is_not_accent(_byte) {
    return !__catspeak_byte_is_accent(_byte);
}

/// @desc Returns whether a byte is a valid whitespace character.
/// @param {real} byte The byte to check.
function __catspeak_byte_is_whitespace(_byte) {
    switch (_byte) {
    case ord(" "):
    case ord("\t"):
        return true;
    default:
        return false;
    }
}

/// @desc Returns whether a byte is a valid alphabetic character.
/// @param {real} byte The byte to check.
function __catspeak_byte_is_alphabetic(_byte) {
    return _byte >= ord("a") && _byte <= ord("z")
            || _byte >= ord("A") && _byte <= ord("Z")
            || _byte == ord("_")
            || _byte == ord("'");
}

/// @desc Returns whether a byte is a valid digit character.
/// @param {real} byte The byte to check.
function __catspeak_byte_is_digit(_byte) {
    return _byte >= ord("0") && _byte <= ord("9");
}

/// @desc Returns whether a byte is a valid alphanumeric character.
/// @param {real} byte The byte to check.
function __catspeak_byte_is_alphanumeric(_byte) {
    return __catspeak_byte_is_alphabetic(_byte)
            || __catspeak_byte_is_digit(_byte);
}

/// @desc Returns whether a byte is a valid operator character.
/// @param {real} byte The byte to check.
function __catspeak_byte_is_operator(_byte) {
    return _byte == ord("!")
            || _byte >= ord("#") && _byte <= ord("&")
            || _byte == ord("*")
            || _byte == ord("+")
            || _byte == ord("-")
            || _byte == ord("/")
            || _byte >= ord("<") && _byte <= ord("@")
            || _byte == ord("^")
            || _byte == ord("|")
            || _byte == ord("~");
}

/// @desc Tokenises the buffer contents.
/// @param {real} buffer The id of the buffer to use.
function __CatspeakScanner(_buff) constructor {
    buff = _buff;
    alignment = buffer_get_alignment(_buff);
    limit = buffer_get_size(_buff);
    row = 1; // assumes the buffer is always at its starting position, even if it's not
    col = 1;
    rowStart = row;
    colStart = col;
    cr = false;
    lexeme = undefined;
    lexemeLength = 0;
    isCommentLexeme = true;
    skipNextByte = false;
    /// @desc Returns the current buffer lexeme.
    static getLexeme = function() {
        return lexeme;
    }
    /// @desc Returns the current buffer position.
    static getPosition = function() {
        return [rowStart, colStart];
    }
    /// @desc Checks for a new line character and increments the source position.
    /// @param {real} byte The byte to register.
    static registerByte = function(_byte) {
        lexemeLength += 1;
        if (isCommentLexeme && _byte != ord("-")) {
            isCommentLexeme = false;
        }
        if (_byte == ord("\r")) {
            cr = true;
            col = 1;
            row += 1;
        } else if (_byte == ord("\n")) {
            col = 1;
            if (cr) {
                cr = false;
            } else {
                row += 1;
            }
        } else {
            col += 1;
            cr = false;
        }
    }
    /// @desc Registers the current lexeme as a string.
    static registerLexeme = function() {
        if (lexemeLength < 1) {
            // always an empty slice
            lexeme = "";
            return;
        }
        var slice = buffer_create(lexemeLength, buffer_fixed, 1);
        buffer_copy(buff, buffer_tell(buff) - lexemeLength, lexemeLength, slice, 0);
        buffer_seek(slice, buffer_seek_start, 0);
        lexeme = buffer_read(slice, buffer_text);
        buffer_delete(slice);
    }
    /// @desc Resets the current lexeme.
    static clearLexeme = function() {
        isCommentLexeme = true;
        lexemeLength = 0;
        lexeme = undefined;
        rowStart = row;
        colStart = col;
    }
    /// @desc Advances the scanner and returns the current byte.
    static advance = function() {
        var byte = buffer_read(buff, buffer_u8);
        registerByte(byte);
        return byte;
    }
    /// @desc Returns whether the next byte equals this expected byte. And advances the scanner if this is the case.
    /// @param {real} expected The byte to check for.
    static advanceIf = function(_expected) {
        var seek = buffer_tell(buff);
        var actual = buffer_peek(buff, seek, buffer_u8);
        if (actual != _expected) {
            return false;
        }
        buffer_read(buff, buffer_u8);
        registerByte(actual);
        return true;
    }
    /// @desc Advances the scanner whilst a predicate holds, or until the EoF was reached.
    /// @param {script} pred The predicate to check for.
    /// @param {script} escape The predicate to check for escapes.
    static advanceWhileEscape = function(_pred, _escape) {
        var do_escape = false;
        var byte = undefined;
        var seek = buffer_tell(buff);
        while (seek < limit) {
            byte = buffer_peek(buff, seek, buffer_u8);
            if (do_escape) {
                do_escape = _escape(byte);
            }
            if not (do_escape) {
                if not (_pred(byte)) {
                    break;
                } else if (byte == ord("\\")) {
                    do_escape = true;
                }
            }
            registerByte(byte);
            seek += alignment;
        }
        buffer_seek(buff, buffer_seek_start, seek);
        return byte;
    }
    /// @desc Advances the scanner according to this predicate, but escapes newline characters.
    /// @param {script} pred The predicate to check for.
    static advanceWhile = function(_pred) {
        return advanceWhileEscape(_pred, __catspeak_byte_is_newline);
    }
    /// @desc Advances the scanner and returns the next token.
    static next = function() {
        clearLexeme();
        if (buffer_tell(buff) >= limit) {
            return __CatspeakToken.EOF;
        }
        if (skipNextByte) {
            advance();
            skipNextByte = false;
            return next();
        }
        var byte = advance();
        switch (byte) {
        case ord("\\"):
            // this is needed for a specific case where `\` is the first character in a line
            advanceWhile(__catspeak_byte_is_newline);
            advanceWhile(__catspeak_byte_is_whitespace);
            return __CatspeakToken.WHITESPACE;
        case ord("("):
            return __CatspeakToken.PAREN_LEFT;
        case ord(")"):
            return __CatspeakToken.PAREN_RIGHT;
        case ord("["):
            return __CatspeakToken.BOX_LEFT;
        case ord("]"):
            return __CatspeakToken.BOX_RIGHT;
        case ord("{"):
            return __CatspeakToken.BRACE_LEFT;
        case ord("}"):
            return __CatspeakToken.BRACE_RIGHT;
        case ord(":"):
            return __CatspeakToken.COLON;
        case ord(";"):
            return __CatspeakToken.SEMICOLON;
        case ord("|"):
        case ord("^"):
        case ord("$"):
            advanceWhile(__catspeak_byte_is_operator);
            registerLexeme();
            return __CatspeakToken.DISJUNCTION;
        case ord("&"):
            advanceWhile(__catspeak_byte_is_operator);
            registerLexeme();
            return __CatspeakToken.CONJUNCTION;
        case ord("<"):
        case ord(">"):
        case ord("!"):
        case ord("?"):
        case ord("="):
        case ord("~"):
            advanceWhile(__catspeak_byte_is_operator);
            registerLexeme();
            return __CatspeakToken.COMPARISON;
        case ord("+"):
        case ord("-"):
            advanceWhile(__catspeak_byte_is_operator);
            if (isCommentLexeme && lexemeLength > 1) {
                advanceWhile(__catspeak_byte_is_not_newline);
                return __CatspeakToken.COMMENT;
            }
            registerLexeme();
            return __CatspeakToken.ADDITION;
        case ord("*"):
        case ord("/"):
            advanceWhile(__catspeak_byte_is_operator);
            registerLexeme();
            return __CatspeakToken.MULTIPLICATION;
        case ord("%"):
        case ord("@"):
        case ord("#"):
            advanceWhile(__catspeak_byte_is_operator);
            registerLexeme();
            return __CatspeakToken.DIVISION;
        case ord("\""):
            clearLexeme();
            advanceWhileEscape(__catspeak_byte_is_not_quote, __catspeak_byte_is_quote);
            skipNextByte = true;
            registerLexeme();
            return __CatspeakToken.STRING;
        case ord("."):
            return __CatspeakToken.DOT;
        case ord("`"):
            clearLexeme();
            advanceWhileEscape(__catspeak_byte_is_not_accent, __catspeak_byte_is_accent);
            skipNextByte = true;
            registerLexeme();
            return __CatspeakToken.IDENTIFIER;
        default:
            if (__catspeak_byte_is_newline(byte)) {
                advanceWhile(__catspeak_byte_is_newline);
                return __CatspeakToken.EOL;
            } else if (__catspeak_byte_is_whitespace(byte)) {
                advanceWhile(__catspeak_byte_is_whitespace);
                return __CatspeakToken.WHITESPACE;
            } else if (__catspeak_byte_is_alphabetic(byte)) {
                advanceWhile(__catspeak_byte_is_alphanumeric);
                registerLexeme();
                var keyword;
                switch (lexeme) {
                case "set":
                    keyword = __CatspeakToken.SET;
                    break;
                case "if":
                    keyword = __CatspeakToken.IF;
                    break;
                case "else":
                    keyword = __CatspeakToken.ELSE;
                    break;
                case "while":
                    keyword = __CatspeakToken.WHILE;
                    break;
                case "print":
                    keyword = __CatspeakToken.PRINT;
                    break;
                case "run":
                    keyword = __CatspeakToken.RUN;
                    break;
                case "return":
                    keyword = __CatspeakToken.RETURN;
                    break;
                default:
                    return __CatspeakToken.IDENTIFIER;
                }
                lexeme = undefined;
                return keyword;
            } else if (__catspeak_byte_is_digit(byte)) {
                advanceWhile(__catspeak_byte_is_digit);
                registerLexeme();
                return __CatspeakToken.NUMBER;
            } else {
                return __CatspeakToken.OTHER;
            }
        }
    }
    /// @desc Returns the next token that isn't a whitespace or comment token.
    static nextWithoutSpace = function() {
        var token;
        do {
            token = next();
        } until (token != __CatspeakToken.WHITESPACE
                && token != __CatspeakToken.COMMENT);
        return token;
    }
}

/// @desc An iterator that simplifies tokens generated by the scanner and applies automatic semicolon insertion.
/// @param {__CatspeakScanner} scanner The Catspeak scanner to iterate over.
function __CatspeakLexer(_scanner) constructor {
    scanner = _scanner;
    pred = __CatspeakToken.BOF;
    lexeme = scanner.getLexeme();
    pos = scanner.getPosition();
    current = scanner.nextWithoutSpace();
    parenDepth = 0;
    eof = false;
    /// @desc Returns the current buffer lexeme.
    static getLexeme = function() {
        return lexeme;
    }
    /// @desc Returns the current buffer position.
    static getPosition = function() {
        return pos;
    }
    /// @desc Advances the scanner and returns the next token.
    static next = function() {
        while (true) {
            lexeme = scanner.getLexeme();
            pos = scanner.getPosition();
            var succ = scanner.nextWithoutSpace();
            switch (current) {
            case __CatspeakToken.PAREN_LEFT:
                parenDepth += 1;
                break;
            case __CatspeakToken.PAREN_RIGHT:
                if (parenDepth > 0) {
                    parenDepth -= 1;
                }
                break;
            case __CatspeakToken.EOL:
                var implicit_semicolon = parenDepth <= 0;
                switch (pred) {
                case __CatspeakToken.BOX_LEFT:
                case __CatspeakToken.BRACE_LEFT:
                case __CatspeakToken.DOT:
                case __CatspeakToken.COLON:
                case __CatspeakToken.SEMICOLON:
                case __CatspeakToken.ADDITION:
                    implicit_semicolon = false;
                    break;
                default:
                    if (__catspeak_token_is_operator(pred)) {
                        implicit_semicolon = false;
                    }
                }
                switch (succ) {
                case __CatspeakToken.DOT:
                case __CatspeakToken.COLON:
                case __CatspeakToken.ELSE:
                case __CatspeakToken.SEMICOLON:
                case __CatspeakToken.ADDITION:
                    implicit_semicolon = false;
                    break;
                default:
                    if (__catspeak_token_is_operator(succ)) {
                        implicit_semicolon = false;
                    }
                }
                if (implicit_semicolon) {
                    current = __CatspeakToken.SEMICOLON;
                } else {
                    // ignore this EOL character and try again
                    current = succ;
                    continue;
                }
                break;
            case __CatspeakToken.EOF:
                if not (eof) {
                    current = __CatspeakToken.SEMICOLON;
                    eof = true;
                }
                break;
            }
            pred = current;
            current = succ;
            return pred;
        }
    }
}

/// @desc Represents a type of compiler state.
enum __CatspeakCompilerState {
    PROGRAM,
    STATEMENT,
    SEQUENCE_BEGIN,
    SEQUENCE_END,
    SET_BEGIN,
    SET_END,
    IF_BEGIN,
    IF_ELSE,
    IF_END,
    WHILE_BEGIN,
    WHILE_END,
    PRINT,
    RETURN,
    POP_VALUE,
    EXPRESSION,
    BINARY_BEGIN,
    BINARY_END,
    RUN,
    CALL_BEGIN,
    CALL_END,
    ARG,
    SUBSCRIPT_BEGIN,
    SUBSCRIPT_END,
    TERMINAL,
    GROUPING_BEGIN,
    GROUPING_END,
    ARRAY,
    OBJECT
}

/// @desc Displays the compiler state as a string.
/// @param {__CatspeakCompilerState} state The state to display.
function __catspeak_compiler_state_render(_state) {
    switch (_state) {
    case __CatspeakCompilerState.PROGRAM: return "PROGRAM";
    case __CatspeakCompilerState.STATEMENT: return "STATEMENT";
    case __CatspeakCompilerState.SEQUENCE_BEGIN: return "SEQUENCE_BEGIN";
    case __CatspeakCompilerState.SEQUENCE_END: return "SEQUENCE_END";
    case __CatspeakCompilerState.SET_BEGIN: return "SET_BEGIN";
    case __CatspeakCompilerState.SET_END: return "SET_END";
    case __CatspeakCompilerState.IF_BEGIN: return "IF_BEGIN";
    case __CatspeakCompilerState.IF_ELSE: return "IF_ELSE";
    case __CatspeakCompilerState.IF_END: return "IF_END";
    case __CatspeakCompilerState.WHILE_BEGIN: return "WHILE_BEGIN";
    case __CatspeakCompilerState.WHILE_END: return "WHILE_END";
    case __CatspeakCompilerState.PRINT: return "PRINT";
    case __CatspeakCompilerState.RETURN: return "RETURN";
    case __CatspeakCompilerState.POP_VALUE: return "POP_VALUE";
    case __CatspeakCompilerState.EXPRESSION: return "EXPRESSION";
    case __CatspeakCompilerState.BINARY_BEGIN: return "BINARY_BEGIN";
    case __CatspeakCompilerState.BINARY_END: return "BINARY_END";
    case __CatspeakCompilerState.RUN: return "RUN";
    case __CatspeakCompilerState.CALL_BEGIN: return "CALL_BEGIN";
    case __CatspeakCompilerState.CALL_END: return "CALL_END";
    case __CatspeakCompilerState.ARG: return "ARG";
    case __CatspeakCompilerState.SUBSCRIPT_BEGIN: return "SUBSCRIPT_BEGIN";
    case __CatspeakCompilerState.SUBSCRIPT_END: return "SUBSCRIPT_END";
    case __CatspeakCompilerState.TERMINAL: return "TERMINAL";
    case __CatspeakCompilerState.GROUPING_BEGIN: return "GROUPING_BEGIN";
    case __CatspeakCompilerState.GROUPING_END: return "GROUPING_END";
    case __CatspeakCompilerState.ARRAY: return "ARRAY";
    case __CatspeakCompilerState.OBJECT: return "OBJECT";
    default: return "<unknown>";
    }
}

/// @desc Creates a new compiler that handles syntactic analysis and code generation.
/// @param {__CatspeakLexer} lexer The lexer to use to generate the intcode program.
/// @param {__CatspeakChunk} out The program to write code to.
function __CatspeakCompiler(_lexer, _out) constructor {
    lexer = _lexer;
    out = _out;
    token = __CatspeakToken.BOF;
    pos = lexer.getPosition();
    lexeme = lexer.getLexeme();
    peeked = lexer.next();
    instructionStack = [__CatspeakCompilerState.PROGRAM];
    storageStack = [];
    loopStack = [];
    loopCurrent = undefined;
    /// @desc Adds a new compiler state to the instruction stack.
    /// @param {__CatspeakCompilerState} state The state to insert.
    static pushState = function(_state) {
        array_push(instructionStack, _state);
    }
    /// @desc Pops the top state from the instruction stack.
    static popState = function() {
        return array_pop(instructionStack);
    }
    /// @desc Adds a new value to the storage stack.
    /// @param {value} value The value to store.
    /// @param {value} ... Additional values.
    static pushStorage = function() {
        for (var i = 0; i < argument_count; i += 1) {
            var value = argument[i];
            array_push(storageStack, value);
        }
    }
    /// @desc Pops the top value from the storage stack.
    /// @param {value} value The value to store.
    static popStorage = function() {
        return array_pop(storageStack);
    }
    /// @desc Adds a loop frame to the loop stack.
    static pushLoop = function(_state) {
        if (loopCurrent != undefined) {
            array_push(loopStack, loopCurrent);
        }
        loopCurrent = {
            pc : out.getCurrentSize(),
            breaks : []
        };
    }
    /// @desc Pops the top loop frame from the loop stack.
    static popLoop = function() {
        if (array_length(loopStack) > 0) {
            loopCurrent = array_pop(loopStack);
        } else {
            loopCurrent = undefined;
        }
    }
    /// @desc Returns the current buffer position.
    static getPosition = function() {
        return pos;
    }
    /// @desc Advances the parser and returns the token.
    static advance = function() {
        token = peeked;
        pos = lexer.getPosition();
        lexeme = lexer.getLexeme();
        peeked = lexer.next();
        return token;
    }
    /// @desc Returns true if the current token matches this token kind.
    /// @param {__CatspeakToken} kind The token kind to match.
    static matches = function(_kind) {
        return peeked == _kind;
    }
    /// @desc Returns true if the current token infers an expression.
    static matchesExpression = function() {
        return matches(__CatspeakToken.PAREN_LEFT)
                || matches(__CatspeakToken.BOX_LEFT)
                || matches(__CatspeakToken.BRACE_LEFT)
                || matches(__CatspeakToken.COLON)
                || matches(__CatspeakToken.IDENTIFIER)
                || matches(__CatspeakToken.STRING)
                || matches(__CatspeakToken.NUMBER);
    }
    /// @desc Returns true if the current token matches any kind of operator.
    static matchesOperator = function() {
        return __catspeak_token_is_operator(peeked);
    }
    /// @desc Attempts to match against a token and advances the parser if this was successful.
    /// @param {__CatspeakToken} kind The token kind to consume.
    static consume = function(_kind) {
        if (matches(_kind)) {
            advance();
            return true;
        } else {
            return false;
        }
    }
    /// @desc Throws a `__CatspeakError` for the current token.
    /// @param {string} on_error The error message.
    static error = function(_msg) {
        throw new __CatspeakError(pos, _msg + " -- got `" + string(lexeme) + "` (" + __catspeak_token_render(token) + ")");
    }
    /// @desc Advances the parser and throws a `CatspeakCompilerError` for the current token.
    /// @param {string} on_error The error message.
    static errorAndAdvance = function(_msg) {
        advance();
        error(_msg);
    }
    /// @desc Throws a `CatspeakCompilerError` if the current token is not the expected value. Advances the parser otherwise.
    /// @param {__CatspeakToken} kind The token kind to expect.
    /// @param {string} on_error The error message.
    static expects = function(_kind, _msg) {
        if (consume(_kind)) {
            return token;
        } else {
            errorAndAdvance(_msg);
            return undefined;
        }
    }
    /// @desc Throws a `CatspeakCompilerError` if the current token is not a semicolon. Advances the parser otherwise.
    /// @param {string} on_error The error message.
    static expectsSemicolon = function(_msg) {
        return expects(__CatspeakToken.SEMICOLON, "expected `;` or new line " + _msg);
    }
    /// @desc Returns whether the compiler is in progress.
    static inProgress = function() {
        return array_length(instructionStack) > 0;
    }
    /// @desc Performs a single step of parsing and code generation.
    static generateCode = function() {
        var state = popState();
        switch (state) {
        case __CatspeakCompilerState.PROGRAM:
            if not (matches(__CatspeakToken.EOF)) {
                pushState(__CatspeakCompilerState.PROGRAM);
                pushState(__CatspeakCompilerState.STATEMENT);
            }
            break;
        case __CatspeakCompilerState.STATEMENT:
            if (consume(__CatspeakToken.SEMICOLON)) {
                // do nothing
            } else if (consume(__CatspeakToken.SET)) {
                pushState(__CatspeakCompilerState.SET_BEGIN);
                pushState(__CatspeakCompilerState.ARG);
            } else if (consume(__CatspeakToken.IF)) {
                pushState(__CatspeakCompilerState.IF_BEGIN);
                pushState(__CatspeakCompilerState.ARG);
            } else if (consume(__CatspeakToken.WHILE)) {
                pushLoop();
                pushState(__CatspeakCompilerState.WHILE_BEGIN);
                pushState(__CatspeakCompilerState.ARG);
            } else if (consume(__CatspeakToken.PRINT)) {
                pushState(__CatspeakCompilerState.PRINT);
                pushState(__CatspeakCompilerState.ARG);
            } else if (consume(__CatspeakToken.RETURN)) {
                pushState(__CatspeakCompilerState.RETURN);
                pushState(__CatspeakCompilerState.ARG);
            } else {
                pushState(__CatspeakCompilerState.POP_VALUE);
                pushState(__CatspeakCompilerState.EXPRESSION);
            }
            break;
        case __CatspeakCompilerState.SEQUENCE_BEGIN:
            expects(__CatspeakToken.BRACE_LEFT, "expected opening `{` in sequence");
            pushState(__CatspeakCompilerState.SEQUENCE_END);
            break;
        case __CatspeakCompilerState.SEQUENCE_END:
            if not (consume(__CatspeakToken.BRACE_RIGHT)) {
                pushState(__CatspeakCompilerState.SEQUENCE_END);
                pushState(__CatspeakCompilerState.STATEMENT);
            }
            break;
        case __CatspeakCompilerState.SET_BEGIN:
            var top_pc = out.getCurrentSize() - 1;
            var top_inst = out.getCode(top_pc);
            switch (top_inst.code) {
            case __CatspeakOpCode.VAR_GET:
                pushStorage(__CatspeakOpCode.VAR_SET);
                break;
            case __CatspeakOpCode.REF_GET:
                pushStorage(__CatspeakOpCode.REF_SET);
                break;
            default:
                error("invalid assignment target");
                break;
            }
            out.removeCode(top_pc);
            pushStorage(top_inst.param);
            pushState(__CatspeakCompilerState.SET_END);
            pushState(__CatspeakCompilerState.ARG);
            break;
        case __CatspeakCompilerState.SET_END:
            expectsSemicolon("after assignment statements");
            var param = popStorage();
            var code = popStorage();
            out.addCode(pos, code, param);
            break;
        case __CatspeakCompilerState.IF_BEGIN:
            pushStorage(out.addCode(pos, __CatspeakOpCode.JUMP_FALSE, undefined));
            pushState(__CatspeakCompilerState.IF_ELSE);
            pushState(__CatspeakCompilerState.SEQUENCE_BEGIN);
            break;
        case __CatspeakCompilerState.IF_ELSE:
            pushState(__CatspeakCompilerState.IF_END);
            if (consume(__CatspeakToken.ELSE)) {
                var jump_if_pc = popStorage();
                pushStorage(out.addCode(pos, __CatspeakOpCode.JUMP, undefined));
                out.getCode(jump_if_pc).param = out.getCurrentSize();
                pushState(__CatspeakCompilerState.SEQUENCE_BEGIN);
            }
            break;
        case __CatspeakCompilerState.IF_END:
            var jump_if_pc = popStorage();
            out.getCode(jump_if_pc).param = out.getCurrentSize();
            break;
        case __CatspeakCompilerState.WHILE_BEGIN:
            pushStorage(out.addCode(pos, __CatspeakOpCode.JUMP_FALSE, undefined));
            pushState(__CatspeakCompilerState.WHILE_END);
            pushState(__CatspeakCompilerState.SEQUENCE_BEGIN);
            break;
        case __CatspeakCompilerState.WHILE_END:
            var jump_false_pc = popStorage();
            var start_pc = loopCurrent.pc;
            out.addCode(pos, __CatspeakOpCode.JUMP, start_pc);
            out.getCode(jump_false_pc).param = out.getCurrentSize();
            popLoop();
            break;
        case __CatspeakCompilerState.PRINT:
            expectsSemicolon("after print statements");
            out.addCode(pos, __CatspeakOpCode.PRINT);
            break;
        case __CatspeakCompilerState.RETURN:
            expectsSemicolon("after return statements");
            out.addCode(pos, __CatspeakOpCode.RETURN);
            break;
        case __CatspeakCompilerState.POP_VALUE:
            expectsSemicolon("after expression statements");
            out.addCode(pos, __CatspeakOpCode.POP);
            break;
        case __CatspeakCompilerState.EXPRESSION:
            pushStorage(__CatspeakToken.__OPERATORS_BEGIN__ + 1);
            pushState(__CatspeakCompilerState.BINARY_BEGIN);
            break;
        case __CatspeakCompilerState.BINARY_BEGIN:
            var precedence = popStorage();
            if (precedence >= __CatspeakToken.__OPERATORS_END__) {
                pushState(__CatspeakCompilerState.RUN);
                break;
            }
            pushStorage(precedence);
            pushState(__CatspeakCompilerState.BINARY_END);
            pushStorage(precedence + 1);
            pushState(__CatspeakCompilerState.BINARY_BEGIN);
            break;
        case __CatspeakCompilerState.BINARY_END:
            var precedence = popStorage();
            if (consume(precedence)) {
                out.addCode(pos, __CatspeakOpCode.VAR_GET, lexeme);
                pushStorage(precedence);
                pushState(__CatspeakCompilerState.BINARY_END);
                pushStorage(-1);
                pushState(__CatspeakCompilerState.CALL_END);
                pushStorage(precedence + 1);
                pushState(__CatspeakCompilerState.BINARY_BEGIN);
            }
            break;
        case __CatspeakCompilerState.RUN:
            if (consume(__CatspeakToken.RUN)) {
                pushStorage(0);
                pushState(__CatspeakCompilerState.CALL_END);
            } else if (matchesOperator()) {
                advance();
                out.addCode(pos, __CatspeakOpCode.VAR_GET, lexeme);
                pushStorage(1);
                pushState(__CatspeakCompilerState.CALL_END);
            } else {
                pushStorage(0);
                pushState(__CatspeakCompilerState.CALL_BEGIN);
            }
            pushState(__CatspeakCompilerState.ARG);
            break;
        case __CatspeakCompilerState.CALL_BEGIN:
            var arg_count = popStorage();
            if (matchesExpression()) {
                arg_count += 1;
                pushState(__CatspeakCompilerState.CALL_BEGIN);
                pushState(__CatspeakCompilerState.ARG);
            } else {
                if (arg_count <= 0) {
                    break;
                }
                pushState(__CatspeakCompilerState.CALL_END);
            }
            pushStorage(arg_count);
            break;
        case __CatspeakCompilerState.CALL_END:
            var arg_count = popStorage();
            out.addCode(pos, __CatspeakOpCode.CALL, arg_count);
            break;
        case __CatspeakCompilerState.ARG:
            pushState(__CatspeakCompilerState.SUBSCRIPT_BEGIN);
            pushState(__CatspeakCompilerState.TERMINAL);
            break;
        case __CatspeakCompilerState.SUBSCRIPT_BEGIN:
            if (consume(__CatspeakToken.DOT)) {
                pushState(__CatspeakCompilerState.SUBSCRIPT_END);
                var access_type;
                if (consume(__CatspeakToken.BOX_LEFT)) {
                    access_type = 0x00;
                    pushState(__CatspeakCompilerState.EXPRESSION);
                } else if (consume(__CatspeakToken.BRACE_LEFT)) {
                    access_type = 0x01;
                    pushState(__CatspeakCompilerState.EXPRESSION);
                } else {
                    access_type = 0x02;
                    expects(__CatspeakToken.IDENTIFIER, "expected identifier after binary `.` operator");
                    out.addCode(pos, __CatspeakOpCode.PUSH, lexeme);
                }
                pushStorage(access_type);
            }
            break;
        case __CatspeakCompilerState.SUBSCRIPT_END:
            var access_type = popStorage();
            var unordered;
            switch (access_type) {
            case 0x00:
                unordered = false;
                expects(__CatspeakToken.BOX_RIGHT, "expected closing `]` in ordered indexing");
                break;
            case 0x01:
                expects(__CatspeakToken.BRACE_RIGHT, "expected closing `}` in unordered indexing");
            default:
                unordered = true;
                break;
            }
            out.addCode(pos, __CatspeakOpCode.REF_GET, unordered);
            pushState(__CatspeakCompilerState.SUBSCRIPT_BEGIN);
            break;
        case __CatspeakCompilerState.TERMINAL:
            if (consume(__CatspeakToken.IDENTIFIER)) {
                out.addCode(pos, __CatspeakOpCode.VAR_GET, lexeme);
            } else if (matchesOperator()) {
                advance();
                out.addCode(pos, __CatspeakOpCode.VAR_GET, lexeme);
            } else if (consume(__CatspeakToken.STRING)) {
                out.addCode(pos, __CatspeakOpCode.PUSH, lexeme);
            } else if (consume(__CatspeakToken.NUMBER)) {
                out.addCode(pos, __CatspeakOpCode.PUSH, real(lexeme));
            } else {
                pushState(__CatspeakCompilerState.GROUPING_BEGIN);
            }
            break;
        case __CatspeakCompilerState.GROUPING_BEGIN:
            if (consume(__CatspeakToken.COLON)) {
                pushState(__CatspeakCompilerState.EXPRESSION);
            } else if (consume(__CatspeakToken.PAREN_LEFT)) {
                pushState(__CatspeakCompilerState.GROUPING_END);
                pushState(__CatspeakCompilerState.EXPRESSION);
            } else if (consume(__CatspeakToken.BOX_LEFT)) {
                pushStorage(0); // store the source position and array length
                pushState(__CatspeakCompilerState.ARRAY);
            } else if (consume(__CatspeakToken.BRACE_LEFT)) {
                pushStorage(0);
                pushState(__CatspeakCompilerState.OBJECT);
            } else {
                errorAndAdvance("unexpected symbol in expression");
            }
            break;
        case __CatspeakCompilerState.GROUPING_END:
            expects(__CatspeakToken.PAREN_RIGHT, "expected closing `)` in grouping");
            break;
        case __CatspeakCompilerState.ARRAY:
            var size = popStorage();
            while (consume(__CatspeakToken.SEMICOLON)) { }
            if (consume(__CatspeakToken.BOX_RIGHT)) {
                out.addCode(pos, __CatspeakOpCode.MAKE_ARRAY, size);
            } else {
                pushStorage(size + 1);
                pushState(__CatspeakCompilerState.ARRAY);
                pushState(__CatspeakCompilerState.EXPRESSION);
            }
            break;
        case __CatspeakCompilerState.OBJECT:
            var size = popStorage();
            while (consume(__CatspeakToken.SEMICOLON)) { }
            if (consume(__CatspeakToken.BRACE_RIGHT)) {
                out.addCode(pos, __CatspeakOpCode.MAKE_OBJECT, size);
            } else {
                pushStorage(size + 1);
                pushState(__CatspeakCompilerState.OBJECT);
                pushState(__CatspeakCompilerState.ARG);
                if (consume(__CatspeakToken.DOT)) {
                    expects(__CatspeakToken.IDENTIFIER, "expected identifier after unary `.` operator");
                    out.addCode(pos, __CatspeakOpCode.PUSH, lexeme);
                } else {
                    pushState(__CatspeakCompilerState.ARG);
                }
            }
            break;
        default:
            error("unknown compiler instruction `" + string(state) + "` (" + __catspeak_compiler_state_render(state) + ")");
            break;
        }
        if not (inProgress()) {
            // code generation complete, add a final return code
            out.addCode(pos, __CatspeakOpCode.PUSH, undefined);
            out.addCode(pos, __CatspeakOpCode.RETURN);
        }
    }
}

/// @desc Represents a kind of intcode.
enum __CatspeakOpCode {
    PUSH,
    POP,
    VAR_GET,
    VAR_SET,
    REF_GET,
    REF_SET,
    MAKE_ARRAY,
    MAKE_OBJECT,
    PRINT,
    RETURN,
    CALL,
    JUMP,
    JUMP_FALSE
}

/// @desc Displays the ir kind as a string.
/// @param {CatspeakIRKind} kind The ir kind to display.
function __catspeak_code_render(_kind) {
    switch (_kind) {
    case __CatspeakOpCode.PUSH: return "PUSH";
    case __CatspeakOpCode.POP: return "POP";
    case __CatspeakOpCode.VAR_GET: return "VAR_GET";
    case __CatspeakOpCode.VAR_SET: return "VAR_SET";
    case __CatspeakOpCode.REF_GET: return "REF_GET";
    case __CatspeakOpCode.REF_SET: return "REF_SET";
    case __CatspeakOpCode.MAKE_ARRAY: return "MAKE_ARRAY";
    case __CatspeakOpCode.MAKE_OBJECT: return "MAKE_OBJECT";
    case __CatspeakOpCode.PRINT: return "PRINT";
    case __CatspeakOpCode.RETURN: return "RETURN";
    case __CatspeakOpCode.CALL: return "CALL";
    case __CatspeakOpCode.JUMP: return "JUMP";
    case __CatspeakOpCode.JUMP_FALSE: return "JUMP_FALSE";
    default: return "<unknown>";
    }
}

/// @desc Represents a Catspeak intcode program with associated debug information.
function __CatspeakChunk() constructor {
    program = [];
    size = 0;
    /// @desc Returns the size of this chunk.
    static getCurrentSize = function() {
        return size;
    }
    /// @desc Returns an existing code at this program counter.
    /// @param {vector} pos The position of this piece of code.
    static getCode = function(_pos) {
        return program[_pos];
    }
    /// @desc Adds a code and its positional information to the program.
    /// @param {vector} pos The position of this piece of code.
    /// @param {value} code The piece of code to write.
    /// @param {value} param The parameter (if any) associated with this instruction.
    static addCode = function(_pos, _code, _param) {
        array_push(program, {
            pos : _pos,
            code : _code,
            param : _param
        });
        var pc = size;
        size += 1;
        return pc;
    }
    /// @desc Permanently removes a code from the program. Don't use this unless you know what you're doing.
    /// @param {vector} pos The position of this piece of code.
    static removeCode = function(_pos) {
        array_delete(program, _pos, 1);
        size -= 1;
    }
}

/// @desc Represents a type of configuration option.
enum __CatspeakVMOption {
    GLOBAL_VISIBILITY,
    INSTANCE_VISIBILITY,
    RESULT_HANDLER,
    POP_HANDLER
}

/// @desc Handles the execution of a single Catspeak chunk.
function __CatspeakVM() constructor {
    interface = { };
    binding = { };
    resultHandler = undefined;
    popHandler = undefined;
    chunks = [];
    chunkCount = 0;
    chunkID = 0;
    pc = 0;
    stackLimit = 8;
    stackSize = 0;
    stack = array_create(stackLimit);
    exposeGlobalScope = false;
    exposeInstanceScope = false;
    /// @desc Throws a `__CatspeakError` with the current program counter.
    /// @param {string} msg The error message.
    static error = function(_msg) {
        throw new __CatspeakError(chunks[chunkID].getCode(pc).pos, _msg);
    }
    /// @desc Adds a new chunk to the VM to execute.
    /// @param {__CatspeakChunk} chunk The chunk to execute code of.
    static addChunk = function(_chunk) {
        array_push(chunks, _chunk);
        chunkCount += 1;
    }
    /// @desc Rewinds the VM back to the first chunk.
    static rewind = function() {
        pc = 0;
        chunkID = 0;
    }
    /// @desc Terminates the chunk that is currently being executed and moves to the next one.
    static terminateChunk = function() {
        pc = 0;
        chunkID += 1;
    }
    /// @desc Returns whether the VM is in progress.
    static inProgress = function() {
        return chunkID < chunkCount;
    }
    /// @desc Gets the variable workspace for this context.
    static getWorkspace = function() {
        return binding;
    }
    /// @desc Inserts a new read-only global variable into the interface.
    /// @param {string} name The name of the variable.
    /// @param {value} value The value of the variable.
    static addConstant = function(_name, _value) {
        interface[$ _name] = _value;
    }
    /// @desc Inserts a new function into to the interface.
    /// @param {string} name The name of the function.
    /// @param {value} method_or_script_id The reference to the function.
    static addFunction = function(_name, _value) {
        var f = _value;
        if not (is_method(f)) {
            // this is so that unexposed functions cannot be enumerated
            // by a malicious user in order to access important functions
            f = method(undefined, f);
        }
        interface[$ _name] = f;
    }
    /// @desc Sets a configuration option.
    /// @param {CatspeakVMOption} option The option to configure.
    /// @param {bool} enable Whether to enable this option.
    static setOption = function(_option, _enable) {
        switch (_option) {
        case __CatspeakVMOption.GLOBAL_VISIBILITY:
            exposeGlobalScope = is_numeric(_enable) && _enable;
            break;
        case __CatspeakVMOption.INSTANCE_VISIBILITY:
            exposeInstanceScope = is_numeric(_enable) && _enable;
            break;
        case __CatspeakVMOption.RESULT_HANDLER:
            resultHandler = _enable;
            break;
        case __CatspeakVMOption.POP_HANDLER:
            popHandler = _enable;
            break;
        }
    }
    /// @desc Pushes a value onto the stack.
    /// @param {value} value The value to push.
    static push = function(_value) {
        stack[stackSize] = _value;
        stackSize += 1;
        if (stackSize >= stackLimit) {
            stackLimit *= 2;
            array_resize(stack, stackLimit);
        }
    }
    /// @desc Pops the top value from the stack.
    static pop = function() {
        if (stackSize < 1) {
            error("VM stack underflow");
            return undefined;
        }
        stackSize -= 1;
        return stack[stackSize];
    }
    /// @desc Pops `n`-many values from the stack.
    /// @param {real} n The number of elements to pop from the stack.
    static popMany = function(_n) {
        var values = array_create(_n);
        for (var i = _n - 1; i >= 0; i -= 1) {
            values[@ i] = pop();
        }
        return values;
    }
    /// @desc Pops `n`-many values from the stack and inserts them into a struct.
    /// @param {real} n The number of pairs to pop from the stack.
    static popManyKWArgs = function(_n) {
        var values = { };
        repeat (_n) {
            var value = pop();
            var key = pop();
            values[$ string(key)] = value;
        }
        return values;
    }
    /// @desc Returns the top value of the stack.
    static top = function() {
        if (stackSize < 1) {
            error("cannot peek into empty VM stack");
            return undefined;
        }
        return stack[stackSize - 1];
    }
    /// @desc Assigns a value to a variable in the current context.
    /// @param {string} name The name of the variable to add.
    /// @param {value} value The value to assign.
    static setVariable = function(_name, _value) {
        binding[$ _name] = _value;
    }
    /// @desc Gets a variable in the current context.
    /// @param {string} name The name of the variable to add.
    static getVariable = function(_name) {
        if (variable_struct_exists(binding, _name)) {
            return binding[$ _name];
        } else if (variable_struct_exists(interface, _name)) {
            return interface[$ _name];
        } else {
            return undefined;
        }
    }
    /// @desc Attempts to index into a container and returns its value.
    /// @param {value} container The container to index.
    /// @param {value} subscript The index to access.
    /// @param {bool} unordered Whether the container is unordered.
    static getIndex = function(_container, _subscript, _unordered) {
        var ty = typeof(_container);
        if (_unordered) {
            switch (ty) {
            case "struct":
                return _container[$ string(_subscript)];
            case "number":
            case "bool":
            case "int32":
            case "int64":
                if (exposeInstanceScope && instance_exists(_container)) {
                    return variable_instance_get(_container, _subscript);
                } else if (exposeGlobalScope && _container == global) {
                    return variable_global_get(_subscript);
                } else if (ds_exists(_container, ds_type_map)) {
                    return _container[? _subscript];
                }
            }
        } else {
            switch (ty) {
            case "array":
                return _container[_subscript];
            case "number":
            case "bool":
            case "int32":
            case "int64":
                if (ds_exists(_container, ds_type_list)) {
                    return _container[| _subscript];
                }
            }
        }
        var madlib = _unordered ? "un" : "";
        error("cannot index " + madlib + "ordered collection of type `" + ty + "`");
        return undefined;
    }
    /// @desc Attempts to assign a value to the index of a container.
    /// @param {value} container The container to index.
    /// @param {value} subscript The index to access.
    /// @param {bool} unordered Whether the container is unordered.
    /// @param {value} value The value to insert.
    static setIndex = function(_container, _subscript, _unordered, _value) {
        var ty = typeof(_container);
        if (_unordered) {
            switch (ty) {
            case "struct":
                _container[$ string(_subscript)] = _value;
                return;
            case "number":
            case "bool":
            case "int32":
            case "int64":
                if (exposeInstanceScope && instance_exists(_container)) {
                    variable_instance_set(_container, _subscript, _value);
                    return;
                } else if (exposeGlobalScope && _container == global) {
                    variable_global_set(_subscript, _value);
                    return;
                } else if (ds_exists(_container, ds_type_map)) {
                    _container[? _subscript] = _value;
                    return;
                }
            }
        } else {
            switch (ty) {
            case "array":
                _container[@ _subscript] = _value;
                return;
            case "number":
            case "bool":
            case "int32":
            case "int64":
                if (ds_exists(_container, ds_type_list)) {
                    _container[| _subscript] = _value;
                    return;
                }
            }
        }
        var madlib = _unordered ? " un" : "";
        error("cannot assign to " + madlib + "ordered collection of type `" + ty + "`");
        return undefined;
    }
    /// @desc Executes a single instruction and updates the program counter.
    static computeProgram = function() {
        var inst = chunks[chunkID].getCode(pc);
        switch (inst.code) {
        case __CatspeakOpCode.PUSH:
            var value = inst.param;
            push(value);
            break;
        case __CatspeakOpCode.POP:
            var value = pop();
            if (popHandler != undefined) {
                popHandler(value);
            }
            break;
        case __CatspeakOpCode.VAR_GET:
            var name = inst.param;
            var value = getVariable(name);
            push(value);
            break;
        case __CatspeakOpCode.VAR_SET:
            var name = inst.param;
            var value = pop();
            setVariable(name, value);
            break;
        case __CatspeakOpCode.REF_GET:
            var unordered = inst.param;
            var subscript = pop();
            var container = pop();
            var value = getIndex(container, subscript, unordered);
            push(value);
            break;
        case __CatspeakOpCode.REF_SET:
            var unordered = inst.param;
            var value = pop();
            var subscript = pop();
            var container = pop();
            setIndex(container, subscript, unordered, value);
            break;
        case __CatspeakOpCode.MAKE_ARRAY:
            var size = inst.param;
            var container = popMany(size);
            push(container);
            break;
        case __CatspeakOpCode.MAKE_OBJECT:
            var size = inst.param;
            var container = popManyKWArgs(size);
            push(container);
            break;
        case __CatspeakOpCode.PRINT:
            var value = pop();
            show_debug_message(value);
            break;
        case __CatspeakOpCode.JUMP:
            var new_pc = inst.param;
            pc = new_pc;
            return;
        case __CatspeakOpCode.JUMP_FALSE:
            var new_pc = inst.param;
            var value = pop();
            if not (is_numeric(value) && value) {
                pc = new_pc;
                return;
            }
            break;
        case __CatspeakOpCode.CALL:
            var arg_count = inst.param;
            var callsite, args;
            if (arg_count < 0) {
                // due to how the compiler is implemented, code for operators
                // is generated infix as `a op b`
                var b = pop();
                callsite = pop();
                var a = pop();
                args = [a, b];
            } else {
                args = popMany(arg_count);
                callsite = pop();
            }
            var ty = typeof(callsite);
            switch (ty) {
            case "method":
                var result = executeMethod(callsite, args);
                push(result);
                break;
            default:
                error("invalid call site of type `" + ty + "`");
                break;
            }
            break;
        case __CatspeakOpCode.RETURN:
            var value = pop();
            if (resultHandler != undefined) {
                resultHandler(value);
            }
            terminateChunk(); // complete execution
            return;
        default:
            error("unknown program instruction `" + string(inst.code) + "` (" + __catspeak_code_render(inst.code) + ")");
            break;
        }
        pc += 1;
    }
    /// @desc Calls a function using an array as the parameter array.
    /// @param {method} ind The id of the method to call.
    /// @param {array} variable The id of the array to pass as a parameter array to this script.
    static executeMethod = function(_f, _a) {
        switch(array_length(_a)){
        case 0: return _f();
        case 1: return _f(_a[0]);
        case 2: return _f(_a[0], _a[1]);
        case 3: return _f(_a[0], _a[1], _a[2]);
        case 4: return _f(_a[0], _a[1], _a[2], _a[3]);
        case 5: return _f(_a[0], _a[1], _a[2], _a[3], _a[4]);
        case 6: return _f(_a[0], _a[1], _a[2], _a[3], _a[4], _a[5]);
        case 7: return _f(_a[0], _a[1], _a[2], _a[3], _a[4], _a[5], _a[6]);
        case 8: return _f(_a[0], _a[1], _a[2], _a[3], _a[4], _a[5], _a[6], _a[7]);
        case 9: return _f(_a[0], _a[1], _a[2], _a[3], _a[4], _a[5], _a[6], _a[7], _a[8]);
        case 10: return _f(_a[0], _a[1], _a[2], _a[3], _a[4], _a[5], _a[6], _a[7], _a[8], _a[9]);
        case 11: return _f(_a[0], _a[1], _a[2], _a[3], _a[4], _a[5], _a[6], _a[7], _a[8], _a[9], _a[10]);
        case 12: return _f(_a[0], _a[1], _a[2], _a[3], _a[4], _a[5], _a[6], _a[7], _a[8], _a[9], _a[10], _a[11]);
        case 13: return _f(_a[0], _a[1], _a[2], _a[3], _a[4], _a[5], _a[6], _a[7], _a[8], _a[9], _a[10], _a[11], _a[12]);
        case 14: return _f(_a[0], _a[1], _a[2], _a[3], _a[4], _a[5], _a[6], _a[7], _a[8], _a[9], _a[10], _a[11], _a[12], _a[13]);
        case 15: return _f(_a[0], _a[1], _a[2], _a[3], _a[4], _a[5], _a[6], _a[7], _a[8], _a[9], _a[10], _a[11], _a[12], _a[13], _a[14]);
        case 16: return _f(_a[0], _a[1], _a[2], _a[3], _a[4], _a[5], _a[6], _a[7], _a[8], _a[9], _a[10], _a[11], _a[12], _a[13], _a[14], _a[15]);
        }
        error("argument count of " + string(array_length(_a)) + " is not supported");
        return undefined;
    }
}