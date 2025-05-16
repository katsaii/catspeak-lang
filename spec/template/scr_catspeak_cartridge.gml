//! Responsible for the reading and writing of Catspeak IR (Intermediate
//! Representation). Catspeak IR is a binary format that can be saved
//! and loaded from a file, or treated like a "ROM" or "cartridge".

//# feather use syntax-errors

{% set header = spec["header"] -%}
{% set meta = spec["meta"] -%}
{% set instrs = spec["instrs"] -%}

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
enum CatspeakCartInst {
{% for instr in instrs["set"] %}
    /// {{ case_sentence(instr["desc"]) }}
    {{ case_snake_upper(instr["name"]) }} = {{ instr["repr"] }},
{% endfor %}
    /// @ignore
    __SIZE__,
}

/// TODO
function CatspeakCartWriter() constructor {
    /// @ignore
    self.buff = undefined;

    /// TODO
    static setTarget = function (buff_) {
        buff = undefined;
        __catspeak_assert(buffer_exists(buff_), "buffer doesn't exist");
        __catspeak_assert_eq(buffer_grow, buffer_get_type(buff_),
            "IR requires a grow buffer (buffer_grow)"
        );
{% for item in header %}
        buffer_write(buff_, buffer_{{- item["type"] }}, {{ ir_type_as_gml_literal(item["type"], item["value"]) }});
{% endfor %}
        buffer_write(buff_, buffer_{{- spec["meta-offset"] }}, 0);
        refMeta = buffer_tell(buff_);
{% for item in meta %}
{%  set name = "meta" + case_camel_upper(item["name"]) %}
{%  if "many" in item %}
{%   if "type" in item %}
        {{ name }} = [];
{%   else %}
        {{ name }} = {{ ir_type_default(item["many"]) }};
{%   endif %}
{%  else %}
        {{ name }} = {{ ir_type_default(item["type"]) }};
{%  endif %}
{% endfor %}
        buff = buff_;
    };

    /// TODO
    static finaliseTarget = function () {
        var buff_ = buff;
        buff = undefined;
        {{ ir_assert_cart_exists("buff_") }}
        buffer_poke(buff_, refMeta, buffer_{{- spec["meta-offset"] }}, buffer_tell() - refMeta);
{% for item in meta %}
{%  set name = "meta" + case_camel_upper(item["name"]) %}
{%  if "many" in item %}
{%   if "type" in item %}
        var {{ name -}}_ = {{ name }};
        var {{ name -}}N = array_length({{ name -}}_);
        buffer_write(buff_, buffer_{{- item["many"] }}, {{ name -}}N);
        for (var i = 0; i < {{ name -}}N; i += 1) {
            buffer_write(buff_, buffer_{{- item["type"] }}, {{ name -}}_[i]);
        }
{%   else %}
        buffer_write(buff_, buffer_{{- item["many"] }}, {{ name }});
{%   endif %}
{%  else %}
        buffer_write(buff_, buffer_{{- item["type"] }}, {{ name }});
{%  endif %}
{% endfor %}
    };
{% for instr in instrs["set"] %}
{%  set name_func = "emit" + case_camel_upper(instr["name"]) %}
{%  set name_enum = "CatspeakCartInst." + case_snake_upper(instr["name"]) %}
{%  set func_args = instr.get("args", []) %}

    /// {{ case_sentence(instr["desc"]) }}
{%  for arg in func_args %}
    ///
    /// @param {{ ir_type_as_feather_type(arg["type"]) }} {{ arg["name"]}}
    ///     {{ case_sentence(arg["desc"]) }} 
{%  endfor %}
    static {{ name_func }} = function ({{ map(fn_field("name"), func_args) | join(", ") }}) {
        var buff_ = buff;
        {{ ir_assert_cart_exists("buff_") }}
{%  for arg in func_args %}
        {{ ir_assert_type(arg["type"], arg["name"]) }}
{%  endfor %}
        buffer_write(buff_, buffer_{{- instrs["type"] }}, {{ name_enum }});
{%  for arg in func_args %}
        buffer_write(buff_, buffer_{{- arg["type"] }}, {{ arg["name"] }});
{%  endfor %}
    };
{% endfor %}
}

/// TODO
function CatspeakCartReader() constructor {
    /// @ignore
    self.buff = undefined;

    /// TODO
    self.__handleMeta__ = undefined;

    /// TODO
    static setTarget = function (buff_) {
        buff = undefined;
        __catspeak_assert(buffer_exists(buff_), "buffer doesn't exist");
        var failedMessage = undefined;
        try {
{% for item in header %}
            if (buffer_read(buff_, buffer_{{- item["type"] }}) != {{ ir_type_as_gml_literal(item["type"], item["value"]) }}) {
                failedMessage = "failed to read Catspeak cartridge: '{{ item['value'] }}' ({{ item['type'] }}) missing from header";
            }
{% endfor %}
        } catch (ex_) {
            __catspeak_error("error occurred when trying to read Catspeak cartridge: ", ex_.message);
        }
        if (failedMessage != undefined) {
            __catspeak_error(failedMessage);
        }
        refMeta = buffer_read(buff_, buffer_{{- spec["meta-offset"] }});
        refMeta += buffer_tell();
        refInstrs = buffer_tell();
        // TODO: load metadata
        buffer_seek(buff_, buffer_seek_start, refMeta);
        refEndOfFile = buffer_tell();
        // rewind back to instructions
        buffer_seek(buff_, buffer_seek_start, refInstrs);
        buff = buff_;
    }

    /// TODO
    static readInstr = function () {
        var buff_ = buff;
        {{ ir_assert_cart_exists("buff_") }}
        if (buffer_tell() >= refMeta) {
            // we've reached the end
            buffer_seek(buff_, buffer_seek_start, refEndOfFile);
            return false;
        }
        var instrType = buffer_read(buff_, buffer_{{- instrs["type"] }});
        __catspeak_assert(instrType >= 0 && instrType < CatspeakCartInst.__SIZE__,
            "invalid cartridge instruction"
        );
        var instrReader = __readerLookup[instrType];
        instrReader();
        return true;
    };
{% for instr in instrs["set"] %}
{%  set name_handler = "__handle" + case_camel_upper(instr["name"]) + "__" %}
{%  set name_func = "__read" + case_camel_upper(instr["name"]) %}
{%  set name_enum = "CatspeakCartInst." + case_snake_upper(instr["name"]) %}
{%  set func_args = instr.get("args", []) %}

    /// TODO
    self.{{- name_handler }} = undefined;
    /// @ignore
    static {{ name_func }} = function () {
{%  if func_args %}
        var buff_ = buff;
{%   for arg in func_args %}
        var {{ arg["name"] }} = buffer_read(buff_, buffer_{{- arg["type"] }});
{%   endfor %}
{%  endif %}
        var handler = {{ name_handler }};
        if (handler != undefined) {
            handler({{ map(fn_field("name"), func_args) | join(", ") }});
        }
    };
{% endfor %}

    /// @ignore
    static __readerLookup = undefined;
    if (__readerLookup == undefined) {
        __readerLookup = array_create(CatspeakCartInst.__SIZE__);
{% for instr in instrs["set"] %}
{%  set name_func = "__read" + case_camel_upper(instr["name"]) %}
{%  set name_enum = "CatspeakCartInst." + case_snake_upper(instr["name"]) %}
        __readerLookup[@ {{ name_enum }}] = {{ name_func }};
{% endfor %}
    }
}
