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

{% set opcode_type_buffer = type_to_gml_buffer(ir["instr-opcode-type"]) -%}
{% set opcode_eof = ir["program-end-signal"] -%}
{% set dbg_type_buffer = type_to_gml_buffer(ir["instr-dbg-type"]) -%}
{% set instrc_type_buffer = type_to_gml_buffer(ir["func"]["instr-count"]) -%}
{% set argc_type_buffer = type_to_gml_buffer(ir["func"]["arg-count"]) -%}

/// Handles the creation of Catspeak cartridges. Performs little to no
/// optimisations on the output. What you emit is what you get!
///
/// @experimental
function CatspeakCartWriter() constructor {
{% for meta in MetaItem.enum(ir) %}
    /// {{ case_sentence(meta.desc) }}
    ///
    /// @returns {{ meta.type_feather }}
    {{ meta.name_id }} = undefined;
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

    /// Returns the number of expressions on the stack at this current moment.
    /// Useful when working with instructions which don't take a constant
    /// number of stackargs. (e.g. `emitSequence`)
    ///
    /// @return {Real}
    static getStackSize = function () { return stackSize };

    /// Returns a new fresh local variable id for the current function.
    /// Intended for use with `emitLocalGet` and `emitLocalSet`.
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
    /// mark it for garbage collection.
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
{% for head in HeadItem.enum(ir) %}
            buffer_write(cart, {{ head.type_buffer }}, {{ head.value_lit }}); // {{ head.name }}
{% endfor %}
            // write metadata
{% for meta in MetaItem.enum(ir) %}
            buffer_write(cart, {{ meta.type_buffer }}, {{ meta.name_id }} ?? {{ meta.value_lit }});
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
            // 0xFF indicates the end of the program section
            buffer_write(cart, {{ opcode_type_buffer }}, {{ opcode_eof }});
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
    ///
    /// @param {Real} [argc]
    ///   The number of named args this function accepts. Defaults to 0.
    ///
    /// @return {Real}
    static popFunction = function (argc = 0) {
        __catspeak_assert(chunkTop >= 0,
            "unbalanced function stack! too many calls to `popFunction`"
        );
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, {{ opcode_type_buffer }}, 0);
        buffer_write(chunk, {{ argc_type_buffer }}, argc);
        var idx = funcCount;
        funcCount += 1;
        chunkTop -= 1;
        // revert to previous state
        var prevChunkStates_ = prevChunkStates;
        varCount = ds_stack_pop(prevChunkStates_);
        stackSize = ds_stack_pop(prevChunkStates_);
        return idx;
    };
{% for instr in InstrItem.enum(ir) %}
{%  set instr_writer = "emit" + case_camel_upper(instr.name) %}
{%  set instr_enum = "__CatspeakInstr." + case_snake_upper(instr.name_short) %}

    /// {{ case_sentence(instr.desc) }}
{%  for arg in InstrArgItem.enum(instr.ir) %}
    ///
    /// @param {{ arg.type_feather }} {{ arg.name }}
    ///   {{ case_sentence(arg.desc) }}
{%  endfor %}
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static {{ instr_writer }} = function ({{
        join(", ", args(InstrArgItem.enum(instr.ir)) + ["dbg = CATSPEAK_NOLOCATION"])
    }}) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, {{ opcode_type_buffer }}, {{ instr_enum }});
        buffer_write(chunk, {{ dbg_type_buffer }}, dbg);
{%  for arg in InstrArgItem.enum(instr.ir) %}
        buffer_write(chunk, {{ arg.type_buffer }}, {{ arg.name }});
{%  endfor %}
{%  set ns = namespace(pushes = "1", pushes_name = "<result>") %}
{%  for arg in InstrStackargItem.enum(instr.ir) %}
{%   set ns.pushes_name = ns.pushes_name + " - " + arg.name %}
{%   if arg.many %}
{%    set ns.pushes = ns.pushes + " - " + str(arg.many) %}
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

/// Handles the parsing of Catspeak cartridges.
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
///   - `.handleMeta({{ join(", ", args(MetaItem.enum(ir))) }})` (always invoked first)
///   - `.handleFunc(idx, argc)`
{% for instr in InstrItem.enum(ir) %}
///   - `.{{ instr.name_handler }}({{
            join(", ", ["dbg"] + args(InstrArgItem.enum(instr.ir)))
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
{% for head in HeadItem.enum(ir) %}
    val = buffer_read(cart_, {{ head.type_buffer }});
    if (val != {{ head.value_lit }}) {
        __catspeak_error(__catspeak_cat(
            @'{{ head.name }} {{ head.value_lit }} of type `{{ head.type }}` missing from cartridge header, got ', val
        ));
    }
{% endfor %}
    // read metadata
{% for meta in MetaItem.enum(ir) %}
    var {{ meta.name_id }} = buffer_read(cart_, {{ meta.type_buffer }});
{% endfor %}
    visitor_.handleMeta({{ join(", ", args(MetaItem.enum(ir))) }});

    /// @ignore
    cart = cart_;
    /// @ignore
    visitor = visitor_;
    /// @ignore
    funcIdx = 0;

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
        var opcode = buffer_read(cart_, {{ opcode_type_buffer }});
        if (opcode == {{ opcode_eof }}) {
            // we've reached the end
            cart_ = undefined;
            return false;
        }
        __catspeak_assert(opcode >= 0 && opcode < __CatspeakInstr.__SIZE__,
            "invalid cartridge instruction: " + string(opcode)
        );
        var instrReader = __readerLookup[opcode];
        instrReader();
        return true;
    };

    /// @ignore
    static __readFunc = function () {
        var argc = buffer_read(cart, {{ argc_type_buffer }});
        visitor.handleFunc(funcIdx, argc);
        funcIdx += 1;
    };
{% for instr in InstrItem.enum(ir) %}
{%  set instr_reader = "__readI" + case_camel_upper(instr.name) %}

    /// @ignore
    static {{ instr_reader }} = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, {{ dbg_type_buffer }});
{%  for arg in InstrArgItem.enum(instr.ir) %}
        var {{ arg.name }} = buffer_read(cart_, {{ arg.type_buffer }});
{%  endfor %}
        visitor.{{ instr.name_handler }}({{
            join(", ", ["dbg"] + args(InstrArgItem.enum(instr.ir)))
        }});
    };
{% endfor %}

    /// @ignore
    static __readerLookup = undefined;
    if (__readerLookup == undefined) {
        __readerLookup = array_create(__CatspeakInstr.__SIZE__, undefined);
        __readerLookup[@ 0] = __readFunc;
{% for instr in InstrItem.enum(ir) %}
{%  set instr_reader = "__readI" + case_camel_upper(instr.name) %}
{%  set instr_enum = "__CatspeakInstr." + case_snake_upper(instr.name_short) %}
        __readerLookup[@ {{ instr_enum }}] = {{ instr_reader }};
{% endfor %}
    }
}

/// @ignore
enum __CatspeakInstr {
{% for instr in InstrItem.enum(ir) %}
    {{ case_snake_upper(instr.name_short) }} = {{ instr.opcode }},
{% endfor %}
    __SIZE__ = {{ InstrItem.max_opcode(ir) + 1 }},
}