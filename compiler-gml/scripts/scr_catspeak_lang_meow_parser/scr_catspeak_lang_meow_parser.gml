//! "Meow" is the code name for the built-in Catspeak programming language,
//! loosely inspired by syntax from JavaScript, GML, and Rust.
//!
//! This module contains the parser for Catspeak, responsible for converting
//! tokens emitted by `CatspeakLexer` into a runnable representation. More
//! about this representation can be found on `CatspeakCartWriter`.
//!
//# feather use syntax-errors

/// Consumes tokens produced by a `CatspeakLexer`, transforming the program
/// they represent into a Catspeak cartridge. This cartridge can be further
/// compiled into a callable GML function using a combination of
/// `CatspeakCartReader` and `CatspeakCodegenGML`. (Though, it's probably
/// best if you stick to using the stable `CatspeakCtx` API!)
///
/// @experimental
///
/// @warning
///   The lexer does not take ownership of its buffer, so you must make sure
///   to delete the buffer once the lexer is complete. Failure to do this will
///   result in leaking memory.
///
/// @param {Struct.CatspeakCartWriter} cart_
///   The writer for the cartridge to emit.
///
/// @param {Id.Buffer} buff
///   The ID of the GML buffer to parse tokens from.
///
/// @param {Real} [offset]
///   The offset in the buffer to start parsing from. Defaults to 0.
///
/// @param {Real} [size]
///   The length of the buffer input. Any characters beyond this limit
///   will be treated as the end of the file. Defaults to `infinity`.
function CatspeakParser(cart_, buff, offset = undefined, size = undefined) constructor {
    /// @ignore
    cart = cart_;
    /// @ignore
    scope = new CatspeakScopeStack(cart_);
    /// @ignore
    lexer = new CatspeakLexer(buff, offset, size);
    /// @ignore
    finalised = false;
    scope.beginFunction();

    /// Parses single a top-level statement, adding any relevant parse
    /// information to the cartridge.
    ///
    /// @example
    ///   Creates a new `CatspeakParser` from a buffer `buff`, and
    ///   writes the program information to `cart`.
    ///
    ///   ```gml
    ///   var parser = new CatspeakParserV3(cart, buff;
    ///   do {
    ///       var moreRemains = parser.update();
    ///   } until (!moreRemains);
    ///   ```
    ///
    /// @return {Bool}
    ///   `true` if there is still more data left to parse, and `false`
    ///   if the parser has reached the end of the file.
    static parseOnce = function () {
        __catspeak_assert(!finalised, "attempting to update parser after it has been finalised");
        if (lexer.peek() == CatspeakToken.EOF) {
            scope.endFunction();
            cart.finalise();
            finalised = true;
            return false;
        }
        __parseStatement();
        return true;
    };

    /// @ignore
    static __parseStatement = function () {
        var peeked = lexer.peek();
        if (peeked == CatspeakToken.SEMICOLON) {
            lexer.next();
            return;
        } else if (peeked == CatspeakToken.LET) {
            lexer.next();
            // TODO
        } else {
            scope.prepareStatement();
            __parseExpression();
        }
    };

    /// @ignore
    static __parseExpression = function () {
        // TODO
        __parseTerminal();
    };

    /// @ignore
    static __parseTerminal = function () {
        var peeked = lexer.peek();
        if (peeked == CatspeakToken.NUMBER) {
            lexer.next();
            cart.emitConstNumber(lexer.getValue(), lexer.getLocation());
        } else if (peeked == CatspeakToken.STRING) {
            lexer.next();
            cart.emitConstString(lexer.getValue(), lexer.getLocation());
        } else if (peeked == CatspeakToken.UNDEFINED) {
            lexer.next();
            //cart.emitConstUndefined(lexer.getLocation());
        } else if (peeked == CatspeakToken.IDENT) {
            lexer.next();
            scope.emitGet(lexer.getValue(), lexer.getLocation());
        } else if (peeked == CatspeakToken.SELF) {
            lexer.next();
            //cart.emitSelf(lexer.getLocation());
        } else if (peeked == CatspeakToken.OTHER) {
            lexer.next();
            //cart.emitSelf(lexer.getLocation());
        } else {
            __parseGrouping();
        }
    };

    /// @ignore
    ///
    /// @return {Struct}
    static __parseGrouping = function () {
        var peeked = lexer.peek();
        if (peeked == CatspeakToken.PAREN_LEFT) {
            lexer.next();
            __parseExpression();
            if (lexer.next() != CatspeakToken.PAREN_RIGHT) {
                __ex("expected closing ')' after group expression");
            }
        } else if (peeked == CatspeakToken.BOX_LEFT) {
            lexer.next();
            // TODO
        } else if (peeked == CatspeakToken.BRACE_LEFT) {
            lexer.next();
            // TODO
        } else {
            __ex("malformed expression, expected: '(', '[' or '{'");
        }
    };

    /// @ignore
    static __isNot = function (expect) {
        var peeked = lexer.peek();
        return peeked != expect && peeked != CatspeakToken.EOF;
    };

    /// @ignore
    static __is = function (expect) {
        var peeked = lexer.peek();
        return peeked == expect && peeked != CatspeakToken.EOF;
    };

    /// @ignore
    static __ex = function (msg = "no message") {
        __catspeak_error(
            catspeak_location_show(lexer.getLocationStart(), cart.path) + " during parsing",
            msg, ", got", __token
        );
    };

    /// @ignore
    static __tokenDebug = function () {
        var peeked = lexer.peek();
        if (peeked == CatspeakToken.EOF) {
            return "end of file";
        } else if (peeked == CatspeakToken.SEMICOLON) {
            return "line break ';'";
        }
        return "token '" + lexer.getLexeme() + "' (" + string(peeked) + ")";
    };
}