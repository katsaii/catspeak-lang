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
function CatspeakCartWriter(buff_) constructor {
    __catspeak_assert(buffer_exists(buff_), "buffer doesn't exist");
    __catspeak_assert_eq(buffer_grow, buffer_get_type(buff_),
        "IR requires a grow buffer (buffer_grow)"
    );
{% for item in header %}
    buffer_write(buff_, buffer_{{ item["type"] }}, {{ ir_type_as_gml_literal(item["type"], item["value"]) }});
{% endfor %}
    /// @ignore
    self.refMeta = buffer_tell(buff_);
    buffer_write(buff_, buffer_{{ spec["meta-offset"] }}, 0);
{% for item in meta %}
{%  set name = "meta" + case_camel_upper(item["name"]) %}
{%  if "many" in item %}
{%   if "type" in item %}
    /// @ignore
    self.{{ name }} = [];
{%   else %}
    /// @ignore
    self.{{ name }} = {{ ir_type_default(item["many"]) }};
{%   endif %}
{%  else %}
    /// @ignore
    self.{{ name }} = {{ ir_type_default(item["type"]) }};
{%  endif %}
{% endfor %}
    /// @ignore
    self.buff = buff_;

    /// TODO
    static finalise = function () {
        var buff_ = buff;
        buff = undefined;
        {{ ir_assert_cart_exists("buff_") }}
        buffer_poke(buff_, refMeta, buffer_{{ spec["meta-offset"] }}, buffer_tell(buff_) - refMeta);
{% for item in meta %}
{%  set name = "meta" + case_camel_upper(item["name"]) %}
{%  if "many" in item %}
{%   if "type" in item %}
        var {{ name }}_ = {{ name }};
        var {{ name }}N = array_length({{ name }}_);
        buffer_write(buff_, buffer_{{ item["many"] }}, {{ name }}N);
        for (var i = {{ name }}N - 1; i >= 0; i -= 1) {
            buffer_write(buff_, buffer_{{ item["type"] }}, {{ name }}_[i]);
        }
{%   else %}
        buffer_write(buff_, buffer_{{ item["many"] }}, {{ name }});
{%   endif %}
{%  else %}
        buffer_write(buff_, buffer_{{ item["type"] }}, {{ name }});
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
{%   if "default" in arg %}
    /// @param {{ ir_type_as_feather_type(arg["type"]) }} [{{ arg["name"]}}]
{%   else %}
    /// @param {{ ir_type_as_feather_type(arg["type"]) }} {{ arg["name"]}}
{%   endif %}
    ///     {{ case_sentence(arg["desc"]) }}
{%  endfor %}
    static {{ name_func }} = function ({{ map(fn_field("name"), func_args) | join(", ") }}) {
        var buff_ = buff;
        {{ ir_assert_cart_exists("buff_") }}
{%  for arg in func_args %}
{%   if "default" in arg %}
        {{ arg["name"] }} ??= {{ arg["default"] }};
{%   endif %}
        {{ ir_assert_type(arg["type"], arg["name"]) }}
{%  endfor %}
        buffer_write(buff_, buffer_{{ instrs["type"] }}, {{ name_enum }});
{%  for arg in func_args %}
        buffer_write(buff_, buffer_{{ arg["type"] }}, {{ arg["name"] }});
{%  endfor %}
    };
{% endfor %}
}

/// TODO
function CatspeakCartReader(buff_, visitor_) constructor {
    __catspeak_assert(buffer_exists(buff_), "buffer doesn't exist");
    __catspeak_assert(is_struct(visitor_), "visitor must be a struct");
{% for instr in instrs["set"] %}
{%  set name_handler = "handle" + case_camel_upper(instr["name"]) %}
    __catspeak_assert(is_method(visitor_[$ "{{ name_handler }}"]),
        "visitor is missing a handler for '{{ name_handler }}'"
    );
{% endfor %}
    var failedMessage = undefined;
    try {
{% for item in header %}
        if (buffer_read(buff_, buffer_{{ item["type"] }}) != {{ ir_type_as_gml_literal(item["type"], item["value"]) }}) {
            failedMessage = "failed to read Catspeak cartridge: '{{ item['value'] }}' ({{ item['type'] }}) missing from header";
        }
{% endfor %}
    } catch (ex_) {
        __catspeak_error("error occurred when trying to read Catspeak cartridge: ", ex_.message);
    }
    if (failedMessage != undefined) {
        __catspeak_error(failedMessage);
    }
    /// @ignore
    self.refMeta = buffer_tell(buff_);
    self.refMeta += buffer_read(buff_, buffer_{{ spec["meta-offset"] }});
    /// @ignore
    self.refInstrs = buffer_tell(buff_);
    buffer_seek(buff_, buffer_seek_start, self.refMeta);
{% for item in meta %}
{%  set name = gml_name(item["name"]) %}
{%  if "many" in item %}
{%   if "type" in item %}
    var {{ name }}N = buffer_read(buff_, buffer_{{ item["many"] }});
    var {{ name }} = array_create({{ name }}N);
    for (var i = {{ name }}N - 1; i >= 0; i -= 1) {
        {{ name }}[@ i] = buffer_read(buff_, buffer_{{ item["type"] }});
    }
{%   else %}
    var {{ name }} = buffer_read(buff_, buffer_{{ item["many"] }});
{%   endif %}
{%  else %}
    var {{ name }} = buffer_read(buff_, buffer_{{ item["type"] }});
{%  endif %}
{% endfor %}
    /// @ignore
    self.refEndOfFile = buffer_tell(buff_);
    // rewind back to instructions
    buffer_seek(buff_, buffer_seek_start, self.refInstrs);
    /// @ignore
    self.buff = buff_;
    /// @ignore
    self.visitor = visitor_;
    if (visitor_.handleMeta != undefined) {
        visitor_.handleMeta({{ map(gml_name, map(fn_field("name"), meta)) | join(", ") }});
    }

    /// TODO
    static readInstr = function () {
        var buff_ = buff;
        {{ ir_assert_cart_exists("buff_") }}
        if (buffer_tell(buff_) >= refMeta) {
            // we've reached the end
            buffer_seek(buff_, buffer_seek_start, refEndOfFile);
            return false;
        }
        var instrType = buffer_read(buff_, buffer_{{ instrs["type"] }});
        __catspeak_assert(instrType >= 0 && instrType < CatspeakCartInst.__SIZE__,
            "invalid cartridge instruction"
        );
        var instrReader = __readerLookup[instrType];
        instrReader();
        return true;
    };
{% for instr in instrs["set"] %}
{%  set name_handler = "handle" + case_camel_upper(instr["name"]) %}
{%  set name_func = "__read" + case_camel_upper(instr["name"]) %}
{%  set name_enum = "CatspeakCartInst." + case_snake_upper(instr["name"]) %}
{%  set func_args = instr.get("args", []) %}

    /// @ignore
    static {{ name_func }} = function () {
{%  if func_args %}
        var buff_ = buff;
{%   for arg in func_args %}
        var {{ arg["name"] }} = buffer_read(buff_, buffer_{{ arg["type"] }});
{%   endfor %}
{%  endif %}
        var visitor_ = visitor;
        if (visitor_.{{ name_handler }} != undefined) {
            visitor_.{{ name_handler }}({{ map(fn_field("name"), func_args) | join(", ") }});
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
