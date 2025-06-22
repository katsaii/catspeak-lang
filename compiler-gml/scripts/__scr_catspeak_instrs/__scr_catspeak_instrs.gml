// hand-written Catspeak instructions, here be dragons
//
// see `__scr_catspeak_instrs_generated` for the automatically generated
// instructions

//# feather use syntax-errors

/// @ignore
function __catspeak_gml_exec_get_return() {
    static special = [undefined];
    return special;
}

/// @ignore
function __catspeak_gml_exec_get_break() {
    static special = [undefined];
    return special;
}

/// @ignore
function __catspeak_gml_exec_get_continue() {
    static special = [];
    return special;
}

/// @ignore
function __catspeak_gml_exec_get_error(exec) {
    var closure_ = method_get_self(exec);
    return catspeak_location_show(closure_[$ "dbg"], closure_.ctx[$ "filename"]);
}

/// @ignore
function __catspeak_instr_ret__() {
    var returnBox = __catspeak_gml_exec_get_return();
    returnBox[@ 0] = result();
    throw returnBox;
}

/// @ignore
function __catspeak_instr_brk__() {
    var breakBox = __catspeak_gml_exec_get_break();
    breakBox[@ 0] = result();
    throw breakBox;
}

/// @ignore
function __catspeak_instr_cont__() {
    throw __catspeak_gml_exec_get_continue();
}

/// @ignore
function __catspeak_instr_thrw__() {
    throw result();
}

/// @ignore
function __catspeak_instr_fclo__() {
    return method({
        ctx : ctx,
        body : body,
        locals : array_create(locals),
        dbg : dbg,
    }, __catspeak_function__);
}

/// @ignore
function __catspeak_instr_seq_stmts_0__() {
    return result();
}

/// @ignore
function __catspeak_instr_seq_stmts_1__() {
    stmts0();
    return result();
}

/// @ignore
function __catspeak_instr_seq_stmts_2__() {
    stmts0();
    stmts1();
    return result();
}

/// @ignore
function __catspeak_instr_seq_stmts_3__() {
    stmts0();
    stmts1();
    stmts2();
    return result();
}

/// @ignore
function __catspeak_instr_seq_stmts_4__() {
    stmts0();
    stmts1();
    stmts2();
    stmts3();
    return result();
}

/// @ignore
function __catspeak_instr_seq__() {
    var stmts_ = stmts;
    var n_ = n - 1;
    for (var i = 0; i < n_; i += 1) {
        var stmt = stmts_[i];
        stmt();
    }
    return result();
}

/// @ignore
function __catspeak_instr_get_l__() {
    return ctx.callee_.locals[idx];
}

/// @ignore
function __catspeak_instr_set_l__() {
    ctx.callee_.locals[idx] = value();
}

/// @ignore
function __catspeak_instr_get_g__() {
    return ctx.globals[$ name];
}

/// @ignore
function __catspeak_instr_set_g__() {
    ctx.globals[$ name] = value();
}

/// @ignore
function __catspeak_function__() {
    var ctx_ = ctx;
    var prevCallee = ctx_.callee_;
    ctx_.callee_ = self;
    var returnValue = body();
    ctx_.callee_ = prevCallee;
    /* TODO: repurpose
    if (doThrowValue) {
        if (is_struct(throwValue)) {
            var catspeakErr = "CATSPEAK RUNTIME ERROR -- " +
                    __catspeak_gml_exec_get_error(body);
            if (variable_struct_exists(throwValue, "message")) {
                // add where the error occurred (really bad implementation, might be good enough for now)
                throwValue.message = catspeakErr + ": " + throwValue.message;
            }
            if (variable_struct_exists(throwValue, "longMessage")) {
                // add where the error occurred (really bad implementation, might be good enough for now)
                throwValue.longMessage += "\n-----\n" + catspeakErr + "\n";
            }
        }
        throw throwValue;
    }
    */
    return returnValue;
}

/// @ignore
function __catspeak_catch_return__() {
    var returnValue = undefined;
    try {
        returnValue = body();
    } catch (err_) {
        if (err_ == __catspeak_gml_exec_get_return()) {
            returnValue = err_[0];
        } else {
            throw err_;
        }
    }
    return returnValue;
}

/// @ignore
function __catspeak_catch_break__() {
    var returnValue = undefined;
    try {
        returnValue = body();
    } catch (err_) {
        if (err_ == __catspeak_gml_exec_get_break()) {
            returnValue = err_[0];
        } else {
            throw err_;
        }
    }
    return returnValue;
}

/// @ignore
function __catspeak_catch_continue__() {
    try {
        body();
    } catch (err_) {
        if (err_ != __catspeak_gml_exec_get_continue()) {
            throw err_;
        }
    }
}