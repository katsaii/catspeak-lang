//! Initialises core components of the Catspeak compiler. This includes
//! any uninitialised global variables.

//      _             _                                                       
//     |  `.       .'  |                   _                             _    
//     |    \_..._/    |                  | |                           | |   
//    /    _       _    \     |\_/|  __ _ | |_  ___  _ __    ___   __ _ | | __
// `-|    / \     / \    |-'  / __| / _` || __|/ __|| '_ \  / _ \ / _` || |/ /
// --|    | |     | |    |-- | (__ | (_| || |_ \__ \| |_) ||  __/| (_| ||   < 
//  .'\   \_/ _._ \_/   /`.   \___| \__,_| \__||___/| .__/  \___| \__,_||_|\_\
//     `~..______    .~'                       _____| |   by: katsaii         
//               `.  |                        / ._____/ logo: mashmerlow      
//                 `.|                        \_)                             

//# feather use syntax-errors

/// The compiler version, should be updated before each release.
#macro CATSPEAK_VERSION "2.0.0"

/// Makes sure that all Catspeak global variables are initialised. Only needs
/// to be called if you are trying to use Catspeak from a script, or through
/// `gml_pragma`. Otherwise you can just ignore this.
function catspeak_force_init() {
    static initialised = false;
    if (initialised) {
        return;
    }
    initialised = true;
    // call initialisers
    __catspeak_init_process();
    __catspeak_init_alloc();
    __catspeak_init_database_prelude();
    __catspeak_init_database_token_starts_expression();
    __catspeak_init_database_token_skips_line();
    __catspeak_init_database_token_keywords();
    __catspeak_init_database_token();
    __catspeak_init_database_ascii_desc();
    // display the initialisation message
    var motd = "you are now using Catspeak v" +
            CATSPEAK_VERSION + " by @katsaii";
    show_debug_message(motd);
}

catspeak_force_init();

/// @ignore
function __catspeak_init_process() {
    var info = {
        processes : ds_list_create(),
        // only compute Catspeak programs for half of a frame
        frameAllocation : 0.5,
        processTimeLimit : 1,
        exceptionHandler : undefined,
        dtRatioCache : 1,
        inactive : true,
        update : function() {
            var oneSecond = frameAllocation * 1000000;
            var idealTime = game_get_speed(gamespeed_microseconds);
            var dtRatio = delta_time / idealTime;
            dtRatioCache = max(1, dtRatioCache - 0.1, dtRatio);
            var duration = frameAllocation * idealTime / dtRatioCache;
            var timeLimit = get_timer() + min(idealTime, duration);
            var processes_ = processes;
            var processIdx = 0;
            var processCount = ds_list_size(processes_);
            var exceptionHandler_ = exceptionHandler;
            // TODO :: add a method of detecting whether a process has
            //         become unresponsive
            do {
                var tStart = get_timer();
                if (processCount < 1) {
                    // don't waste time waiting for new processes to exist
                    time_source_stop(timeSource);
                    inactive = true;
                    break;
                }
                var process = processes_[| processIdx];
                var catchFun = process.callbackCatch ?? exceptionHandler_;
                var terminate = false;
                var errorOccurred = false;
                if (process.isBusy()) {
                    if (catchFun == undefined) {
                        // helps preserve the throw origin in the debugger
                        process.update();
                    } else {
                        try {
                            process.update();
                        } catch (e) {
                            catchFun(e);
                            terminate = true;
                            errorOccurred = true;
                        }
                    }
                } else {
                    terminate = true;
                }
                if (terminate) {
                    ds_list_delete(processes_, processIdx);
                    process.used = false;
                    // TODO :: pool processes to avoid constant allocation
                    if (!errorOccurred) {
                        var resultFun = process.callback;
                        if (resultFun != undefined) {
                            resultFun(process.result());
                        }
                    }
                } else {
                    var tSpent = process.timeSpent;
                    process.timeSpent = tSpent + (get_timer() - tStart);
                    if (tSpent > process.timeLimit * oneSecond) {
                        var err = new CatspeakError(undefined,
                                "exceeded process time limit");
                        if (catchFun == undefined) {
                            throw err;
                        } else {
                            catchFun(err);
                        }
                    }
                }
                processCount = ds_list_size(processes_);
                processIdx -= 1;
                if (processIdx < 0) {
                    processIdx = processCount - 1;
                }
            } until (get_timer() > timeLimit);
        },
    };
    info.timeSource = time_source_create(
                time_source_global, 1, time_source_units_frames,
                info.update, [], -1);
    /// @ignore
    global.__catspeakProcessManager = info;
}

/// @ignore
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
function __catspeak_init_database_prelude() {
    var db = { };
    var funcs = [
        "+", __catspeak_builtin_add,
        "++", __catspeak_builtin_add_string,
        "-", __catspeak_builtin_sub,
        "*", __catspeak_builtin_mul,
        "/", __catspeak_builtin_div,
        "%", __catspeak_builtin_mod,
        "//", __catspeak_builtin_div_int,
        "|", __catspeak_builtin_bit_or,
        "&", __catspeak_builtin_bit_and,
        "^", __catspeak_builtin_bit_xor,
        "~", __catspeak_builtin_bit_not,
        "<<", __catspeak_builtin_bit_lshift,
        ">>", __catspeak_builtin_bit_rshift,
        "||", __catspeak_builtin_or,
        "&&", __catspeak_builtin_and,
        "^^", __catspeak_builtin_xor,
        "!", __catspeak_builtin_not,
        "==", __catspeak_builtin_eq,
        "!=", __catspeak_builtin_neq,
        ">=", __catspeak_builtin_geq,
        "<=", __catspeak_builtin_leq,
        ">", __catspeak_builtin_gt,
        "<", __catspeak_builtin_lt,
        "[]", __catspeak_builtin_get,
        "[]=", __catspeak_builtin_set,
        "len", __catspeak_builtin_length,
        "print", __catspeak_builtin_print,
        "bool", bool,
        "string", string,
        "real", real,
        "int64", int64,
        "typeof", typeof,
        "instanceof", instanceof,
        "is_array", is_array,
        "is_bool", is_bool,
        "is_infinity", is_infinity,
        "is_int32", is_int32,
        "is_int64", is_int64,
        "is_method", is_method,
        "is_nan", is_nan,
        "is_numeric", is_numeric,
        "is_ptr", is_ptr,
        "is_real", is_real,
        "is_string", is_string,
        "is_struct", is_struct,
        "is_undefined", is_undefined,
        "is_vec3", is_vec3,
        "is_vec4", is_vec4,
    ];
    for (var i = 0; i < array_length(funcs); i += 2) {
        db[$ funcs[i + 0]] = method(undefined, funcs[i + 1]);
    }
    var consts = [
        "null", pointer_null,
        "undefiend", undefined,
        "true", true,
        "false", false,
        "NaN", NaN,
        "infinity", infinity,
    ];
    for (var i = 0; i < array_length(consts); i += 2) {
        db[$ consts[i + 0]] = consts[i + 1];
    }
    /// @ignore
    global.__catspeakDatabasePrelude = db;
}

/// @ignore
function __catspeak_init_database_token_starts_expression() {
    var db = array_create(catspeak_token_sizeof(), true);
    var exceptions = [
        CatspeakToken.PAREN_RIGHT,
        CatspeakToken.BOX_RIGHT,
        CatspeakToken.BRACE_RIGHT,
        CatspeakToken.DOT,
        CatspeakToken.COLON,
        CatspeakToken.COMMA,
        CatspeakToken.ASSIGN,
        CatspeakToken.BREAK_LINE,
        CatspeakToken.CONTINUE_LINE,
        CatspeakToken.ELSE,
        CatspeakToken.LET,
        CatspeakToken.WHITESPACE,
        CatspeakToken.COMMENT,
        CatspeakToken.EOL,
        CatspeakToken.BOF,
        CatspeakToken.EOF,
        CatspeakToken.OTHER,
        CatspeakToken.OP_LOW,
        CatspeakToken.OP_OR,
        CatspeakToken.OP_AND,
        CatspeakToken.OP_COMP,
        CatspeakToken.OP_ADD,
        CatspeakToken.OP_MUL,
        CatspeakToken.OP_DIV,
        CatspeakToken.OP_HIGH,
    ];
    var count = array_length(exceptions);
    for (var i = 0; i < count; i += 1) {
        db[@ catspeak_token_valueof(exceptions[i])] = false;
    }
    /// @ignore
    global.__catspeakDatabaseTokenStartsExpression = db;
}

/// @ignore
function __catspeak_init_database_token_skips_line() {
    var db = array_create(catspeak_token_sizeof(), false);
    var tokens = [
        // !! DO NOT ADD `BREAK_LINE` HERE, IT WILL RUIN EVERYTHING !!
        //              you have been warned... (*^_^*) b
        CatspeakToken.PAREN_LEFT,
        CatspeakToken.BOX_LEFT,
        CatspeakToken.BRACE_LEFT,
        CatspeakToken.DOT,
        CatspeakToken.COLON,
        CatspeakToken.COMMA,
        CatspeakToken.ASSIGN,
        // this token technically does, but it's handled in a different
        // way to the others, so it's only here honorarily
        //CatspeakToken.CONTINUE_LINE,
        CatspeakToken.DO,
        CatspeakToken.IF,
        CatspeakToken.ELSE,
        CatspeakToken.WHILE,
        CatspeakToken.FOR,
        CatspeakToken.LET,
        CatspeakToken.FUN,
        CatspeakToken.OP_LOW,
        CatspeakToken.OP_OR,
        CatspeakToken.OP_AND,
        CatspeakToken.OP_COMP,
        CatspeakToken.OP_ADD,
        CatspeakToken.OP_MUL,
        CatspeakToken.OP_DIV,
        CatspeakToken.OP_HIGH,
    ];
    var count = array_length(tokens);
    for (var i = 0; i < count; i += 1) {
        db[@ catspeak_token_valueof(tokens[i])] = true;
    }
    /// @ignore
    global.__catspeakDatabaseTokenSkipsLine = db;
}

/// @ignore
function __catspeak_init_database_token_keywords() {
    var db = { };
    db[$ "--"] = CatspeakToken.COMMENT;
    db[$ "="] = CatspeakToken.ASSIGN;
    db[$ ":"] = CatspeakToken.COLON;
    db[$ ";"] = CatspeakToken.BREAK_LINE;
    db[$ "."] = CatspeakToken.DOT;
    db[$ "..."] = CatspeakToken.CONTINUE_LINE;
    db[$ "do"] = CatspeakToken.DO;
    db[$ "it"] = CatspeakToken.IT;
    db[$ "if"] = CatspeakToken.IF;
    db[$ "else"] = CatspeakToken.ELSE;
    db[$ "while"] = CatspeakToken.WHILE;
    db[$ "for"] = CatspeakToken.FOR;
    db[$ "loop"] = CatspeakToken.LOOP;
    db[$ "let"] = CatspeakToken.LET;
    db[$ "fun"] = CatspeakToken.FUN;
    db[$ "break"] = CatspeakToken.BREAK;
    db[$ "continue"] = CatspeakToken.CONTINUE;
    db[$ "return"] = CatspeakToken.RETURN;
    db[$ "and"] = CatspeakToken.AND;
    db[$ "or"] = CatspeakToken.OR;
    db[$ "new"] = CatspeakToken.NEW;
    db[$ "impl"] = CatspeakToken.IMPL;
    /// @ignore
    global.__catspeakDatabaseLexemeToKeyword = db;
}

/// @ignore
function __catspeak_init_database_ascii_desc() {
    var db = array_create(256, CatspeakASCIIDesc.NONE);
    var mark = __catspeak_init_database_ascii_desc_mark;
    mark(db, [
        0x09, // CHARACTER TABULATION ('\t')
        0x0A, // LINE FEED ('\n')
        0x0B, // LINE TABULATION ('\v')
        0x0C, // FORM FEED ('\f')
        0x0D, // CARRIAGE RETURN ('\r')
        0x20, // SPACE (' ')
        0x85, // NEXT LINE
    ], CatspeakASCIIDesc.WHITESPACE);
    mark(db, [
        0x0A, // LINE FEED ('\n')
        0x0D, // CARRIAGE RETURN ('\r')
    ], CatspeakASCIIDesc.NEWLINE);
    mark(db, function (char) {
        return char >= ord("a") && char <= ord("z")
                || char >= ord("A") && char <= ord("Z");
    }, CatspeakASCIIDesc.ALPHABETIC
            | CatspeakASCIIDesc.GRAPHIC
            | CatspeakASCIIDesc.IDENT);
    mark(db, ["_", "'"],
            CatspeakASCIIDesc.GRAPHIC | CatspeakASCIIDesc.IDENT);
    mark(db, function (char) {
        return char >= ord("0") && char <= ord("9");
    }, CatspeakASCIIDesc.DIGIT
            | CatspeakASCIIDesc.GRAPHIC
            | CatspeakASCIIDesc.IDENT);
    mark(db, [
        "!", "#", "$", "%", "&", "*", "+", "-", ".", "/", ":", ";", "<",
        "=", ">", "?", "@", "\\", "^", "|", "~",
    ], CatspeakASCIIDesc.OPERATOR | CatspeakASCIIDesc.IDENT);
    /// @ignore
    global.__catspeakDatabaseByteToASCIIDesc = db;
}

/// @ignore
function __catspeak_init_database_ascii_desc_mark(db, query, value) {
    if (!is_array(query)) {
        query = [query];
    }
    var count = array_length(query);
    var countDb = array_length(db);
    for (var i = 0; i < count; i += 1) {
        var queryItem = query[i];
        if (is_method(queryItem)) {
            for (var i = 0; i < countDb; i += 1) {
                if (queryItem(i)) {
                    db[@ i] |= value;
                }
            }
            continue;
        }
        var byte = is_string(queryItem) ? ord(queryItem) : queryItem;
        db[@ byte] |= value;
    }
}

/// @ignore
function __catspeak_init_database_token() {
    var db = array_create(256, CatspeakToken.OTHER);
    var mark = __catspeak_init_database_token_mark;
    mark(db, [
        0x09, // CHARACTER TABULATION ('\t')
        0x0B, // LINE TABULATION ('\v')
        0x0C, // FORM FEED ('\f')
        0x20, // SPACE (' ')
        0x85, // NEXT LINE
    ], CatspeakToken.WHITESPACE);
    mark(db, [
        0x0A, // LINE FEED ('\n')
        0x0D, // CARRIAGE RETURN ('\r')
    ], CatspeakToken.BREAK_LINE);
    mark(db, function (char) {
        return char >= ord("a") && char <= ord("z")
                || char >= ord("A") && char <= ord("Z")
                || char == ord("_")
                || char == ord("'")
                || char == ord("`");
    }, CatspeakToken.IDENT);
    mark(db, function (char) {
        return char >= ord("0") && char <= ord("9");
    }, CatspeakToken.NUMBER);
    mark(db, ["$", ":", ";"], CatspeakToken.OP_LOW);
    mark(db, ["^", "|"], CatspeakToken.OP_OR);
    mark(db, ["&"], CatspeakToken.OP_AND);
    mark(db, [
        "!", "<", "=", ">", "?", "~"
    ], CatspeakToken.OP_COMP);
    mark(db, ["+", "-"], CatspeakToken.OP_ADD);
    mark(db, ["*", "/"], CatspeakToken.OP_MUL);
    mark(db, ["%", "\\"], CatspeakToken.OP_DIV);
    mark(db, ["#", ".", "@"], CatspeakToken.OP_HIGH);
    mark(db, "\"", CatspeakToken.STRING);
    mark(db, "(", CatspeakToken.PAREN_LEFT);
    mark(db, ")", CatspeakToken.PAREN_RIGHT);
    mark(db, "[", CatspeakToken.BOX_LEFT);
    mark(db, "]", CatspeakToken.BOX_RIGHT);
    mark(db, "{", CatspeakToken.BRACE_LEFT);
    mark(db, "}", CatspeakToken.BRACE_RIGHT);
    mark(db, ",", CatspeakToken.COMMA);
    /// @ignore
    global.__catspeakDatabaseByteToToken = db;
}

/// @ignore
function __catspeak_init_database_token_mark(db, query, value) {
    if (!is_array(query)) {
        query = [query];
    }
    var count = array_length(query);
    var countDb = array_length(db);
    for (var i = 0; i < count; i += 1) {
        var queryItem = query[i];
        if (is_method(queryItem)) {
            for (var i = 0; i < countDb; i += 1) {
                if (queryItem(i)) {
                    db[@ i] = value;
                }
            }
            continue;
        }
        var byte = is_string(queryItem) ? ord(queryItem) : queryItem;
        db[@ byte] = value;
    }
}
