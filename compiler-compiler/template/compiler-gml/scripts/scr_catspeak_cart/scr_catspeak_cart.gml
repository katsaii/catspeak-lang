//! Responsible for the reading and writing of Catspeak IR (Intermediate
//! Representation). Catspeak IR is a binary format that can be saved and
//! loaded from a file, or treated like a "ROM" or "cartridge".
//!
//! Cartridge code is stored in reverse-polish notation, where each
//! instruction may push (or pop) intermediate values onto a virtual stack.
//!
//! Depending on the export, this may literally be a stack--such as with a
//! so-called "stack machine" VM. Other times the "stack" may be an
//! abstraction (e.g. the GML export), where Catspeak cartridges are
//! transformed into recursive GML function calls. (This ends up being faster
//! for reasons I won't detail here.)
//!
//! Each instruction may also be associated with zero or more static
//! parameters.

//# feather use syntax-errors

/// Handles the writing of Catspeak cartridges
///
/// @experimental
function CatspeakCartBuilder() constructor {
{% for meta in MetaItem.enum(ir) %}
    /// {{ case_sentence(meta.desc) }}
    ///
    /// @returns {{ meta.type_feather }}
    {{ meta.name_id }} = undefined;
{% endfor %}
    /// @ignore
    isAlive = true;

    /// Writes the contents of this builder to the given buffer. If no buffer
    /// is supplied then a new, fresh buffer is allocated and returned.
    ///
    /// This method will also free the memory allocated by this builder, and
    /// mark it for garbage collection.
    ///
    /// @warning
    ///   Continuing to use the builder after this method has been called is
    ///   considered invalid, and may result in strange behaviour or crashes.
    ///
    /// @param {Id.Buffer} [buff]
    ///   The buffer to write the cartridge to. Must be a `buffer_grow` type
    ///   buffer with an alignment of 1.
    static finalise = function (buff = undefined) {
        __catspeak_assert(isAlive, "cannot call `finalise` method twice");
        isAlive = false;
        var cart;
        if (buff == undefined) {
            cart = buffer_create(1, buffer_grow, 1);
        } else {
            __catspeak_assert_typeof(buff, __catspeak_is_buffer,
                "argument `buff` must be a buffer"
            );
            __catspeak_assert_eq(buffer_grow, buffer_get_type(buff),
                "requires a grow buffer (buffer_grow)"
            );
            __catspeak_assert_eq(1, buffer_get_alignment(buff),
                "requires a buffer with alignment 1"
            );
            cart = buff;
        }
        // write header
{% for head in HeadItem.enum(ir) %}
        buffer_write(cart, {{ head.type_buffer }}, {{ head.value_lit }}); // {{ head.name }}
{% endfor %}
        // write metadata
{% for meta in MetaItem.enum(ir) %}
        buffer_write(cart, {{ meta.type_buffer }}, {{ meta.name_id }} ?? {{ meta.value_lit }});
{% endfor %}
        return cart;
    };
}

/// Returns the version number of this Catspeak cartridge, or 0 if the
/// given buffer isn't a valid cartridge.
///
/// @param {Id.Buffer} cart
///   The buffer to read cartridge info from.
///
/// @return {Real}
function catspeak_cart_version(cart) {
    if (!__catspeak_is_buffer(cart)) {
        return 0;
    }
    var currSeek = buffer_tell(cart);
    var val;
    try {
{% for head in HeadItem.enum(ir) %}
        // {{ head.name }}
        val = buffer_read(cart, {{ head.type_buffer }});
{%  if head.name == "cart-version" %}
        buffer_seek(cart, buffer_seek_start, currSeek);
        return val;
{%  else %}
        if (val != {{ head.value_lit }}) {
            buffer_seek(cart, buffer_seek_start, currSeek);
            return 0;
        }
{%  endif %}
{% endfor %}
    } catch (ex) {
        buffer_seek(cart, buffer_seek_start, currSeek);
    }
    return 0;
}

/// Handles the reading of Catspeak cartridges.
///
/// @experimental
///
/// @remark
///   Immediately reads and calls the handlers for the "data" section of the
///   Catspeak cartridge.
///
/// @param {Id.Buffer} cart_
///   The buffer to read cartridge info from.
///
/// @param {Struct} visitor_
///   A struct containing methods for handling each of the following cases:
///
///   - TODO
function CatspeakCartParser(cart_, visitor_) constructor {
    __catspeak_assert_typeof(cart_, __catspeak_is_buffer,
        "buffer doesn't exist"
    );
    __catspeak_assert_eq(1, buffer_get_alignment(cart_),
        "requires a buffer with alignment 1"
    );
    __catspeak_assert_typeof(visitor_, is_struct,
        "visitor must be a struct"
    );
    // read header
    var failedMessage = undefined;
    try {
{% for head in HeadItem.enum(ir) %}
        if (buffer_read(cart_, {{ head.type_buffer }}) != {{ head.value_lit }}) {
            failedMessage = @'{{ head.name }} {{ head.value_lit }} of type `{{ head.type }}` missing from header';
        }
{% endfor %}
    } catch (ex_) {
        failedMessage = ex_.message;
    }
    if (failedMessage != undefined) {
        __catspeak_error("failed to read Catspeak cartridge: ", failedMessage);
    }
    // read metadata
{% for meta in MetaItem.enum(ir) %}
    var {{ meta.name_id }} = buffer_read(cart_, {{ meta.type_buffer }});
{% endfor %}
    visitor_.handleMeta({
{% for meta in MetaItem.enum(ir) %}
        {{ meta.name_id }} : {{ meta.name_id }},
{% endfor %}
    });

    /// @ignore
    cart = cart_;
    /// @ignore
    visitor = visitor_;

    /// Reads the next instruction if it exists, calling its handler.
    ///
    /// If there are more instructions left to be read, then this function will
    /// return `true`. If all instructions have been read, then `false` is
    /// returned, and the buffers seek is set to the end of the Cartidge.
    ///
    /// @return {Bool}
    static readInstr = function () {
        return false;
    }
}