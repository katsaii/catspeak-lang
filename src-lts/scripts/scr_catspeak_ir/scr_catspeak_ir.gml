//! Exposes an interface for building and optimising the hierarchial
//! representation of Catspeak programs, commonly referred to in this
//! documentation as "Catspeak IR". It represents the code of a Catspeak
//! program without any unnecessary detail, like whitespace or syntax.
//!
//! Everything in Catspeak IR is an expression which can return a result.
//!
//! Mostly used internally by `CatspeakParser`, but could be used yourself
//! to build your own programs from your own domain-specific language and
//! then compile it down further to be a callable GML function using
//! `CatspeakGMLCompiler`.

//# feather use syntax-errors

/// The old Catspeak IR builder.
///
/// @deprecated {3.0.0}
///   Use `CatspeakIRBuilder` instead.
function CatspeakASGBuilder() : CatspeakIRBuilder() constructor { }

/// Intended to be a stable inferface for generating code for Catspeak IR
/// programs. The preferred method of creating correctly formed, and
/// optimised Catspeak IR.
///
/// @experimental
function CatspeakIRBuilder() constructor {
    /// @ignore
    self.functions = [];
    /// @ignore
    self.topLevelFunctions = [];
    /// @ignore
    self.functionScopes = __catspeak_alloc_ds_list(self);
    /// @ignore
    self.functionScopesTop = -1;
    /// @ignore
    self.currFunctionScope = undefined;

    /// Returns the underlying representation of this builder.
    ///
    /// @return {Struct}
    static get = function () {
        return {
            functions : functions,
            entryPoints : topLevelFunctions,
        };
    };

    /// Emits the instruction to return a new constant value.
    ///
    /// @param {Any} value
    ///   The value this term should resolve to.
    ///
    /// @param {Real} [location]
    ///   The source location of this value term.
    ///
    /// @return {Struct}
    static createValue = function (value, location=undefined) {
        // __createTerm() will do argument validation
        return __createTerm(CatspeakTerm.VALUE, location, {
            value : value
        });
    };

    /// Emits the instruction to create a new array literal.
    ///
    /// @param {Array} values
    ///   The values to populate the array with.
    ///
    /// @param {Real} [location]
    ///   The source location of this value term.
    ///
    /// @return {Struct}
    static createArray = function (values, location=undefined) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg("values", values, is_array);
        }
        // __createTerm() will do argument validation
        return __createTerm(CatspeakTerm.ARRAY, location, {
            values : values
        });
    };

    /// Emits the instruction to create a new struct literal.
    ///
    /// @param {Array} values
    ///   The key-value pairs to populate the struct with.
    ///
    /// @param {Real} [location]
    ///   The source location of this value term.
    ///
    /// @return {Struct}
    static createStruct = function (values, location=undefined) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg("values", values, is_array);
            if (array_length(values) % 2 == 1) {
                __catspeak_error(
                    "expected arg 'values' to be an array with an even ",
                    "number of elements, got ", array_length(values)
                );
            }
        }
        // __createTerm() will do argument validation
        return __createTerm(CatspeakTerm.STRUCT, location, {
            values : values
        });
    };

    /// @ignore
    ///
    /// @param {Struct} term
    /// @return {Any}
    static __getValue = function (term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg_struct("term", term,
                "value", undefined
            );
        }
        return term.value;
    }

    /// Emits the instruction for an if statement.
    ///
    /// @param {Struct} condition
    ///   The term which evaluates to the condition of the if statement.
    ///
    /// @param {Struct} ifTrue
    ///   The term which evaluates if the condition of the if statement is
    ///   true.
    ///
    /// @param {Struct} ifFalse
    ///   The term which evaluates if the condition of the if statement is
    ///   false.
    ///
    /// @param {Real} [location]
    ///   The source location of this value term.
    ///
    /// @return {Struct}
    static createIf = function (condition, ifTrue, ifFalse, location=undefined) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg_struct("condition", condition,
                "type", is_numeric
            );
            __catspeak_check_arg_struct("ifFalse", ifFalse,
                "type", is_numeric,
            );
        }
        if (condition.type == CatspeakTerm.VALUE) {
            if (__getValue(condition)) {
                return ifTrue;
            } else {
                return ifFalse;
            }
        }
        // __createTerm() will do argument validation
        if (ifFalse.type == CatspeakTerm.VALUE &&
                __catspeak_is_nullish(__getValue(ifFalse))) {
            return __createTerm(CatspeakTerm.IF, location, {
                condition : condition,
                ifTrue : ifTrue,
                ifFalse : undefined,
            });
        } else {
            return __createTerm(CatspeakTerm.IF, location, {
                condition : condition,
                ifTrue : ifTrue,
                ifFalse : ifFalse,
            });
        }
    };
    
    /// Emits the instruction for a match expression.
    ///
    /// @param {Struct} value
    ///   The term to evaluate and compare against.
    ///
    /// @param {Array} arms
    ///   A list of pairs where the first term is compared against `value` and the second term is returned if both match.
    ///
    /// @param {Real} [location]
    ///   The source location of this match term.
    static createMatch = function(value, arms, location = undefined) {
        return __createTerm(CatspeakTerm.MATCH, location, {
            value: value,
            arms: arms,
        });
    }

    /// Emits the instruction for a short-circuiting logical AND expression.
    ///
    /// @param {Struct} eager
    ///   The term which evaluates immediately.
    ///
    /// @param {Struct} lazy
    ///   The term which evaluates if the first term is true.
    ///
    /// @param {Real} [location]
    ///   The source location of this value term.
    ///
    /// @return {Struct}
    static createAnd = function (eager, lazy, location=undefined) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg_struct("eager", eager,
                "type", is_numeric
            );
        }
        if (eager.type == CatspeakTerm.VALUE) {
            if (__getValue(condition)) {
                return lazy;
            } else {
                return eager;
            }
        }
        // __createTerm() will do argument validation
        return __createTerm(CatspeakTerm.AND, location, {
            eager : eager,
            lazy : lazy,
        });
    };

    /// Emits the instruction for a short-circuiting logical OR expression.
    ///
    /// @param {Struct} eager
    ///   The term which evaluates immediately.
    ///
    /// @param {Struct} lazy
    ///   The term which evaluates if the first term is false.
    ///
    /// @param {Real} [location]
    ///   The source location of this value term.
    ///
    /// @return {Struct}
    static createOr = function (eager, lazy, location=undefined) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg_struct("eager", eager,
                "type", is_numeric
            );
        }
        if (eager.type == CatspeakTerm.VALUE) {
            if (__getValue(condition)) {
                return eager;
            } else {
                return lazy;
            }
        }
        // __createTerm() will do argument validation
        return __createTerm(CatspeakTerm.OR, location, {
            eager : eager,
            lazy : lazy,
        });
    };

    /// Emits the instruction for a while loop.
    ///
    /// @param {Struct} condition
    ///   The term which evaluates to the condition of the while loop.
    ///
    /// @param {Struct} body
    ///   The body of the while loop.
    ///
    /// @param {Real} [location]
    ///   The source location of this value term.
    ///
    /// @return {Struct}
    static createWhile = function (condition, body, location=undefined) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg_struct("condition", condition,
                "type", is_numeric
            );
            __catspeak_check_arg_struct("body", body);
        }
        if (condition.type == CatspeakTerm.VALUE && !__getValue(condition)) {
            return createValue(undefined, condition.dbg);
        }
        // __createTerm() will do argument validation
        return __createTerm(CatspeakTerm.WHILE, location, {
            condition : condition,
            body : body,
        });
    };

    /// Emits the instruction to return a value from the current function.
    ///
    /// @param {Struct} value
    ///   The instruction for the value to return.
    ///
    /// @param {Real} [location]
    ///   The source location of this value term.
    ///
    /// @return {Struct}
    static createReturn = function (value, location=undefined) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg_struct("value", value);
        }
        // __createTerm() will do argument validation
        return __createTerm(CatspeakTerm.RETURN, location, {
            value : value
        });
    };

    /// Emits the instruction to break from the current loop with a specified
    /// value.
    ///
    /// @param {Struct} value
    ///   The instruction for the value to break with.
    ///
    /// @param {Real} [location]
    ///   The source location of this value term.
    ///
    /// @return {Struct}
    static createBreak = function (value, location=undefined) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg_struct("value", value);
        }
        // __createTerm() will do argument validation
        return __createTerm(CatspeakTerm.BREAK, location, {
            value : value
        });
    };

    /// Emits the instruction to continue to the next iteration of the current
    /// loop.
    ///
    /// @param {Real} [location]
    ///   The source location of this value term.
    ///
    /// @return {Struct}
    static createContinue = function (location=undefined) {
        // __createTerm() will do argument validation
        return __createTerm(CatspeakTerm.CONTINUE, location, { });
    };

    /// Emits the instruction to call a function with a set of arguments.
    ///
    /// @param {Struct} callee
    ///   The instruction containing the function to call.
    ///
    /// @param {Struct} args
    ///   The the arguments to pass into the function call.
    ///
    /// @param {Real} [location]
    ///   The source location of this value term.
    ///
    /// @return {Struct}
    static createCall = function (callee, args, location=undefined) {
        // __createTerm() will do argument validation
        return __createTerm(CatspeakTerm.CALL, location, {
            callee : callee,
            args : args,
        });
    };

    /// Emits the instruction to call a constructor function with a set of
    /// arguments.
    ///
    /// @param {Struct} callee
    ///   The instruction containing the function to call.
    ///
    /// @param {Struct} args
    ///   The the arguments to pass into the function call.
    ///
    /// @param {Real} [location]
    ///   The source location of this value term.
    ///
    /// @return {Struct}
    static createCallNew = function (callee, args, location=undefined) {
        // __createTerm() will do argument validation
        return __createTerm(CatspeakTerm.CALL_NEW, location, {
            callee : callee,
            args : args,
        });
    };

    /// Searches a for a variable with the supplied name and emits a get
    /// instruction for it.
    ///
    /// @param {String} name
    ///   The name of the variable to search for.
    ///
    /// @param {Real} [location]
    ///   The source location of this term.
    ///
    /// @return {Struct}
    static createGet = function (name, location=undefined) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg("name", name, is_string);
        }
        // __createTerm() will do argument validation
        var localIdx = undefined;
        for (
            var i = currFunctionScope.blocksTop;
            __catspeak_is_nullish(localIdx) && i >= 0;
            i -= 1
        ) {
            var scope = currFunctionScope.blocks[| i].locals;
            localIdx = scope[? name];
        }
        if (__catspeak_is_nullish(localIdx)) {
            return __createTerm(CatspeakTerm.GLOBAL, location, {
                name : name
            });
        } else {
            return __createTerm(CatspeakTerm.LOCAL, location, {
                idx : localIdx
            });
        }
    };

    /// Creates an accessor expression.
    ///
    /// @param {Struct} collection
    ///   The term containing the collection to access.
    ///
    /// @param {Struct} key
    ///   The term containing the key to access the collection with.
    ///
    /// @param {Real} [location]
    ///   The source location of this term.
    ///
    /// @return {Struct}
    static createAccessor = function (collection, key, location=undefined) {
        // __createTerm() will do argument validation
        return __createTerm(CatspeakTerm.INDEX, location, {
            collection : collection,
            key : key,
        });
    };

    /// Creates a property expression.
    ///
    /// @param {Struct} property
    ///   The term containing the property to access.
    ///
    /// @param {Real} [location]
    ///   The source location of this term.
    ///
    /// @return {Struct}
    static createProperty = function (property, location=undefined) {
        // __createTerm() will do argument validation
        return __createTerm(CatspeakTerm.PROPERTY, location, {
            property : property,
        });
    };

    /// Creates a binary operator.
    ///
    /// @param {Enum.CatspeakOperator} operator
    ///   The operator type to use.
    ///
    /// @param {String} lhs
    ///   The left-hand side operand.
    ///
    /// @param {String} rhs
    ///   The right-hand side operand.
    ///
    /// @param {Real} [location]
    ///   The source location of this term.
    ///
    /// @return {Struct}
    static createBinary = function (operator, lhs, rhs, location=undefined) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg("operator", operator, is_numeric); // TODO :: proper bounds check
            __catspeak_check_arg_struct("lhs", lhs, "type", is_numeric);
            __catspeak_check_arg_struct("rhs", rhs, "type", is_numeric);
        }
        if (lhs.type == CatspeakTerm.VALUE && rhs.type == CatspeakTerm.VALUE) {
            if (CATSPEAK_DEBUG_MODE) {
                __catspeak_check_arg_struct("lhs", lhs, "value", undefined);
                __catspeak_check_arg_struct("rhs", rhs, "value", undefined);
            }
            // constant folding
            var opFunc = __catspeak_operator_get_binary(operator);
            lhs.value = opFunc(lhs.value, rhs.value);
            return lhs;
        }
        // __createTerm() will do argument validation
        return __createTerm(CatspeakTerm.OP_BINARY, location, {
            operator : operator,
            lhs : lhs,
            rhs : rhs,
        });
    };

    /// Creates a binary operator.
    ///
    /// @param {Enum.CatspeakOperator} operator
    ///   The operator type to use.
    ///
    /// @param {String} value
    ///   The value to apply the operator to.
    ///
    /// @param {Real} [location]
    ///   The source location of this term.
    ///
    /// @return {Struct}
    static createUnary = function (operator, value, location=undefined) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg("operator", operator, is_numeric); // TODO :: proper bounds check
            __catspeak_check_arg_struct("value", value, "type", is_numeric);
        }
        if (value.type == CatspeakTerm.VALUE) {
            if (CATSPEAK_DEBUG_MODE) {
                __catspeak_check_arg_struct("value", value, "value", undefined);
            }
            // constant folding
            var opFunc = __catspeak_operator_get_unary(operator);
            value.value = opFunc(value.value);
            return value;
        }
        // __createTerm() will do argument validation
        return __createTerm(CatspeakTerm.OP_UNARY, location, {
            operator : operator,
            value : value,
        });
    };

    /// Creates an instruction for accessing the caller `self`.
    ///
    /// @param {Real} [location]
    ///   The source location of this term.
    ///
    /// @return {Struct}
    static createSelf = function (location=undefined) {
        // __createTerm() will do argument validation
        return __createTerm(CatspeakTerm.SELF, location, { });
    };

    /// Attempts to assign a right-hand-side value to a left-hand-side target.
    ///
    /// @remark
    ///   Either terms A or B could be optimised or modified, therefore you
    ///   should always treat both terms as being invalid after calling this
    ///   method. Always use the result returned by this method as the new
    ///   source of truth.
    ///
    /// @param {Enum.CatspeakAssign} type
    ///   The assignment type to use.
    ///
    /// @param {Struct} lhs
    ///   The assignment target to use. Typically this is a local/global
    ///   variable get expression.
    ///
    /// @param {Struct} rhs
    ///   The assignment target to use. Typically this is a local/global
    ///   variable get expression.
    ///
    /// @param {Real} [location]
    ///   The source location of this assignment.
    ///
    /// @return {Struct}
    static createAssign = function (type, lhs, rhs, location=undefined) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg("type", type, is_numeric);
        }
        if (type == CatspeakAssign.VANILLA) {
            if (CATSPEAK_DEBUG_MODE) {
                __catspeak_check_arg_struct("lhs", lhs,
                    "type", is_numeric
                );
                __catspeak_check_arg_struct("rhs", rhs,
                    "type", is_numeric
                );
            }
            var lhsType = lhs.type;
            if (lhsType == CatspeakTerm.LOCAL) {
                if (rhs.type == CatspeakTerm.LOCAL) {
                    if (CATSPEAK_DEBUG_MODE) {
                        __catspeak_check_arg_struct("lhs", lhs, "idx", is_numeric);
                        __catspeak_check_arg_struct("rhs", rhs, "idx", is_numeric);
                    }
                    if (lhs.idx == rhs.idx) {
                        return createValue(undefined, location);
                    }
                }
            } else if (lhsType == CatspeakTerm.GLOBAL) {
                if (rhs.type == CatspeakTerm.GLOBAL) {
                    if (CATSPEAK_DEBUG_MODE) {
                        __catspeak_check_arg_struct("lhs", lhs, "name", is_string);
                        __catspeak_check_arg_struct("rhs", rhs, "name", is_string);
                    }
                    if (lhs.name == rhs.name) {
                        return createValue(undefined, location);
                    }
                }
            }
        }
        return __createTerm(CatspeakTerm.SET, location, {
            assignType : type,
            target : lhs,
            value : rhs,
        });
    };

    /// Adds an existing node to the current block's statement list.
    ///
    /// @param {Struct} term
    ///   The term to register to the current block.
    static createStatement = function (term) {
        var block = currFunctionScope.blocks[| currFunctionScope.blocksTop];
        var result_ = block.result;
        if (result_ != undefined) {
            ds_list_add(block.inheritedTerms ?? block.terms, result_);
        }
        block.result = term;
    };

    /// Allocates a new local variable with the supplied name in the current
    /// scope. Returns a term to get or set the value of this local variable.
    ///
    /// @param {String} name
    ///   The name of the local variable to allocate.
    ///
    /// @param {Real} [location]
    ///   The source location of this local variable.
    ///
    /// @return {Struct}
    static allocLocal = function (name, location=undefined) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg("name", name, is_string);
        }
        // __createTerm() will do argument validation
        var block = currFunctionScope.blocks[| currFunctionScope.blocksTop];
        var scope = block.locals;
        if (ds_map_exists(scope, name)) {
            __catspeak_error(
                __catspeak_location_show(location),
                " -- a local variable with the name '", name, "' is already ",
                "defined in this scope"
            );
        }
        block.localCount += 1;
        var localIdx = currFunctionScope.nextLocalIdx;
        var nextLocalIdx_ = localIdx + 1;
        currFunctionScope.nextLocalIdx = nextLocalIdx_;
        if (nextLocalIdx_ > currFunctionScope.localCount) {
            currFunctionScope.localCount = nextLocalIdx_;
        }
        scope[? name] = localIdx;
        return __createTerm(CatspeakTerm.LOCAL, location, {
            idx : localIdx
        });
    };

    /// Allocates a new named function argument with the supplied name.
    /// Returns a term to get or set the value of this argument.
    ///
    /// @param {String} name
    ///   The name of the local variable to allocate.
    ///
    /// @param {Real} [location]
    ///   The source location of this local variable.
    ///
    /// @return {Struct}
    static allocArg = function (name, location=undefined) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg("name", name, is_string);
        }
        // __createTerm() will do argument validation
        var local = allocLocal(name, location);
        if (currFunctionScope.argCount != local.idx) {
            __catspeak_error(
                "must allocate all function arguments before ",
                "allocating any local variables"
            );
        }
        currFunctionScope.argCount += 1;
        return local;
    };

    /// Starts a new local variable block scope. Any local variables
    /// allocated in this scope will be cleared after [popBlock] is
    /// called.
    ///
    /// @param {Bool} [inherit]
    ///   Whether to write terms to the parent block or not. Defaults to
    ///   `false`, which will always create a new block term per local
    ///   scope.
    static pushBlock = function (inherit=false) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg("inherit", inherit, is_numeric);
        }
        var blocks_ = currFunctionScope.blocks;
        var blocksTop_ = currFunctionScope.blocksTop + 1;
        currFunctionScope.blocksTop = blocksTop_;
        var block = blocks_[| blocksTop_];
        var inheritedTerms = undefined;
        if (inherit) {
            var blockParent = blocks_[| blocksTop_ - 1];
            inheritedTerms = blockParent.inheritedTerms ?? blockParent.terms;
        }
        if (__catspeak_is_nullish(block)) {
            ds_list_add(blocks_, {
                locals : __catspeak_alloc_ds_map(self),
                terms : __catspeak_alloc_ds_list(self),
                inheritedTerms : inheritedTerms,
                result : undefined,
                localCount : 0,
            });
        } else {
            ds_map_clear(block.locals);
            ds_list_clear(block.terms);
            block.inheritedTerms = inheritedTerms;
            block.result = undefined;
            block.localCount = 0;
        }
    };

    /// Clears the most recent local scope and frees any allocated local
    /// variables.
    ///
    /// @param {Real} [location]
    ///   The source location of this block.
    ///
    /// @return {Struct}
    static popBlock = function (location=undefined) {
        // __createTerm() will do argument validation
        var block = currFunctionScope.blocks[| currFunctionScope.blocksTop];
        currFunctionScope.nextLocalIdx -= block.localCount;
        currFunctionScope.blocksTop -= 1;
        var result_ = block.result;
        if (block.inheritedTerms != undefined) {
            return result_ ?? createValue(undefined, location);
        }
        var terms = block.terms;
        if (result_!= undefined) {
            // since the result is separate from the other statements,
            // add it back
            ds_list_add(terms, result_);
        }
        var termCount = ds_list_size(terms);
        var finalTerms = array_create(termCount);
        var finalCount = 0;
        var prevTermIsPure = false;
        for (var i = 0; i < termCount; i += 1) {
            var term = terms[| i];
            if (prevTermIsPure) {
                finalCount -= 1;
            }
            finalTerms[@ finalCount] = term;
            finalCount += 1;
            prevTermIsPure = __catspeak_term_is_pure(term.type);
        }
        if (finalCount == 0) {
            return createValue(undefined, location);
        } else if (finalCount == 1) {
            return finalTerms[0];
        } else {
            var blockLocation = location ?? terms[| 0].dbg;
            array_resize(finalTerms, finalCount);
            return __createTerm(CatspeakTerm.BLOCK, blockLocation, {
                terms : finalTerms,
            });
        }
    };

    /// Begins a new Catspeak function scope.
    static pushFunction = function () {
        var functionScopes_ = functionScopes;
        var functionScopesTop_ = functionScopesTop + 1;
        functionScopesTop = functionScopesTop_;
        var function_ = functionScopes_[| functionScopesTop_];
        if (__catspeak_is_nullish(function_)) {
            function_ = {
                blocks : __catspeak_alloc_ds_list(self),
                blocksTop : -1,
                nextLocalIdx : 0,
                localCount : 0,
                argCount : 0,
            };
            ds_list_add(functionScopes_, function_);
        } else {
            ds_list_clear(function_.blocks);
            function_.blocksTop = -1;
            function_.nextLocalIdx = 0;
            function_.localCount = 0;
            function_.argCount = 0;
        }
        currFunctionScope = function_;
        pushBlock();
    };

    /// Finalises a Catspeak function and inserts it into the list of
    /// known functionScopes and returns its term.
    ///
    /// @param {Real} [location]
    ///   The source location of this function definition.
    ///
    /// @return {Struct}
    static popFunction = function (location=undefined) {
        // __createTerm() will do argument validation
        var idx = array_length(functions);
        functions[@ idx] = {
            localCount : currFunctionScope.localCount,
            argCount : currFunctionScope.argCount,
            root : popBlock(),
        };
        functionScopesTop -= 1;
        if (functionScopesTop < 0) {
            array_push(topLevelFunctions, idx);
            currFunctionScope = undefined;
        } else {
            currFunctionScope = functionScopes[| functionScopesTop];
        }
        return __createTerm(CatspeakTerm.FUNCTION, location, {
            idx : idx,
        });
    };

    /// @ignore
    ///
    /// @param {Enum.CatspeakTerm} kind
    /// @param {Real} location
    /// @param {Struct} container
    /// @return {Struct}
    static __createTerm = function (kind, location, container) {
        if (CATSPEAK_DEBUG_MODE && location != undefined) {
            __catspeak_check_arg_size_bits("location", location, 32);
        }
        container.type = kind;
        container.dbg = location;
        return container;
    };
}

/// @ignore
///
/// @param {Enum.CatspeakTerm} kind
/// @return {Bool}
function __catspeak_term_is_pure(kind) {
    return kind == CatspeakTerm.VALUE ||
            kind == CatspeakTerm.LOCAL ||
            kind == CatspeakTerm.GLOBAL ||
            kind == CatspeakTerm.FUNCTION ||
            kind == CatspeakTerm.SELF;
}

/// @ignore
///
/// @param {Struct} term
/// @return {Any}
function __catspeak_term_get_terminal(term) {
    if (CATSPEAK_DEBUG_MODE) {
        __catspeak_check_arg_struct("term", term,
            "type", is_numeric
        );
    }
    if (term.type == CatspeakTerm.GLOBAL) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg_struct("term", term,
                "name", undefined
            );
        }
        return term.name;
    } else if (term.type == CatspeakTerm.SELF) {
        return "self";
    } else if (term.type == CatspeakTerm.VALUE) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg_struct("term", term,
                "value", undefined
            );
        }
        return string(term.value);
    }
    return undefined;
}

/// Indicates the type of Catspeak IR instruction.
///
/// @experimental
enum CatspeakTerm {
    VALUE,
    ARRAY,
    STRUCT,
    BLOCK,
    IF,
    AND,
    OR,
    WHILE,
    MATCH,
    USE,
    RETURN,
    BREAK,
    CONTINUE,
    OP_BINARY,
    OP_UNARY,
    CALL,
    CALL_NEW,
    SET,
    INDEX,
    PROPERTY,
    LOCAL,
    GLOBAL,
    FUNCTION,
    SELF,
    /// @ignore
    __SIZE__
}

/// Represents the set of pure operators used by the Catspeak runtime and
/// compile-time constant folding.
///
/// @experimental
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
    /// The bitwise AND `&` operator.
    BITWISE_AND,
    /// The bitwise XOR `^` operator.
    BITWISE_XOR,
    /// The bitwise OR `|` operator.
    BITWISE_OR,
    /// The logical XOR operator.
    XOR,
    /// @ignore
    __SIZE__,
}

/// Represents the set of assignment operators understood by Catspeak.
///
/// @experimental
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
    /// @ignore
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
    if (CATSPEAK_DEBUG_MODE && __catspeak_is_nullish(opFunc)) {
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
    if (CATSPEAK_DEBUG_MODE && __catspeak_is_nullish(opFunc)) {
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
/// @param {Any} lhs
/// @param {Any} rhs
/// @return {Any}
function __catspeak_op_xor(lhs, rhs) {
    return lhs ^^ rhs;
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
    binOps[@ CatspeakOperator.XOR] = __catspeak_op_xor;
    /// @ignore
    global.__catspeakBinOps = binOps;
    /// @ignore
    global.__catspeakUnaryOps = unaryOps;
}