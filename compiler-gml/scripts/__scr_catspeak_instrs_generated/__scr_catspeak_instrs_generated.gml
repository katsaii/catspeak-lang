// AUTO GENERATED, DO NOT MODIFY THIS FILE
// see:
//  - https://github.com/katsaii/catspeak-lang/blob/main/compiler-compiler/def-catspeak-ir-outdated.yaml
//  - https://github.com/katsaii/catspeak-lang/blob/main/compiler-compiler/build-ir-gml.py
//  - __scr_catspeak_instrs_generated.gml

//# feather use syntax-errors

/// @ignore
function __catspeak_instr_ifte__() {
    return condition() ? if_true() : if_false();
}

/// @ignore
function __catspeak_instr_or__() {
    return eager() || lazy();
}

/// @ignore
function __catspeak_instr_xor__() {
    return lhs() ^^ rhs();
}

/// @ignore
function __catspeak_instr_and__() {
    return eager() && lazy();
}

/// @ignore
function __catspeak_instr_eq__() {
    return lhs() == rhs();
}

/// @ignore
function __catspeak_instr_neq__() {
    return lhs() != rhs();
}

/// @ignore
function __catspeak_instr_lt__() {
    return lhs() < rhs();
}

/// @ignore
function __catspeak_instr_leq__() {
    return lhs() <= rhs();
}

/// @ignore
function __catspeak_instr_gt__() {
    return lhs() > rhs();
}

/// @ignore
function __catspeak_instr_geq__() {
    return lhs() >= rhs();
}

/// @ignore
function __catspeak_instr_band__() {
    return lhs() & rhs();
}

/// @ignore
function __catspeak_instr_bor__() {
    return lhs() | rhs();
}

/// @ignore
function __catspeak_instr_bxor__() {
    return lhs() ^ rhs();
}

/// @ignore
function __catspeak_instr_lshift__() {
    return value() << amount();
}

/// @ignore
function __catspeak_instr_rshift__() {
    return value() >> amount();
}

/// @ignore
function __catspeak_instr_add__() {
    return lhs() + rhs();
}

/// @ignore
function __catspeak_instr_sub__() {
    return lhs() - rhs();
}

/// @ignore
function __catspeak_instr_mult__() {
    return lhs() * rhs();
}

/// @ignore
function __catspeak_instr_div__() {
    return lhs() / rhs();
}

/// @ignore
function __catspeak_instr_idiv__() {
    return lhs() div rhs();
}

/// @ignore
function __catspeak_instr_rem__() {
    return lhs() % rhs();
}

/// @ignore
function __catspeak_instr_pos__() {
    return +value();
}

/// @ignore
function __catspeak_instr_neg__() {
    return -value();
}

/// @ignore
function __catspeak_instr_not__() {
    return !value();
}

/// @ignore
function __catspeak_instr_bnot__() {
    return ~value();
}

/// @ignore
function __catspeak_instr_get_n__() {
    return value;
}

/// @ignore
function __catspeak_instr_get_s__() {
    return value;
}

/// @ignore
function __catspeak_instr_get_u__() {
    return undefined;
}

function __catspeak_const_value__() {
    return value;
}