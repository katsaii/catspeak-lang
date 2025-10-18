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
{% for meta_name, meta in ir_enumerate(ir, "meta") %}
{%  set meta_ref = gml_var_ref(meta_name) %}
{%  set meta_desc = case_sentence(meta["desc"]) %}
{%  set meta_feather = gml_type_feather(meta["type"]) %}
    /// {{ meta_desc }}
    ///
    /// @returns {{ meta_feather }}
    {{ meta_ref }} = undefined;
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
{% for head_name, head in ir_enumerate(ir, "head") %}
{%  set head_bufftype = gml_type_buffer(head["type"]) %}
{%  set head_value = ir_type_as_gml_literal(head["type"], head["value"]) %}
        buffer_write(cart, {{ head_bufftype }}, {{ head_value }}); // {{ head_name }}
{% endfor %}
        // write metadata
{% for meta_name, meta in ir_enumerate(ir, "meta") %}
{%  set meta_ref = gml_var_ref(meta_name) %}
{%  set meta_bufftype = gml_type_buffer(meta["type"]) %}
{%  set meta_value = ir_type_as_gml_literal(meta["type"], meta["value"]) %}
        buffer_write(cart, {{ meta_bufftype }}, {{ meta_ref }} ?? {{ meta_value }});
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
{% for head_name, head in ir_enumerate(ir, "head") %}
{%  set head_bufftype = gml_type_buffer(head["type"]) %}
{%  set head_value = ir_type_as_gml_literal(head["type"], head["value"]) %}
        // {{ head_name }}
        val = buffer_read(cart, {{ head_bufftype }});
{%  if head_name == "cart-version" %}
        buffer_seek(cart, buffer_seek_start, currSeek);
        return val;
{%  else %}
        if (val != {{ head_value }}) {
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
{% for head_name, head in ir_enumerate(ir, "head") %}
{%  set head_bufftype = gml_type_buffer(head["type"]) %}
{%  set head_value = ir_type_as_gml_literal(head["type"], head["value"]) %}
        if (buffer_read(cart_, {{ head_bufftype }}) != {{ head_value }}) {
            failedMessage = @'{{ head_name }} `{{ head["value"] }}` of type {{ head["type"] }} missing from header';
        }
{% endfor %}
    } catch (ex_) {
        failedMessage = ex_.message;
    }
    if (failedMessage != undefined) {
        __catspeak_error("failed to read Catspeak cartridge: ", failedMessage);
    }
    // read metadata
{% for meta_name, meta in ir_enumerate(ir, "meta") %}
{%  set meta_ref = gml_var_ref(meta_name) %}
{%  set meta_bufftype = gml_type_buffer(meta["type"]) %}
    var {{ meta_ref }} = buffer_read(cart_, {{ meta_bufftype }});
{% endfor %}
    visitor_.handleMeta({
{% for meta_name, meta in ir_enumerate(ir, "meta") %}
{%  set meta_ref = gml_var_ref(meta_name) %}
        {{ meta_ref }} : {{ meta_ref }},
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