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
            return false;
        }
        asg.addRoot(__parseStatement());
        return true;
    };

    /// @ignore
    /// @return {Struct}
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
            result = asg.assignTerms(getter, valueTerm);
        } else {
            result = __parseExpression();
        }
        if (lexer.peek() == CatspeakToken.BREAK_LINE) {
            lexer.next();
        }
        return result;
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
            asg.pushLocalScope();
            if (lexer.next() != CatspeakToken.BRACE_LEFT) {
                __ex("expected opening '{' after 'do' keyword");
            }
            var inner = asg.createValue(undefined, lexer.getLocation());
            while (__isNot(CatspeakToken.BRACE_RIGHT)) {
                inner = asg.mergeTerms(inner, __parseStatement());
            }
            if (lexer.next() != CatspeakToken.BRACE_RIGHT) {
                __ex("expected closing '}' after 'do' block");
            }
            asg.popLocalScope();
            return inner;
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
    //# feather disable once GM2043
    self.asg.root = createValue(undefined);
    self.blocks = __catspeak_alloc_ds_list(self);
    self.blocksTop = -1;
    self.nextLocalIdx = 0;

    // Feather disable once GM2043
    pushLocalScope(); // TODO :: yuck!

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

    /// Adds an existing node to the program's root node.
    ///
    /// @param {Real} term
    ///   The term to register to the root node.
    static addRoot = function (term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_typeof("term", term, "struct");
            __catspeak_check_var_exists("term", term, "type");
            __catspeak_check_typeof_numeric("term.type", term.type);
        }

        asg.root = mergeTerms(asg.root, term);
    };

    /// Composes two terms together, producing a new term where term A
    /// executes first, followed by term B.
    ///
    /// NOTE: Either terms A or B could be optimised or modified, therefore
    ///       you should always treat both terms as being invalid after
    ///       calling this method. Always use the result returned by this
    ///       method as the new source of truth.
    ///
    /// @param {Real} termA
    ///   The term to execute first.
    ///
    /// @param {Real} termB
    ///   The term to execute second.
    ///
    /// @return {Real}
    static mergeTerms = function (termA, termB) {
        var aType = termA.type;
        var bType = termB.type;
        var aIsBlock = aType == CatspeakTerm.BLOCK;
        var bIsBlock = bType == CatspeakTerm.BLOCK;
        if (aIsBlock && !bIsBlock) {
            if (!__catspeak_term_is_pure(termA.result.type)) {
                array_push(termA.terms, termA.result);
            }
            termA.result = termB;
            return termA;
        } else if (aIsBlock && bIsBlock) {
            var aTerms = termA.terms;
            var bTerms = termB.terms;
            var aResult = termA.result;
            if (__catspeak_term_is_pure(aResult.type)) {
                array_push(aTerms, aResult);
            }
            array_copy(
                aTerms, array_length(aTerms),
                bTerms, 0, array_length(bTerms)
            );
            termA.result = termB.result;
            return termA;
        } else if (__catspeak_term_is_pure(aType)) {
            return termB;
        } else if (!aIsBlock && bIsBlock) {
            // hoping that this doesn't happen often
            array_insert(termB.terms, 0, termA);
            return termB;
        } else {
            var terms = array_create(32, termA);
            array_resize(terms, 1);
            return __createTerm(CatspeakTerm.BLOCK, termA.dbg, {
                terms : terms,
                result : termB,
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
    static assignTerms = function (lhs, rhs) {
        var lhsType = lhs.type;
        if (lhsType == CatspeakTerm.GET_LOCAL) {
            if (rhs.type == CatspeakTerm.GET_LOCAL && lhs.idx == rhs.idx) {
                return createValue(undefined, lhs.location);
            }
            lhs.type = CatspeakTerm.SET_LOCAL;
        } else if (lhsType == CatspeakTerm.GET_GLOBAL) {
            if (rhs.type == CatspeakTerm.GET_GLOBAL && lhs.name == rhs.name) {
                return createValue(undefined, lhs.location);
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
    /// allocated in this scope will be cleared after [popLocalScope] is
    /// called.
    ///
    /// @param {Bool} [implicit]
    ///   Whether to write terms to the parent block or not. Defaults to
    ///   `false`, which will always create a new block term per local
    ///   scope.
    static pushLocalScope = function (implicit=false) {
        var blocks_ = blocks;
        var blocksTop_ = blocksTop + 1;
        blocksTop = blocksTop_;
        var block = blocks_[| blocksTop_];
        if (block == undefined) {
            ds_list_add(blocks_, {
                locals : __catspeak_alloc_ds_map(self),
                localCount : 0,
            });
        } else {
            ds_map_clear(block.locals);
            block.localCount = 0;
        }
    };

    /// Clears the most recent local scope and frees any allocated local
    /// variables.
    static popLocalScope = function () {
        nextLocalIdx -= blocks[| blocksTop].localCount;
        blocksTop -= 1;
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