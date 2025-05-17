//! Responsible for the reading and writing of Catspeak IR (Intermediate
//! Representation). Catspeak IR is a binary format that can be saved
//! and loaded from a file, or treated like a "ROM" or "cartridge".

//# feather use syntax-errors

{% set instr_opcode_bufftype = gml_type_buffer(ir["instr-opcode"]) %}

/// The type of Catspeak IR instruction.
/// 
/// Catspeak stores cartridge code in reverse-polish notation, where each
/// instruction may push (or pop) intermediate values onto a virtual stack.
/// 
/// Depending on the export, this may literally be a stack--such as with a
/// so-called "stack machine" VM. Other times the "stack" may be an abstraction,
/// such as with the GML export, where Catspeak cartridges are transformed into
/// recursive GML function calls. (This ends up being faster for reasons I won't
/// detail here.)
/// 
/// Each instruction may also be associated with zero or many static parameters.
enum CatspeakInstr {
    /// @ignore
    END_OF_PROGRAM = 0,
{% for _, instr in ir_enumerate(ir, "instr") %}
{%  set instr_name = case_snake_upper(instr["name-short"] or instr["name"]) %}
{%  set instr_repr = instr["repr"] %}
{%  set instr_desc = case_sentence(instr["desc"]) %}
    /// {{ instr_desc }}
    {{ instr_name }} = {{ instr_repr }},
{% endfor %}
    /// @ignore
    __SIZE__,
}

/// Handles the creation of Catspeak cartridges.
///
/// @param {Id.Buffer} buff_
///   The buffer to write the cartridge to. Must be a `buffer_grow` type buffer
///   with an alignment of 1.
function CatspeakCartWriter(buff_) constructor {
    __catspeak_assert(buffer_exists(buff_), "buffer doesn't exist");
    __catspeak_assert_eq(buffer_grow, buffer_get_type(buff_),
        "Catspeak cartridges require a grow buffer (buffer_grow)"
    );
    {{ gml_chunk_head("buff_") }}
{% for head_name, head in ir_enumerate(ir, "head") %}
{%  set head_bufftype = gml_type_buffer(head["type"]) %}
{%  set head_value = ir_type_as_gml_literal(head["type"], head["value-unfinished"] or head["value"]) %}
{%  if "value-unfinished" in head %}
{%   set head_varname = gml_var_ref(head_name, "h") %}
    {{ head_varname }} = buffer_tell(buff_);
    // ({{ head_name }} will be patched to {{ head["value"] }} when finalised)
{%  endif %}
    buffer_write(buff_, {{ head_bufftype }}, {{ head_value }}); // {{ head_name }} header
{% endfor %}
{% for chunk_name, chunk_type in ir_enumerate(ir, "chunk") %}
{%  set chunk_ref = gml_chunk_ref(chunk_name) %}
{%  set chunk_bufftype = gml_type_buffer(chunk_type) %}
    /// @ignore
    {{ chunk_ref }} = buffer_tell(buff_);
    buffer_write(buff_, {{ chunk_bufftype }}, 0);
{% endfor %}
    {{ gml_chunk_patch(ir, "instr", "buff_") }}
{% for section_name, section in ir_enumerate(ir, "data") %}
{%  if section_name == "func" %}
{%   for funcvar_name, funcvar in ir_enumerate(ir["data"], "func") %}
{%    set funcvar_ref = gml_var_ref(funcvar_name, "fv") %}
{%    set funcvar_value = gml_literal_default(funcvar["type"]) %}
    /// @ignore
    {{ funcvar_ref }} = {{ funcvar_value }};
{%   endfor %}
    /// @ignore
    fvStack = array_create(8);
    /// @ignore
    fvTop = 0;
    /// @ignore
    fvFrozen = [];
    /// @ignore
    fvFrozenCount = 1;
{%  endif %}
{%  if section_name == "meta" %}
{%   for meta_name, meta in ir_enumerate(ir["data"], "meta") %}
{%    set meta_ref = gml_var_ref(meta_name, "cart") %}
{%    set meta_value = gml_literal_default(meta["type"]) %}
{%    set meta_desc = case_sentence(meta["desc"]) %}
{%    set meta_feathtype = gml_type_feather(meta["type"]) %}
    /// {{ meta_desc }}
    ///
    /// @returns {{ meta_feathtype }}
    {{ meta_ref }} = {{ meta_value }};
{%   endfor %}
{%  endif %}
{% endfor %}
    /// @ignore
    buff = buff_;

    /// Finalises the creation of this Catspeak cartridge. Assumes the program
    /// section is well-formed, then writes the data section before patching
    /// any necessary references and in the header.
    static finalise = function () {
        var buff_ = buff;
        buff = undefined;
        {{ ir_assert_cart_exists("buff_") }}
        __catspeak_assert(fvTop_ < 0.5,
            "'.beginFunction' called with no associated '.endFunction' call"
        );
        buffer_write(buff_, {{ instr_opcode_bufftype }}, CatspeakInstr.END_OF_PROGRAM);
        {{ gml_chunk_patch(ir, "data", "buff_") }}
{% for section_name, section in ir_enumerate(ir, "data") %}
{%  if section_name == "func" %}
        // write func data
{%   set func_count_bufftype = gml_type_buffer(ir["data"]["func-count"]) %}
        buffer_write(buff_, {{ func_count_bufftype }}, fvFrozenCount);
{%   for funcvar_name, funcvar in ir_enumerate(ir["data"], "func") %}
{%    set funcvar_ref = gml_var_ref(funcvar_name, "fv") %}
{%    set funcvar_bufftype = gml_type_buffer(funcvar["type"]) %}
        buffer_write(buff_, {{ funcvar_bufftype }}, funcvar_ref);
{%   endfor %}
        var fvI = 0;
        var fvTop_ = fvTop;
        var fvFrozen_ = fvFrozen;
        while (i < fvTop_) {
{%   for funcvar_name, funcvar in ir_enumerate(ir["data"], "func") %}
{%    set funcvar_bufftype = gml_type_buffer(funcvar["type"]) %}
            buffer_write(buff_, {{ funcvar_bufftype }}, fvFrozen_[fvI]);
            fvI += 1;
{%   endfor %}
        }
{%  endif %}
{%  if section_name == "meta" %}
        // write meta data
{%   for meta_name, meta in ir_enumerate(ir["data"], "meta") %}
{%    set meta_ref = gml_var_ref(meta_name, "cart") %}
{%    set meta_bufftype = gml_type_buffer(meta["type"]) %}
        buffer_write(buff_, {{ meta_bufftype }}, {{ meta_ref }});
{%   endfor %}
{%  endif %}
{% endfor %}
        {{ gml_chunk_patch(ir, "end", "buff_") }}
{% for head_name, head in ir_enumerate(ir, "head") %}
{%  if "value-unfinished" in head %}
{%   set head_bufftype = gml_type_buffer(head["type"]) %}
{%   set head_value = ir_type_as_gml_literal(head["type"], head["value"]) %}
{%   set head_varname = gml_var_ref(head_name, "h") %}
        buffer_poke(buff_, {{ head_varname }}, {{ head_bufftype }}, {{ head_value }}); // patch {{ head_name }} header
{%  endif %}
{% endfor %}
    };

    /// Begins a new Catspeak function scope.
    static beginFunction = function () {
        {{ ir_assert_cart_exists("buff") }}
        var fvTop_ = fvTop;
        var fvStack_ = fvStack;
{% for funcvar_name, funcvar in ir_enumerate(ir["data"], "func") %}
{%  set funcvar_ref = gml_var_ref(funcvar_name, "fv") %}
{%  set funcvar_value = gml_literal_default(funcvar["type"]) %}
        fvStack_[@ fvTop_] = {{ funcvar_ref }};
        fvTop_ += 1;
{% endfor %}
        fvTop = fvTop_;
    };

    /// Ends the current Catspeak function scope, returning its id.
    ///
    /// @returns {Real}
    static endFunction = function () {
        {{ ir_assert_cart_exists("buff") }}
        var fvTop_ = fvTop;
        __catspeak_assert(fvTop_ > 0.5, "function stack underflow");
        var fvFrozen_ = fvFrozen;
        var fvStack_ = fvStack;
{% for funcvar_name, funcvar in ir_enumerate(ir["data"], "func") %}
{%  set funcvar_ref = gml_var_ref(funcvar_name, "fv") %}
        array_push(fvFrozen_, {{ funcvar_ref }});
        {{ funcvar_ref }} = fvStack_[fvTop_];
        fvTop_ -= 1;
{% endfor %}
        fvTop = fvTop_;
        var functionIdx = fvFrozenCount;
        fvFrozenCount += 1;
        return functionIdx;
    };

    /// Allocate space for a new local variable, returning its id.
    ///
    /// @returns {Real}
    static allocLocal = function () {
        {{ ir_assert_cart_exists("buff") }}
        var localIdx = fvLocals;
        fvLocals += 1;
        return localIdx;
    };
{% for _, instr in ir_enumerate(ir, "instr") %}
{%  set instr_func = gml_var_ref(instr["name"], "emit") %}
{%  set instr_enum = "CatspeakInstr." + case_snake_upper(instr["name"]) %}

    /// {{ case_sentence(instr["desc"]) }}
{%  for arg in instr["args"] %}
    ///
{%   if "default" in arg %}
    /// @param {{ ir_type_as_feather_type(arg["type"]) }} [{{ arg["name"]}}]
{%   else %}
    /// @param {{ ir_type_as_feather_type(arg["type"]) }} {{ arg["name"]}}
{%   endif %}
    ///     {{ case_sentence(arg["desc"]) }}
{%  endfor %}
    static {{ instr_func }} = function ({{ gml_func_args(instr["args"]) }}) {
        var buff_ = buff;
        {{ ir_assert_cart_exists("buff_") }}
{%  for arg in instr["args"] %}
{%   if "default" in arg %}
        {{ arg["name"] }} ??= {{ arg["default"] }};
{%   endif %}
        {{ ir_assert_type(arg["type"], arg["name"]) }}
{%  endfor %}
        buffer_write(buff_, {{ instr_opcode_bufftype }}, {{ instr_enum }});
{%  for arg in instr["args"] %}
{%   set arg_bufftype = gml_type_buffer(arg["type"]) %}
        buffer_write(buff_, {{ arg_bufftype }}, {{ arg["name"] }});
{%  endfor %}
    };
{% endfor %}
}

/// Handles the parsing of Catspeak cartridges.
///
/// @param {Id.Buffer} buff_
///   The buffer to read cartridge info from.
///
/// @param {Struct} visitor_
///   A struct containing methods for handling each of the following cases:
///
///   - TODO
function CatspeakCartReader(buff_, visitor_) constructor {
    __catspeak_assert(buffer_exists(buff_), "buffer doesn't exist");
    __catspeak_assert(is_struct(visitor_), "visitor must be a struct");
{% for _, instr in ir_enumerate(ir, "instr") %}
{%  set name_handler = gml_var_ref(instr["name"], "handle") %}
    __catspeak_assert(is_method(visitor_[$ "{{ name_handler }}"]),
        "visitor is missing a handler for '{{ name_handler }}'"
    );
{% endfor %}
    var buffStart = buffer_tell(buff_);
    var failedMessage = undefined;
    try {
{% for head_name, head in ir_enumerate(ir, "head") %}
{%  set head_bufftype = gml_type_buffer(head["type"]) %}
{%  set head_value = ir_type_as_gml_literal(head["type"], head["value"]) %}
        if (buffer_read(buff_, {{ head_bufftype }}) != {{ head_value }}) {
            failedMessage = "failed to read Catspeak cartridge: '{{ head['value'] }}' ({{ head['type'] }}) missing from header";
        }
{% endfor %}
    } catch (ex_) {
        __catspeak_error("error occurred when trying to read Catspeak cartridge: ", ex_.message);
    }
    if (failedMessage != undefined) {
        __catspeak_error(failedMessage);
    }
{% for chunk_name, chunk_type in ir_enumerate(ir, "chunk") %}
{%  set chunk_ref = gml_chunk_ref(chunk_name) %}
{%  set chunk_bufftype = gml_type_buffer(chunk_type) %}
    /// @ignore
    {{ chunk_ref }} = buffer_read(buff_, {{ chunk_bufftype }}, 0);
{% endfor %}
    {{ gml_chunk_seek(ir, "data", "buff_") }}

{% for section_name, section in ir_enumerate(ir, "data") %}
{%  if section_name == "func" %}
        // write func data
{%   set func_count_bufftype = gml_type_buffer(ir["data"]["func-count"]) %}
        buffer_write(buff_, {{ func_count_bufftype }}, fvFrozenCount);
{%   for funcvar_name, funcvar in ir_enumerate(ir["data"], "func") %}
{%    set funcvar_ref = gml_var_ref(funcvar_name, "fv") %}
{%    set funcvar_bufftype = gml_type_buffer(funcvar["type"]) %}
        buffer_write(buff_, {{ funcvar_bufftype }}, funcvar_ref);
{%   endfor %}
        var fvI = 0;
        var fvTop_ = fvTop;
        var fvFrozen_ = fvFrozen;
        while (i < fvTop_) {
{%   for funcvar_name, funcvar in ir_enumerate(ir["data"], "func") %}
{%    set funcvar_bufftype = gml_type_buffer(funcvar["type"]) %}
            buffer_write(buff_, {{ funcvar_bufftype }}, fvFrozen_[fvI]);
            fvI += 1;
{%   endfor %}
        }
{%  endif %}
{%  if section_name == "meta" %}
        // write meta data
{%   for meta_name, meta in ir_enumerate(ir["data"], "meta") %}
{%    set meta_ref = gml_var_ref(meta_name, "cart") %}
{%    set meta_bufftype = gml_type_buffer(meta["type"]) %}
        buffer_write(buff_, {{ meta_bufftype }}, {{ meta_ref }});
{%   endfor %}
{%  endif %}
{% endfor %}

    {{ gml_chunk_seek(ir, "instr", "buff_") }}
    /// @ignore
    buff = buff_;

    /// @ignore
    static __readerLookup = undefined;
    if (__readerLookup == undefined) {
        __readerLookup = array_create(CatspeakCartInst.__SIZE__, undefined);
{% for _, instr in ir_enumerate(ir, "instr") %}
{%  set instr_reader = gml_var_ref(instr["name"], "__read") %}
{%  set instr_enum = "CatspeakCartInst." + case_snake_upper(instr["name"]) %}
        __readerLookup[@ {{ instr_enum }}] = {{ instr_reader }};
{% endfor %}
    }
}
