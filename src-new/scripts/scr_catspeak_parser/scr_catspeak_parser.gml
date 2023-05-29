//! Responsible for the syntax analysis stage of the Catspeak compiler.
//!
//! This stage creates a hierarchical representation of your Catspeak programs,
//! called an abstract syntax graph (or ASG for short). These graphs are
//! encoded as a JSON object, making it possible for you to cache the result
//! of parsing a mod to a file, instead of re-parsing each time the game loads.

//# feather use syntax-errors

/// Consumes tokens produced by a [CatspeakLexer] and transforms them into an
/// abstract syntax graph representing a Catspeak program.
///
/// @param {Struct.CatspeakLexer} lexer
///   The lexer to consume tokens from.
///
/// @param {Struct.CatspeakASGBuilder} builder
///   The syntax graph builder to write data to.
function CatspeakParser(lexer, builder) constructor {
    if (CATSPEAK_DEBUG_MODE) {
        __catspeak_check_arg_struct_instanceof(
                "lexer", lexer, "CatspeakLexer");
        __catspeak_check_arg_struct_instanceof(
                "builder", builder, "CatspeakASGBuilder");
    }

    self.lexer = lexer;
    self.asg = builder;
    self.finalised = false;
    builder.pushFunction();

    /// Updates the parser by parsing a simple Catspeak expression from the
    /// supplied lexer, adding any relevant parse information to the supplied
    /// syntax graph.
    ///
    /// Returns `true` if there is still more data left to parse, and `false`
    /// if the parser has reached the end of the file.
    ///
    /// @example
    ///   Creates a new [CatspeakParser] from the variables `lexer` and
    ///   `builder`, then loops until there is nothing left to parse.
    ///
    /// ```gml
    /// var parser = new CatspeakParser(lexer, builder);
    /// var moreToParse;
    /// do {
    ///     moreToParse = parser.update();
    /// } until (!moreToParse);
    /// ```
    ///
    /// @return {Function}
    static update = function () {
        if (lexer.peek() == CatspeakToken.EOF) {
            if (!finalised) {
                asg.popFunction();
                finalised = true;
            }
            return false;
        }
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_error(
                "attempting to update parser after it has been finalised"
            );
        }
        __parseStatement();
        return true;
    };

    /// @ignore
    static __parseStatement = function() {
        var result;
        if (lexer.peek() == CatspeakToken.LET) {
            lexer.next();
            if (lexer.next() != CatspeakToken.IDENT) {
                __ex("expected identifier after 'let' keyword");
            }
            var localName = lexer.getValue();
            var location = lexer.getLocation();
            var valueTerm;
            if (lexer.peek() == CatspeakToken.ASSIGN) {
                lexer.next();
                valueTerm = __parseExpression();
            } else {
                valueTerm = asg.createValue(undefined, location);
            }
            var getter = asg.allocLocal(localName, location);
            result = asg.createAssign(getter, valueTerm);
        } else {
            result = __parseExpression();
        }
        if (lexer.peek() == CatspeakToken.BREAK_LINE) {
            lexer.next();
        }
        asg.createStatement(result);
    };

    /// @ignore
    /// @return {Struct}
    static __parseExpression = function() {
        return __parseTerminal();
    };

    /// @ignore
    /// @return {Struct}
    static __parseTerminal = function () {
        var peeked = lexer.peek();
        if (peeked == CatspeakToken.STRING || peeked == CatspeakToken.NUMBER) {
            lexer.next();
            return asg.createValue(lexer.getValue(), lexer.getLocation());
        } else if (peeked == CatspeakToken.IDENT) {
            lexer.next();
            return asg.createGet(lexer.getValue(), lexer.getLocation());
        } else {
            return __parseGrouping();
        }
    };

    /// @ignore
    /// @return {Struct}
    static __parseGrouping = function () {
        var peeked = lexer.peek();
        if (peeked == CatspeakToken.PAREN_LEFT) {
            lexer.next();
            var inner = __parseExpression();
            if (lexer.next() != CatspeakToken.PAREN_RIGHT) {
                __ex("expected closing ')' after group expression");
            }
            return inner;
        } else if (peeked == CatspeakToken.DO) {
            lexer.next();
            asg.pushBlock(true);
            if (lexer.next() != CatspeakToken.BRACE_LEFT) {
                __ex("expected opening '{' after 'do' keyword");
            }
            while (__isNot(CatspeakToken.BRACE_RIGHT)) {
                __parseStatement();
            }
            if (lexer.next() != CatspeakToken.BRACE_RIGHT) {
                __ex("expected closing '}' after 'do' block");
            }
            return asg.popBlock();
        } else if (peeked == CatspeakToken.FUN) {
            lexer.next();
            asg.pushFunction();
            if (lexer.next() != CatspeakToken.BRACE_LEFT) {
                __ex("expected opening '{' after 'fun' keyword");
            }
            while (__isNot(CatspeakToken.BRACE_RIGHT)) {
                __parseStatement();
            }
            if (lexer.next() != CatspeakToken.BRACE_RIGHT) {
                __ex("expected closing '}' after 'fun' block");
            }
            return asg.popFunction();
        } else {
            __ex("malformed expression");
        }
    };

    /// @ignore
    /// @param {String} ...
    static __ex = function () {
        var dbg = __catspeak_location_show(lexer.getLocation()) + " when parsing";
        if (argument_count < 1) {
            __catspeak_error(dbg);
        } else {
            var msg = "";
            for (var i = 0; i < argument_count; i += 1) {
                msg += __catspeak_string(argument[i]);
            }
            __catspeak_error(dbg, " -- ", msg, ", got ", __tokenDebug());
        }
    };

    /// @ignore
    /// @return {String}
    static __tokenDebug = function () {
        var peeked = lexer.peek();
        if (peeked == CatspeakToken.EOF) {
            return "end of file";
        } else if (peeked == CatspeakToken.BREAK_LINE) {
            return "line break ';'";
        }
        return "token '" + lexer.getLexeme() + "' (" + string() + ")";
    };

    /// @ignore
    /// @param {Enum.CatspeakToken} expect
    /// @return {Bool}
    static __isNot = function (expect) {
        var peeked = lexer.peek();
        return peeked != expect && peeked != CatspeakToken.EOF;
    };

    /// @ignore
    /// @param {Enum.CatspeakToken} expect
    /// @return {Bool}
    static __is = function (expect) {
        var peeked = lexer.peek();
        return peeked == expect && peeked != CatspeakToken.EOF;
    };
}

/// Handles the generation and optimisation of a syntax graph.
///
/// @unstable
function CatspeakASGBuilder() constructor {
    self.functions = [];
    self.topLevelFunctions = [];
    self.functionScopes = __catspeak_alloc_ds_list(self);
    self.functionScopesTop = -1;
    self.currFunctionScope = undefined;

    /// Returns the underlying syntax graph for this builder.
    ///
    /// @return {Struct}
    static get = function () {
        return {
            functions : functions,
            entryPoints : topLevelFunctions,
        };
    };

    /// Builds a new value term and returns its handle.
    ///
    /// @param {Any} value
    ///   The value this term should resolve to.
    ///
    /// @param {Real} [location]
    ///   The source location of this value term.
    ///
    /// @return {Real}
    static createValue = function (value, location=undefined) {
        return __createTerm(CatspeakTerm.VALUE, location, {
            value : value
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
    static createGet = function (name, location=undefined) {
        var localIdx = undefined;
        for (var i = currFunctionScope.blocksTop; localIdx == undefined && i >= 0; i -= 1) {
            var scope = currFunctionScope.blocks[| i].locals;
            localIdx = scope[? name];
        }
        if (localIdx == undefined) {
            return __createTerm(CatspeakTerm.GET_GLOBAL, location, {
                name : name
            });
        } else {
            return __createTerm(CatspeakTerm.GET_LOCAL, location, {
                idx : localIdx
            });
        }
    };

    /// Attempts to assign a right-hand-side value to a left-hand-side target.
    ///
    /// NOTE: Either terms A or B could be optimised or modified, therefore
    ///       you should always treat both terms as being invalid after
    ///       calling this method. Always use the result returned by this
    ///       method as the new source of truth.
    ///
    /// @param {Struct} lhs
    ///   The assignment target to use. Typically this is a local/global
    ///   variable get expression.
    ///
    /// @param {Struct} rhs
    ///   The assignment target to use. Typically this is a local/global
    ///   variable get expression.
    ///
    /// @return {Struct}
    static createAssign = function (lhs, rhs) {
        var lhsType = lhs.type;
        if (lhsType == CatspeakTerm.GET_LOCAL) {
            if (rhs.type == CatspeakTerm.GET_LOCAL && lhs.idx == rhs.idx) {
                return createValue(undefined, lhs.dbg);
            }
            lhs.type = CatspeakTerm.SET_LOCAL;
        } else if (lhsType == CatspeakTerm.GET_GLOBAL) {
            if (rhs.type == CatspeakTerm.GET_GLOBAL && lhs.name == rhs.name) {
                return createValue(undefined, lhs.dbg);
            }
            lhs.type = CatspeakTerm.SET_GLOBAL;
        } else {
            __catspeak_error(
                __catspeak_location_show(lexer.getLocation()),
                " -- invalid assignment target, ",
                "must be an identifier or accessor expression"
            );
        }
        lhs.value = rhs;
        return lhs;
    };

    /// Adds an existing node to the current block's statement list.
    ///
    /// @param {Real} term
    ///   The term to register to the current block.
    static createStatement = function (term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg_struct("term", term,
                "type", is_numeric
            );
        }

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
        var block = currFunctionScope.blocks[| currFunctionScope.blocksTop];
        var scope = block.locals;
        if (ds_map_exists(scope, name)) {
            __catspeak_error(
                __catspeak_location_show(lexer.getLocation()),
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
        return __createTerm(CatspeakTerm.GET_LOCAL, location, {
            idx : localIdx
        });
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
        var blocks_ = currFunctionScope.blocks;
        var blocksTop_ = currFunctionScope.blocksTop + 1;
        currFunctionScope.blocksTop = blocksTop_;
        var block = blocks_[| blocksTop_];
        var inheritedTerms = undefined;
        if (inherit) {
            var blockParent = blocks_[| blocksTop_ - 1];
            inheritedTerms = blockParent.inheritedTerms ?? blockParent.terms;
        }
        if (block == undefined) {
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
        if (function_ == undefined) {
            function_ = {
                blocks : __catspeak_alloc_ds_list(self),
                blocksTop : -1,
                nextLocalIdx : 0,
                localCount : 0,
            };
            ds_list_add(functionScopes_, function_);
        } else {
            ds_list_clear(function_.blocks);
            function_.blocksTop = -1;
            function_.nextLocalIdx = 0;
            function_.localCount = 0;
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
        var idx = array_length(functions);
        functions[@ idx] = {
            localCount : currFunctionScope.localCount,
            root : popBlock()
        };
        functionScopesTop -= 1;
        if (functionScopesTop < 0) {
            array_push(topLevelFunctions, idx);
            currFunctionScope = undefined;
        } else {
            currFunctionScope = functionScopes[| functionScopesTop];
        }
        return __createTerm(CatspeakTerm.GET_FUNCTION, location, {
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
function __catspeak_term_is_pure(kind) {
    return kind == CatspeakTerm.VALUE ||
            kind == CatspeakTerm.GET_LOCAL ||
            kind == CatspeakTerm.GET_GLOBAL ||
            kind == CatspeakTerm.GET_FUNCTION;
}

/// Indicates the type of term within a Catspeak syntax graph.
enum CatspeakTerm {
    VALUE,
    BLOCK,
    GET_LOCAL,
    SET_LOCAL,
    GET_GLOBAL,
    SET_GLOBAL,
    GET_FUNCTION,
    __SIZE__
}