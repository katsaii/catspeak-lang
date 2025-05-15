"""
builds the Catspeak IR compiler from the catspeak-ir.yaml file
"""

import common

spec_path = "spec/catspeak-ir.yaml"
spec = common.load_yaml(spec_path)
script_header = common.get_header(spec_path, __file__)
script = common.SimpleStringBuilder(script_header)

script.writedoc("""
    Responsible for the reading and writing of Catspeak IR (Intermediate
    Representation). Catspeak IR is a binary format that can be saved
    and loaded from a file, or treated like a "ROM" or "cartridge".
""", common.COMMENT_BANGDOC)
script.writeln()

# IR sections
spec_header = spec["header"]
spec_meta = spec["meta"]
spec_instrs = spec["instrs"]

# build IR enum
script.writedoc(f"""
    The type of Catspeak IR instruction.

    Catspeak stores cartridge code in reverse-polish notation, where each
    instruction may push (or pop) intermediate values onto a virtual stack.

    Depending on the export, this may literally be a stack--such as with a
    so-called "stack machine" VM. Other times the "stack" may be an abstraction,
    such as with the GML export, where Catspeak cartridges are transformed into
    recursive GML function calls. (This ends up being faster for reasons I won't
    detail here.)

    Each instruction may also be associated with zero or many static parameters.
""", common.COMMENT_DOC)
script.writeln("enum CatspeakCartInst {")
with script.indent():
    for instr in spec_instrs["set"]:
        instr_name = instr["name"]
        instr_desc = common.case_sentence(instr["desc"])
        instr_repr = f" = {instr["repr"]}" if "repr" in instr else ""
        if instr_desc:
            script.writedoc(instr_desc, common.COMMENT_DOC)
        script.writeln(f"{common.case_snake_upper(instr_name)}{instr_repr},")
    script.writedoc("""
        /// @ignore
        __SIZE__,
    """)
script.writeln("}")
script.writeln()

def ir_type_coerce(type_name, value):
    match type_name:
        case "i32" | "u32" | "f64" | "u8":
            return value
        case "string": return f"@'{value}'"
    raise Exception(f"unknown type '{type_name}'")

def ir_type_check(writer, type_name, var_name):
    def do_assert(condition):
        writer.writeln(f"__catspeak_assert({condition}, \"expected type of {type_name}\");")
    match type_name:
        case "i32" | "u32" | "f64" | "u8":
            return do_assert(f"is_numeric({var_name})")
        case "string": return do_assert(f"is_string({var_name})")
    raise Exception(f"unknown type '{type_name}'")

def ir_type_write(writer, buff_name, type_name, var_name, offset=None):
    def do_write(buff_type, value):
        if offset:
            writer.writeln(f"buffer_poke({buff_name}, {offset}, {buff_type}, {value});")
        else:
            writer.writeln(f"buffer_write({buff_name}, {buff_type}, {value});")
    match type_name:
        case "i32": return do_write("buffer_i32", var_name)
        case "u32": return do_write("buffer_u32", var_name)
        case "f64": return do_write("buffer_f64", var_name)
        case "u8": return do_write("buffer_u8", var_name)
        case "string": return do_write("buffer_string", var_name)
    raise Exception(f"unknown type '{type_name}'")

def ir_type_read(writer, buff_name, type_name, var_name):
    def do_read(buff_type, value):
        writer.writeln(f"{value} = buffer_read({buff_name}, {buff_type});")
    match type_name:
        case "i32": return do_read("buffer_i32", var_name)
        case "u32": return do_read("buffer_u32", var_name)
        case "f64": return do_read("buffer_f64", var_name)
        case "u8": return do_read("buffer_u8", var_name)
        case "string": return do_read("buffer_string", var_name)
    raise Exception(f"unknown type '{type_name}'")

def ir_type_default(type_name):
    match type_name:
        case "i32": return "0"
        case "u32": return "0"
        case "f64": return "0"
        case "u8": return "0"
        case "string": return "\"\""

def assert_cart_exists(writer, buff_name):
    writer.writedoc(f"""
        __catspeak_assert({buff_name} != undefined && buffer_exists({buff_name}),
            "no cartridge loaded"
        );
    """)

# build IR writer
script.writedoc("""
    TODO
""", common.COMMENT_DOC)
script.writeln("function CatspeakCartWriter() constructor {")
with script.indent():
    script.writedoc("""
        /// @ignore
        self.buff = undefined;
    """)

    # set the IR target
    script.writeln()
    script.writedoc("""
        TODO
    """, common.COMMENT_DOC)
    script.writeln("static setTarget = function (buff_) {")
    with script.indent():
        script.writedoc("""
            buff = undefined;
            __catspeak_assert(buffer_exists(buff_), "buffer doesn't exist");
            __catspeak_assert_eq(buffer_grow, buffer_get_type(buff_),
                "IR requires a grow buffer (buffer_grow)"
            );
        """)
        for header_item in spec_header:
            header_value = header_item["value"]
            header_type = header_item["type"]
            ir_type_write(script, "buff_", header_type, ir_type_coerce(header_type, header_value))
        ir_type_write(script, "buff_", spec["meta-offset"], 0)
        script.writedoc(f"""
            /// @ignore
            self.refMeta = buffer_tell(buff_);
        """)
        ir_type_write(script, "buff_", spec["instrs-offset"], 0)
        for meta_item in spec_meta:
            meta_name = f"meta{common.case_camel_upper(meta_item['name'])}"
            if "many" in meta_item:
                # array of values
                if "type" in meta_item:
                    value = "[]"
                else:
                    value = "0"
            else:
                # normal value
                value = "undefined"
            script.writedoc("@ignore", common.COMMENT_DOC)
            script.writeln(f"self.{meta_name} = {value};")
        script.writeln("buff = buff_;")
    script.writeln("}")

    # finalise the IR target
    script.writeln()
    script.writedoc("""
        TODO
    """, common.COMMENT_DOC)
    script.writeln("static finaliseTarget = function () {")
    with script.indent():
        script.writedoc("""
            var buff_ = buff;
            buff = undefined;
        """)
        assert_cart_exists(script, "buff_")
        ir_type_write(script, "buff_", spec["meta-offset"], "buffer_tell(buff_) - refMeta", "refMeta")
    script.writeln("};")

    # metadata setters
    for meta_item in spec_meta:
        meta_name = common.case_camel_upper(meta_item['name'])
        meta_desc = "TODO"
        script.writedoc(meta_desc, common.COMMENT_DOC)
        if "many" in meta_item:
            # array of values
            if "type" in meta_item:
                value = "[]"
            else:
                value = "0"
        else:
            # normal value
            script.writeln(f"static set{metaName} = function (v) {{")
            with script.indent():
                script.
            script.writeln("};")

    # allocate references
    script.writeln()
    script.writedoc("""
        TODO
    """, common.COMMENT_DOC)
    script.writeln("static allocRef = function () {")
    with script.indent():
        script.writedoc(f"""
            var refIdx = buffer_peek(buff, refCountOffset, buffer_u32);
            buffer_poke(buff, refCountOffset, buffer_u32, refIdx + 1);
            return refIdx;
        """);
    script.writeln("};")

    # instruction writers
    for instr in spec_instrs["set"]:
        instr_name = instr["name"]
        script.writeln()
        if "desc" in instr:
            instr_desc = "Emit an instruction to " + instr["desc"] + "."
            script.writedoc(instr_desc, common.COMMENT_DOC)
        script.write(f"static emit{common.case_camel_upper(instr_name)} = function (")
        if "args" in instr:
            script.write(", ".join(arg["name"] for arg in instr["args"]))
        script.write(") {")
        script.writeln()
        with script.indent():
            script.writeln("var buff_ = buff;")
            assert_cart_exists(script, "buff_")
            if "args" in instr:
                for arg in instr["args"]:
                    arg_name = arg["name"]
                    ir_type_check(script, arg["type"], arg_name)
            ir_type_write(script, "buff_", spec_instrs["type"], f"CatspeakCartInst.{common.case_snake_upper(instr_name)}")
            if "args" in instr:
                for arg in instr["args"]:
                    arg_name = arg["name"]
                    ir_type_write(script, "buff_", arg["type"], arg_name)
        script.writeln("};")
script.writeln("}")

# build the IR reader
script.writeln()
script.writedoc("""
    TODO
""", common.COMMENT_DOC)
script.writeln("function CatspeakCartReader() constructor {")
with script.indent():
    script.writedoc("""
        /// @ignore
        self.buff = undefined;
    """)

    # set the IR target
    script.writeln()
    script.writedoc("TODO", common.COMMENT_DOC)
    script.writeln(f"self.__handleHeader__ = undefined;")
    script.writeln()
    script.writedoc("""
        TODO
    """, common.COMMENT_DOC)
    script.writeln("static setTarget = function (buff_) {")
    with script.indent():
        script.writedoc("""
            buff = undefined;
            __catspeak_assert(buffer_exists(buff_), "buffer doesn't exist");
            var startOffset = buffer_tell(buff_);
        """)
        for header_item in spec_header:
            header_name = "h" + common.case_camel_upper(header_item["name"])
            header_type = header_item["type"]
            script.writeln(f"var {header_name};")
            ir_type_read(script, "buff_", header_type, header_name)
        script.write("if (")
        first = True
        for header_item in spec_header:
            header_name = "h" + common.case_camel_upper(header_item["name"])
            header_value = ir_type_coerce(header_item["type"], header_item["value"])
            if not first:
                script.write(" &&")
            first = False
            script.writeln()
            script.write(f"    {header_name} == {header_value}")
        script.writeln()
        script.writedoc(f"""
            ) {{
                // successfully loaded IR
                var refCount = buffer_read(buff_, buffer_u32);
                var handler = __handleHeader__;
                if (handler != undefined) {{
                    handler(refCount);
                }}
            }} else {{
                buffer_seek(buff_, buffer_seek_start, startOffset);
                __catspeak_error("failed to read Catspeak cartridge, it may be corrupted");
            }}
            buff = buff_;
        """);
    script.writeln("};")

    # chunk reader
    script.writeln("")
    script.writedoc("TODO", common.COMMENT_DOC)
    script.writeln("static readChunk = function () {")
    with script.indent():
        script.writeln("var buff_ = buff;")
        assert_cart_exists(script, "buff_")
        script.writeln("var instType;")
        ir_type_read(script, "buff_", spec_instrs["type"], "instType")
        script.writedoc("""
            __catspeak_assert(instType >= 0 && instType < CatspeakCartInst.__SIZE__,
                "invalid cartridge instruction"
            );
            var instReader = __readerLookup[instType];
            instReader();
        """)
    script.writeln("};")

    # instruction readers
    for instr in spec_instrs["set"]:
        instr_name = instr["name"]
        instr_name_camel = common.case_camel_upper(instr_name)
        instr_handler_name = f"__handle{instr_name_camel}__"
        instr_reader_name = f"__read{instr_name_camel}"
        script.writeln()
        script.writedoc("TODO", common.COMMENT_DOC)
        script.writeln(f"self.{instr_handler_name} = undefined;")
        script.writeln()
        script.writedoc("@ignore", common.COMMENT_DOC)
        script.write(f"static {instr_reader_name} = function () {{")
        script.writeln()
        with script.indent():
            if "args" in instr:
                script.writeln("var buff_ = buff;")
                for arg in instr["args"]:
                    arg_name = arg["name"]
                    script.writeln(f"var {arg_name};")
                    ir_type_read(script, "buff_", arg["type"], arg_name)
            script.writedoc(f"""
                var handler = {instr_handler_name};
                if (handler != undefined) {{
            """)
            with script.indent():
                script.write("handler(")
                if "args" in instr:
                    script.write(", ".join(arg["name"] for arg in instr["args"]))
                script.writeln(");")
            script.writeln("}")
        script.writeln("};")

    # instruction readers lookup table
    script.writeln()
    script.writedoc("@ignore", common.COMMENT_DOC)
    script.writedoc("""
        static __readerLookup = undefined;
        if (__readerLookup == undefined) {
    """)
    with script.indent():
        script.writeln("__readerLookup = array_create(CatspeakCartInst.__SIZE__);")
        for instr in spec_instrs["set"]:
            instr_name = instr["name"]
            instr_name_camel = common.case_camel_upper(instr_name)
            instr_name_snake = common.case_snake_upper(instr_name)
            script.writeln(f"__readerLookup[@ CatspeakCartInst.{instr_name_snake}] = __read{instr_name_camel};")
    script.writeln("}")
script.writeln("}")

common.save_gml(script, "src-lts/scripts/scr_catspeak_cartridge/scr_catspeak_cartridge.gml")