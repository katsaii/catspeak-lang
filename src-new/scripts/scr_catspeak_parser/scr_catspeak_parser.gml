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
        __catspeak_check_instanceof("lexer", lexer, "CatspeakLexer");
        __catspeak_check_instanceof("builder", builder, "CatspeakASGBuilder");
    }

    self.lexer = lexer;
    self.asg = builder;

    self.asg.pushFunction();

    /// Enables or disables any additional features for this parser, according
    /// to the supplied feature flags.
    ///
    /// @param {Enum.CatspeakFeature} featureFlags
    ///   An instance of [CatspeakFeature] specifying which features to enable.
    ///
    /// @return {Struct}
    static withFeatures = function (featureFlags) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_typeof_numeric("featureFlags", featureFlags);
        }

        return self;
    };

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
            self.asg.popFunction();
            return false;
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
function CatspeakASGBuilder() constructor {
    self.asg = {
        localCount : 0,
        root : undefined,
    };
    self.blocks = __catspeak_alloc_ds_list(self);
    self.blocksTop = -1;
    self.nextLocalIdx = 0;

    /// Returns the underlying syntax graph for this builder.
    ///
    /// @return {Struct}
    static get = function () {
        return asg;
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
        for (var i = blocksTop; localIdx == undefined && i >= 0; i -= 1) {
            var scope = blocks[| i].locals;
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
                " -- unable to assignment target, ",
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
            __catspeak_check_typeof("term", term, "struct");
            __catspeak_check_var_exists("term", term, "type");
            __catspeak_check_typeof_numeric("term.type", term.type);
        }
        var block = blocks[| blocksTop];
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
        var block = blocks[| blocksTop];
        var scope = block.locals;
        if (ds_map_exists(scope, name)) {
            __catspeak_error(
                __catspeak_location_show(lexer.getLocation()),
                " -- a local variable with the name '", name, "' is already ",
                "defined in this scope"
            );
        }
        block.localCount += 1;
        var localIdx = nextLocalIdx;
        var nextLocalIdx_ = localIdx + 1;
        nextLocalIdx = nextLocalIdx_;
        var asg_ = asg;
        if (nextLocalIdx_ > asg_.localCount) {
            asg_.localCount = nextLocalIdx_;
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
        var blocks_ = blocks;
        var blocksTop_ = blocksTop + 1;
        blocksTop = blocksTop_;
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
        var block = blocks[| blocksTop];
        nextLocalIdx -= block.localCount;
        blocksTop -= 1;
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
        pushBlock();
    };

    /// Finalises a Catspeak function and inserts it into the list of
    /// known functions and returns its term.
    ///
    /// @return {Struct}
    static popFunction = function () {
        // TODO :: actually implement functions
        asg.root = popBlock();
        return asg.root;
    };

    /// @ignore
    ///
    /// @param {Enum.CatspeakTerm} kind
    /// @param {Real} location
    /// @param {Struct} container
    /// @return {Struct}
    static __createTerm = function (kind, location, container) {
        if (CATSPEAK_DEBUG_MODE && location != undefined) {
            __catspeak_check_size_bits("location", location, 32);
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
            kind == CatspeakTerm.GET_GLOBAL;
}

/// Indicates the type of term within a Catspeak syntax graph.
enum CatspeakTerm {
    VALUE,
    BLOCK,
    GET_LOCAL,
    SET_LOCAL,
    GET_GLOBAL,
    SET_GLOBAL,
    __SIZE__
}

/// A debug function which attempts to convert a syntax graph back into
/// Catspeak code.
///
/// NOTE: May not always produce valid Catspeak code.
///
/// NOTE: May be very slow.
///
/// @param {Struct} asg
///   The syntax graph to decompile.
///
/// @return {String}
function catspeak_debug_decompile(asg) {
    if (CATSPEAK_DEBUG_MODE) {
        __catspeak_check_var_exists("asg", asg, "root");
        __catspeak_check_var_exists("asg", asg, "localCount");
        __catspeak_check_typeof_numeric("asg.localCount", asg.localCount);
    }
    return __catspeak_debug_decompile_func(asg.localCount, asg.root);
}

/// @ignore
/// @param {Struct} term
/// @return {String}
function __catspeak_debug_decompile_func(localCount, term) {
    var msg = "";
    var i = 0;
    repeat (localCount) {
        msg += "let t" + string(i) + "\n";
        i += 1;
    }
    return msg + __catspeak_debug_decompile_term(term);
}

/// @ignore
/// @param {Struct} term
/// @return {String}
function __catspeak_debug_decompile_term(term) {
    static indent = 0;
    if (CATSPEAK_DEBUG_MODE) {
        __catspeak_check_typeof("term", term, "struct");
        __catspeak_check_var_exists("term", term, "type");
        __catspeak_check_typeof_numeric("term.type", term.type);
    }
    switch (term.type) {
    case CatspeakTerm.VALUE:
        var value = term.value;
        return is_string(value) ? "\"" + value + "\"" : string(value);
    case CatspeakTerm.BLOCK:
        var msg = "do {\n";
        var terms = term.terms;
        indent += 1;
        var indentStr = "";
        repeat (indent) {
            indentStr += "  ";
        }
        for (var i = 0; i < array_length(terms); i += 1) {
            var blockTerm = terms[i];
            msg += indentStr + __catspeak_debug_decompile_term(blockTerm);
            if (blockTerm.dbg != undefined) {
                msg += "\n" + indentStr + "-- ^" + __catspeak_location_show(blockTerm.dbg);
            }
            msg += "\n";
        }
        indent -= 1;
        indentStr = string_delete(indentStr, 1, 2);
        msg += indentStr + "}";
        return msg;
    case CatspeakTerm.GET_LOCAL:
        return "t" + string(term.idx);
    case CatspeakTerm.SET_LOCAL:
        return "t" + string(term.idx) + " = " + 
                __catspeak_debug_decompile_term(term.value);
    case CatspeakTerm.GET_GLOBAL:
        return term.name;
    case CatspeakTerm.SET_GLOBAL:
        return term.name + " = " + 
                __catspeak_debug_decompile_term(term.value);
    default:
        return "<decomp-failed>";
    }
}