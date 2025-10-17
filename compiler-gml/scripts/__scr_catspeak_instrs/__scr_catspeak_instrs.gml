// hand-written Catspeak instructions, here be dragons
//
// see `__scr_catspeak_instrs_generated` for the automatically generated
// instructions

//# feather use syntax-errors

/// @ignore
function __catspeak_gml_exec_get_error(exec) {
    var closure_ = method_get_self(exec);
    return catspeak_location_show(closure_[$ "dbg"], closure_.ctx[$ "filename"]);
}

/// @ignore
function __catspeak_gml_exec_get_unwind() {
    static unwindBox = { label : undefined, value : undefined };
    return unwindBox;
}

/// @ignore
function __catspeak_instr_thrw__() {
    throw result();
}

/// @ignore
function __catspeak_instr_cat__() {
    var returnValue = undefined;
    try {
        returnValue = eager();
    } catch (err_) {
        if (err_ == __catspeak_gml_exec_get_unwind()) {
            throw err_;
        }
        ctx.callee_.locals[idx] = err_;
        returnValue = lazy();
    }
    return returnValue;
}

/// @ignore
function __catspeak_instr_uwnd__() {
    var unwindBox = __catspeak_gml_exec_get_unwind();
    unwindBox.label = label;
    unwindBox.value = result();
    throw unwindBox;
}

/// @ignore
function __catspeak_instr_cat_uwnd__() {
    var returnValue = undefined;
    try {
        returnValue = body();
    } catch (err_) {
        if (err_ == __catspeak_gml_exec_get_unwind() && label == err_.label) {
            returnValue = err_.value;
            err_.label = undefined;
            err_.value = undefined;
        } else {
            throw err_;
        }
    }
    return returnValue;
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
function __catspeak_instr_fclo__() {
    var body_ = body;
    return method({
        ctx : ctx,
        body : body_,
        locals : array_create(locals),
        dbg : dbg,
    }, __catspeak_function__);
}

/// @ignore
function __catspeak_function__() {
    var ctx_ = ctx;
    var prevCallee = ctx_.callee_;
    ctx_.callee_ = self;
    var returnValue = body();
    ctx_.callee_ = prevCallee;
    return returnValue;
}

/// @ignore
function __catspeak_instr_get_l__() {
    return ctx.callee_.locals[idx];
}

/// @ignore
function __catspeak_instr_set_l_multiply__() {
    ctx.callee_.locals[idx] *= value();
}

/// @ignore
function __catspeak_instr_set_l_divide__() {
    ctx.callee_.locals[idx] /= value();
}

/// @ignore
function __catspeak_instr_set_l_add__() {
    ctx.callee_.locals[idx] += value();
}

/// @ignore
function __catspeak_instr_set_l_subtract__() {
    ctx.callee_.locals[idx] -= value();
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
function __catspeak_instr_set_g_multiply__() {
    ctx.globals[$ name] *= value();
}

/// @ignore
function __catspeak_instr_set_g_divide__() {
    ctx.globals[$ name] /= value();
}

/// @ignore
function __catspeak_instr_set_g_add__() {
    ctx.globals[$ name] += value();
}

/// @ignore
function __catspeak_instr_set_g_subtract__() {
    ctx.globals[$ name] -= value();
}

/// @ignore
function __catspeak_instr_set_g__() {
    ctx.globals[$ name] = value();
}