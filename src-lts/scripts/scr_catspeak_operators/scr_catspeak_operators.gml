//! Catspeak operator database.

//# feather use syntax-errors

/// Represents the set of pure operators used by the Catspeak runtime and
/// compile-time constant folding.
enum CatspeakOperator {
    /// The remainder `%` operator.
    REMAINDER,
    /// The `*` operator.
    MULTIPLY,
    /// The `/` operator.
    DIVIDE,
    /// The integer division `//` operator.
    DIVIDE_INT,
    /// The `-` operator.
    SUBTRACT,
    /// The `+` operator.
    PLUS,
    /// The `==` operator.
    EQUAL,
    /// The `!=` operator.
    NOT_EQUAL,
    /// The `>` operator.
    GREATER,
    /// The `>=` operator.
    GREATER_EQUAL,
    /// The `<` operator.
    LESS,
    /// The `<=` operator.
    LESS_EQUAL,
    /// The logical negation `!` operator.
    NOT,
    /// The bitwise negation `~` operator.
    BITWISE_NOT,
    /// The bitwise right shift `>>` operator.
    SHIFT_RIGHT,
    /// The bitwise left shift `<<` operator.
    SHIFT_LEFT,
    /// The bitwise and `&` operator.
    BITWISE_AND,
    /// The bitwise xor `^` operator.
    BITWISE_XOR,
    /// The bitwise or `|` operator.
    BITWISE_OR,
    __SIZE__,
}

/// Represents the set of assignment operators understood by Catspeak.
enum CatspeakAssign {
    /// The typical `=` assignment.
    VANILLA,
    /// Multiply assign `*=`.
    MULTIPLY,
    /// Division assign `/=`.
    DIVIDE,
    /// Subtract assign `-=`.
    SUBTRACT,
    /// Plus assign `+=`.
    PLUS,
    __SIZE__,
}

/// @ignore
///
/// @param {Enum.CatspeakToken} token
/// @return {Enum.CatspeakOperator}
function __catspeak_operator_from_token(token) {
    return token - CatspeakToken.__OP_BEGIN__ - 1;
}

/// @ignore
///
/// @param {Enum.CatspeakToken} token
/// @return {Enum.CatspeakAssign}
function __catspeak_operator_assign_from_token(token) {
    return token - CatspeakToken.__OP_ASSIGN_BEGIN__ - 1;
}

/// @ignore
///
/// @param {Enum.CatspeakOperator} op
/// @return {Function}
function __catspeak_operator_get_binary(op) {
    var opFunc = global.__catspeakBinOps[op];
    if (CATSPEAK_DEBUG_MODE && opFunc == undefined) {
        __catspeak_error_bug();
    }
    return opFunc;
}

/// @ignore
///
/// @param {Enum.CatspeakOperator} op
/// @return {Function}
function __catspeak_operator_get_unary(op) {
    var opFunc = global.__catspeakUnaryOps[op];
    if (CATSPEAK_DEBUG_MODE && opFunc == undefined) {
        __catspeak_error_bug();
    }
    return opFunc;
}

/// @ignore
///
/// @param {Any} lhs
/// @param {Any} rhs
/// @return {Any}
function __catspeak_op_remainder(lhs, rhs) {
    return lhs % rhs;
}

/// @ignore
///
/// @param {Any} lhs
/// @param {Any} rhs
/// @return {Any}
function __catspeak_op_multiply(lhs, rhs) {
    return lhs * rhs;
}

/// @ignore
///
/// @param {Any} lhs
/// @param {Any} rhs
/// @return {Any}
function __catspeak_op_divide(lhs, rhs) {
    return lhs / rhs;
}

/// @ignore
///
/// @param {Any} lhs
/// @param {Any} rhs
/// @return {Any}
function __catspeak_op_divide_int(lhs, rhs) {
    return lhs div rhs;
}

/// @ignore
///
/// @param {Any} lhs
/// @param {Any} rhs
/// @return {Any}
function __catspeak_op_subtract(lhs, rhs) {
    return lhs - rhs;
}

/// @ignore
///
/// @param {Any} lhs
/// @param {Any} rhs
/// @return {Any}
function __catspeak_op_plus(lhs, rhs) {
    return lhs + rhs;
}

/// @ignore
///
/// @param {Any} lhs
/// @param {Any} rhs
/// @return {Any}
function __catspeak_op_equal(lhs, rhs) {
    return lhs == rhs;
}

/// @ignore
///
/// @param {Any} lhs
/// @param {Any} rhs
/// @return {Any}
function __catspeak_op_not_equal(lhs, rhs) {
    return lhs != rhs;
}

/// @ignore
///
/// @param {Any} lhs
/// @param {Any} rhs
/// @return {Any}
function __catspeak_op_greater(lhs, rhs) {
    return lhs > rhs;
}

/// @ignore
///
/// @param {Any} lhs
/// @param {Any} rhs
/// @return {Any}
function __catspeak_op_greater_equal(lhs, rhs) {
    return lhs >= rhs;
}

/// @ignore
///
/// @param {Any} lhs
/// @param {Any} rhs
/// @return {Any}
function __catspeak_op_less(lhs, rhs) {
    return lhs < rhs;
}

/// @ignore
///
/// @param {Any} lhs
/// @param {Any} rhs
/// @return {Any}
function __catspeak_op_less_equal(lhs, rhs) {
    return lhs <= rhs;
}

/// @ignore
///
/// @param {Any} lhs
/// @param {Any} rhs
/// @return {Any}
function __catspeak_op_shift_right(lhs, rhs) {
    return lhs >> rhs;
}

/// @ignore
///
/// @param {Any} lhs
/// @param {Any} rhs
/// @return {Any}
function __catspeak_op_shift_left(lhs, rhs) {
    return lhs << rhs;
}

/// @ignore
///
/// @param {Any} lhs
/// @param {Any} rhs
/// @return {Any}
function __catspeak_op_bitwise_and(lhs, rhs) {
    return lhs & rhs;
}

/// @ignore
///
/// @param {Any} lhs
/// @param {Any} rhs
/// @return {Any}
function __catspeak_op_bitwise_xor(lhs, rhs) {
    return lhs ^ rhs;
}

/// @ignore
///
/// @param {Any} lhs
/// @param {Any} rhs
/// @return {Any}
function __catspeak_op_bitwise_or(lhs, rhs) {
    return lhs | rhs;
}

/// @ignore
///
/// @param {Any} rhs
/// @return {Any}
function __catspeak_op_subtract_unary(rhs) {
    return -rhs;
}

/// @ignore
///
/// @param {Any} rhs
/// @return {Any}
function __catspeak_op_plus_unary(rhs) {
    return +rhs;
}

/// @ignore
///
/// @param {Any} rhs
/// @return {Any}
function __catspeak_op_not_unary(rhs) {
    return !rhs;
}

/// @ignore
///
/// @param {Any} rhs
/// @return {Any}
function __catspeak_op_bitwise_not_unary(rhs) {
    return ~rhs;
}

/// @ignore
function __catspeak_init_operators() {
    var binOps = array_create(CatspeakOperator.__SIZE__, undefined);
    var unaryOps = array_create(CatspeakOperator.__SIZE__, undefined);
    binOps[@ CatspeakOperator.REMAINDER] = __catspeak_op_remainder;
    binOps[@ CatspeakOperator.MULTIPLY] = __catspeak_op_multiply;
    binOps[@ CatspeakOperator.DIVIDE] = __catspeak_op_divide;
    binOps[@ CatspeakOperator.DIVIDE_INT] = __catspeak_op_divide_int;
    binOps[@ CatspeakOperator.SUBTRACT] = __catspeak_op_subtract;
    binOps[@ CatspeakOperator.PLUS] = __catspeak_op_plus;
    binOps[@ CatspeakOperator.EQUAL] = __catspeak_op_equal;
    binOps[@ CatspeakOperator.NOT_EQUAL] = __catspeak_op_not_equal;
    binOps[@ CatspeakOperator.GREATER] = __catspeak_op_greater;
    binOps[@ CatspeakOperator.GREATER_EQUAL] = __catspeak_op_greater_equal;
    binOps[@ CatspeakOperator.LESS] = __catspeak_op_less;
    binOps[@ CatspeakOperator.LESS_EQUAL] = __catspeak_op_less_equal;
    binOps[@ CatspeakOperator.SHIFT_RIGHT] = __catspeak_op_shift_right;
    binOps[@ CatspeakOperator.SHIFT_LEFT] = __catspeak_op_shift_left;
    binOps[@ CatspeakOperator.BITWISE_AND] = __catspeak_op_bitwise_and;
    binOps[@ CatspeakOperator.BITWISE_XOR] = __catspeak_op_bitwise_xor;
    binOps[@ CatspeakOperator.BITWISE_OR] = __catspeak_op_bitwise_or;
    unaryOps[@ CatspeakOperator.SUBTRACT] = __catspeak_op_subtract_unary;
    unaryOps[@ CatspeakOperator.PLUS] = __catspeak_op_plus_unary;
    unaryOps[@ CatspeakOperator.NOT] = __catspeak_op_not_unary;
    unaryOps[@ CatspeakOperator.BITWISE_NOT] = __catspeak_op_bitwise_not_unary;
    /// @ignore
    global.__catspeakBinOps = binOps;
    /// @ignore
    global.__catspeakUnaryOps = unaryOps;
}