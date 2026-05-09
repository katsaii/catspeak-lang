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
//!
//! @advanced
//! @experimental

//# feather use syntax-errors

{% set opcode_type = ir["instr"]["opcode"] -%}
{% set dbg_type = ir["instr"]["dbg"] -%}

{% macro m_buffer_write(cart, type_, val) -%}
buffer_write({{ cart }}, {{ type_to_gml_buffer(type_) }}, {{ val }})
{%- endmacro -%}

{% macro m_buffer_write_default(cart, type_, val, default_) -%}
buffer_write({{ cart }}, {{ type_to_gml_buffer(type_) }}, {{ val }} ?? {{
    type_to_gml_literal(type_, default_)
}})
{%- endmacro -%}

{% macro m_buffer_read(cart, type_) -%}
buffer_read({{ cart }}, {{ type_to_gml_buffer(type_) }})
{%- endmacro -%}

/// Handles the creation of Catspeak cartridges. Performs little to no
/// optimisations on the output. What you emit is what you get!
function CatspeakCartWriter() constructor {
{% for meta_name, meta in ir_enum(ir, "meta") %}
    /// {{ case_sentence(meta["desc"]) }}
    ///
    /// @returns {{ type_to_gml_feather(meta["type"]) }}
    {{ case_camel(meta_name) }} = undefined;
{% endfor %}
    /// @ignore
    isAlive = true;
    /// @ignore
    chunks = ds_list_create();
    /// @ignore
    chunkTop = -1;
    /// @ignore
    funcCount = 0;
    /// @ignore
    prevChunkStates = ds_stack_create();
    /// @ignore
    stackSize = 0;
    /// @ignore
    varCount = 0;

    /// Returns the number of expressions on the stack.
    ///
    /// Useful when working with instructions which don't take a constant
    /// number of stackargs. (e.g. `emitSequence`)
    ///
    /// @return {Real}
    static getStackSize = function () { return stackSize };

    /// Returns a new fresh local variable id for the current function.
    /// Intended for use with `emitGetLocal` and `emitSetLocal`.
    ///
    /// @return {Real}
    static getFreshVar = function () {
        var idx = varCount;
        varCount += 1;
        return idx;
    };

    /// Frees any dynamically allocated resources managed by this writer.
    ///
    /// @warning
    ///   This **must** be called in a `finally` block if you expect exceptions.
    static destroy = function () {
        if (!isAlive) {
            return;
        }
        var chunks_ = chunks;
        for (var i = ds_list_size(chunks_) - 1; i >= 0; i -= 1) {
            var chunk = chunks_[| i];
            buffer_delete(chunk);
        }
        ds_list_destroy(chunks_);
        ds_stack_destroy(prevChunkStates);
        isAlive = false;
    };

    /// Writes the contents of this builder to the given buffer. If no buffer
    /// is supplied then a new, fresh buffer is allocated and returned.
    ///
    /// This method will also free the memory allocated by this builder, and
    /// mark it for garbage collection. **This means you cannot use the same
    /// builder twice to write to different buffers**, you should use
    /// `buffer_copy` for that!
    ///
    /// @warning
    ///   Continuing to use the builder after this method has been called is
    ///   considered invalid, and may result in strange behaviour or crashes.
    ///
    /// @param {Id.Buffer} [buff]
    ///   The buffer to write the cartridge to. Must be a `buffer_grow` type
    ///   buffer with an alignment of 1.
    ///
    /// @param {Bool} [rewind]
    ///   Whether to rewind the buffer once the cart is finalised. Defaults to
    ///   `true`.
    ///
    /// @return {Id.Buffer}
    static finalise = function (buff = undefined, rewind = true) {
        __catspeak_assert(isAlive, "cannot call `finalise` method twice");
        try {
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
            var cartStart = buffer_tell(cart);
            // write header
{% for head_name, head in ir_enum(ir, "head") %}
{%  set head_value = type_to_gml_literal(head["type"], head["value"]) %}
            {{ m_buffer_write("cart", head["type"], head_value) }}; // {{ head_name }}
{% endfor %}
            // write metadata
{% for meta_name, meta in ir_enum(ir, "meta") %}
            {{ m_buffer_write_default("cart", meta["type"], case_camel(meta_name), meta["default"]) }};
{% endfor %}
            // write functions
            __catspeak_assert(chunkTop < 0,
                "missing call to `popFunction` after calling `pushFunction`"
            );
            var offset = buffer_tell(cart);
            for (var i = ds_list_size(chunks) - 1; i >= 0; i -= 1) {
                var chunk = chunks[| i];
                var chunkSize = buffer_tell(chunk);
                buffer_copy(chunk, 0, chunkSize, cart, offset);
                offset += chunkSize;
            }
            buffer_seek(cart, buffer_seek_start, offset);
            {{ m_buffer_write("cart", ir["instr"]["opcode"], 0x00) }}; // end of program
            if (rewind) {
                buffer_seek(cart, buffer_seek_start, cartStart);
            }
        } finally {
            destroy();
        }
        return cart;
    };

    /// Starts a new function.
    static pushFunction = function () {
        chunkTop += 1;
        if (chunks[| chunkTop] == undefined) {
            chunks[| chunkTop] = buffer_create(1, buffer_grow, 1);
        }
        var prevChunkStates_ = prevChunkStates;
        ds_stack_push(prevChunkStates_, stackSize);
        ds_stack_push(prevChunkStates_, varCount);
        stackSize = 0;
        varCount = 0;
    };

    /// Ends the current function, returning its id.
{% for func_name, func in ir_enum(ir, "func") %}
    ///
    /// @param {{ type_to_gml_feather(func["type"]) }} {{ case_camel(func_name) }}
    ///   {{ case_sentence(func["desc"]) }}
{% endfor %}
    ///
    /// @return {Real}
    static popFunction = function ({{ join(", ", ir_enum_ids(ir, "func")) }}) {
        __catspeak_assert(chunkTop >= 0,
            "unbalanced function stack! too many calls to `popFunction`"
        );
        var chunk = chunks[| chunkTop];
        {{ m_buffer_write("chunk", opcode_type, 0x00) }}; // end of instructions
{% for func_name, func in ir_enum(ir, "func") %}
        {{ m_buffer_write("chunk", func["type"], case_camel(func_name)) }};
{% endfor %}
        var idx = funcCount;
        funcCount += 1;
        chunkTop -= 1;
        // revert to previous state
        var prevChunkStates_ = prevChunkStates;
        varCount = ds_stack_pop(prevChunkStates_);
        stackSize = ds_stack_pop(prevChunkStates_);
        return idx;
    };
{% for _, instr in ir_enum(ir, "instr-ops") %}
{%  set instr_writer = "emit" + case_camel_upper(instr["name"]) %}
{%  set instr_enum = "__CatspeakInstr." + case_snake_upper(instr["name-short"] or instr["name"]) %}

    /// {{ case_sentence(instr["desc"]) }}
{%  for _, arg in ir_enum(instr, "args") %}
    ///
    /// @param {{ type_to_gml_feather(arg["type"]) }} {{ case_camel(arg["name"]) }}
    ///   {{ case_sentence(arg["desc"]) }}
{%  endfor %}
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static {{ instr_writer }} = function ({{
        join(", ", ir_enum_ids(instr, "args"), ["dbg = CATSPEAK_NOLOCATION"])
    }}) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        {{ m_buffer_write("chunk", opcode_type, instr_enum) }};
        {{ m_buffer_write("chunk", dbg_type, "dbg") }};
{%  for _, arg in ir_enum(instr, "args") %}
        {{ m_buffer_write("chunk", arg["type"], case_camel(arg["name"])) }};
{%  endfor %}
{%  set ns = namespace(pushes = "1", pushes_name = "<result>") %}
{%  for _, arg in ir_enum(instr, "args") %}
{%   set ns.pushes_name = ns.pushes_name + " - " + case_camel(arg["name"]) %}
{%   if arg["many"] %}
{%    set ns.pushes = ns.pushes + " - " + str(arg["many"]) %}
{%   else %}
{%    set ns.pushes = ns.pushes + " - 1" %}
{%   endif %}
{%  endfor %}
        // {{ ns.pushes_name }}
        {{ "//" if ns.pushes == "1 - 1" else "" }}stackSize += {{ ns.pushes }};
    };
{% endfor %}
}

/// Returns the version number of this Catspeak cartridge, or `0` if the
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
{% for head_name, head in ir_enum(ir, "head") %}
        // {{ head_name }}
        val = {{ m_buffer_read("cart", head["type"]) }};
{%  if head_name == "cart-version" %}
        buffer_seek(cart, buffer_seek_start, currSeek);
        return val;
{%  else %}
        if (val != {{ type_to_gml_literal(head["type"], head["value"]) }}) {
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

/// Handles the parsing of Catspeak cartridges.
///
/// @remark
///   Immediately reads and calls the handlers for the "data" section of the
///   given Catspeak cartridge.
///
/// @param {Id.Buffer} cart_
///   The buffer to read cartridge info from.
///
/// @param {Struct} visitor_
///   A struct containing methods for handling each of the following cases:
///
///   - `.handleMeta({{ join(", ", ir_enum_ids(ir, "meta")) }})` (always invoked first)
///   - `.handleFunc({{ join(", ", ["idx"], ir_enum_ids(ir, "func")) }})`
{% for _, instr in ir_enum(ir, "instr-ops") %}
///   - `.handleInstr{{ case_camel_upper(instr["name"]) }}({{
            join(", ", ["dbg"], ir_enum_ids(instr, "args"))
        }})`
{% endfor %}
function CatspeakCartReader(cart_, visitor_) constructor {
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
    var val;
{% for head_name, head in ir_enum(ir, "head") %}
{%  set head_value = type_to_gml_literal(head["type"], head["value"]) %}
    val = {{ m_buffer_read("cart_", head["type"]) }};
    if (val != {{ head_value }}) {
        __catspeak_error(__catspeak_cat(
            @'{{ head_name }} {{ head_value }} of type `{{ head["type"] }}` missing from cartridge header, got ', val
        ));
    }
{% endfor %}
    // read metadata
{% for meta_name, meta in ir_enum(ir, "meta") %}
    var {{ case_camel(meta_name) }} = {{ m_buffer_read("cart_", meta["type"]) }};
{% endfor %}
    visitor_.handleMeta({{ join(", ", ir_enum_ids(ir, "meta")) }});

    /// @ignore
    cart = cart_;
    /// @ignore
    visitor = visitor_;
    /// @ignore
    funcIdx = 0;
    /// @ignore
    instrIdx = 0;

    /// Reads the next instruction if it exists, calling its handler.
    ///
    /// If there are more instructions left to be read, then this function will
    /// return `true`. If all instructions have been read, then `false` is
    /// returned, and the buffer seek is set to the **end of the Cartidge**.
    ///
    /// @return {Bool}
    static readInstr = function () {
        var cart_ = cart;
        __catspeak_assert(cart_ != undefined,
            "called `readInstr` after reaching end of cartridge"
        );
        var opcode = {{ m_buffer_read("cart_", opcode_type) }};
        if (opcode == 0x00) {
            if (instrIdx == 0) {
                // end of program
                __catspeak_assert(funcIdx > 0,
                    "cartridge cannot contain 0 functions"
                );
                return false;
            } else {
                // end of function
{% for func_name, func in ir_enum(ir, "func") %}
                var {{ case_camel(func_name) }} = {{ m_buffer_read("cart", func["type"]) }};
{% endfor %}
                visitor.handleFunc({{ join(", ", ["funcIdx"], ir_enum_ids(ir, "func")) }});
                funcIdx += 1;
                instrIdx = 0;
                return true;
            }
        }
        instrIdx += 1;
        __catspeak_assert(opcode >= 0 && opcode < __CatspeakInstr.__SIZE__,
            "invalid cartridge instruction: " + string(opcode)
        );
        var instrReader = __readerLookup[opcode];
        instrReader();
        return true;
    };
{% for _, instr in ir_enum(ir, "instr-ops") %}
{%  set instr_id_upper = case_camel_upper(instr.name) %}

    /// @ignore
    static __readI{{ instr_id_upper }} = function () {
        var cart_ = cart;
        var dbg = {{ m_buffer_read("cart_", dbg_type) }};
{%  for _, arg in ir_enum(instr, "args") %}
        var {{ case_camel(arg["name"]) }} = {{ m_buffer_read("cart_", arg["type"]) }};
{%  endfor %}
        visitor.handleInstr{{ instr_id_upper }}({{
            join(", ", ["dbg"], ir_enum_ids(instr, "args"))
        }});
    };
{% endfor %}

    /// @ignore
    static __readerLookup = undefined;
    if (__readerLookup == undefined) {
        __readerLookup = array_create(__CatspeakInstr.__SIZE__, undefined);
{% for _, instr in ir_enum(ir, "instr-ops") %}
{%  set instr_id_upper = case_camel_upper(instr["name"]) %}
{%  set instr_id_upper_snake = case_snake_upper(instr["name-short"] or instr["name"]) %}
        __readerLookup[@ __CatspeakInstr.{{ instr_id_upper_snake }}] = __readI{{ instr_id_upper }};
{% endfor %}
    }
}

/// @ignore
enum __CatspeakInstr {
{% for _, instr in ir_enum(ir, "instr-ops") %}
{%  set instr_id_upper_snake = case_snake_upper(instr["name-short"] or instr["name"]) %}
    {{ instr_id_upper_snake }} = {{ instr["opcode"] }},
{% endfor %}
    __SIZE__ = {{ max(map(get(1, "opcode"), ir_enum(ir, "instr-ops"))) + 1 }},
}