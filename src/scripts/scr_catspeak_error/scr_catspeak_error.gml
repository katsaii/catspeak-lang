//! Handles errors raised by the compiler and runtime environment.

//# feather use syntax-errors

/// Represents a line and column number in a Catspeak source file.
///
/// @param {Real} line
///   The line number this position is found on.
///
/// @param {Real} [column]
///   The column number this position is found on. This is the number of
///   characters since the previous new-line character; therefore, tabs are
///   considered a single column, not 2, 4, 8, etc. columns.
function CatspeakLocation(line, column) constructor {
    self.line = line;
    self.column = column;

    /// Renders this Catspeak location. If both a line number and column
    /// number exist, then the format will be `(line N, column M)`. Otherwise,
    /// if only a line number exists, the format will be `(line N)`.
    function toString() {
        var msg = "(line " + string(line);
        if (column != undefined) {
            msg += ", column " + string(column);
        }
        msg += ")";
        return msg;
    }
}

/// Represents an error raised by the Catspeak runtime. Follows a similar
/// structure to the built-in error struct.
///
/// @param {Struct.CatspeakLocation} location
///   The location where this error occurred.
///
/// @param {String} [message]
///   The error message to display. Defaults to "No message".
function CatspeakError(location, message="No message") constructor {
    try {
        show_error(message, false);
    } catch (e) {
        self.message = e.message;
        self.longMessage = e.longMessage;
        self.script = e.script;
        self.stacktrace = e.stacktrace;
    }
    self.location = location;

    /// Renders this Catspeak error with its location followed by the error
    /// message.
    ///
    /// @param {Bool} [verbose]
    ///   Whether to include the stack trace as part of the error output.
    function toString(verbose=false) {
        var msg = "";
        msg += instanceof(self) + " " + string(location);
        msg += ": " + string(message);
        if (verbose) {
            msg += "\nStacktrace:";
            var count = array_length(stacktrace);
            for (var i = 0; i < count; i += 1) {
                msg += "\n(" + string(i) + ") " + string(stacktrace[i]);
            }
        }
        return msg;
    }
}