"""
builds the Catspeak IR compiler from the catspeak-ir.yaml file
"""

import common

spec_path = "spec/catspeak-ir.yaml"
spec = common.load_yaml(spec_path)
script_header = common.get_header(spec_path, "spec/build-ir.py")
script = common.SimpleStringBuilder(script_header)

script.writedoc("""
    Responsible for the reading and writing of Catspeak HIR (Hierarchial
    Intermediate Representation). HIR is a binary format that can be saved
    and loaded from a file, or treated like a "ROM" or "cartridge".
""", common.COMMENT_BANGDOC)
script.writeln()

# build IR enum
script.writedoc("""
    The type of Catspeak HIR instruction.
""", common.COMMENT_DOC)
script.writeln("enum CatspeakHIRInst {")
with script.indent():
    for term_name, term in spec["terms"].items():
        term_desc = common.case_sentence(term["desc"])
        term_repr = f" = {term["repr"]}" if "repr" in term else ""
        if term_desc:
            script.writedoc(term_desc, common.COMMENT_DOC)
        script.writeln(f"{common.case_snake_upper(term_name)}{term_repr},")
    script.writedoc("""
        /// @ignore
        __SIZE__,
    """)
script.writeln("}")
script.writeln()

# IR header
spec_header = spec["header"]
spec_header_magicnum = spec_header["magic-number"]
spec_header_title = spec_header["cart-title"]

def ir_type_check(writer, type_name, var_name):
    def do_assert(condition):
        writer.writeln(f"__catspeak_assert({condition}, \"expected type of {type_name}\");")
    match type_name:
        case "number": do_assert(f"is_numeric({var_name})")
        case "bool": do_assert(f"is_numeric({var_name})")
        case "string": do_assert(f"is_string({var_name})")

def ir_type_write(writer, type_name, var_name):
    def do_write(buff_type, value):
        writer.writeln(f"buffer_write(buff, {buff_type}, {value});")
    match type_name:
        case "number": do_write("buffer_f64", var_name)
        case "bool": do_write("buffer_u8", var_name)
        case "string": do_write("buffer_string", var_name)

def ir_type_read(writer, type_name, var_name):
    def do_read(buff_type, value):
        writer.writeln(f"{value} = buffer_read(buff, {buff_type});")
    match type_name:
        case "number": do_read("buffer_f64", f"var {var_name}")
        case "bool": do_read("buffer_u8", f"var {var_name}")
        case "string": do_read("buffer_string", f"var {var_name}")

# build IR writer
script.writedoc("""
    TODO
""", common.COMMENT_DOC)
script.writeln("function CatspeakHIRWriter() constructor {")
with script.indent():
    script.writedoc("""
        /// @ignore
        self.buff = undefined;
        /// @ignore
        self.refCountOffset = undefined;
    """)

    # set the IR target
    script.writeln()
    script.writedoc("""
        TODO
    """, common.COMMENT_DOC)
    script.writeln("static setTarget = function (buff_) {")
    with script.indent():
        script.writedoc(f"""
            buff = undefined;
            refCountOffset = undefined;
            __catspeak_assert(buffer_exists(buff_), "buffer doesn't exist");
            __catspeak_assert_eq(buffer_grow, buffer_get_type(buff_),
                "HIR requires a grow buffer (buffer_grow)"
            );
            var buffOffset = buffer_tell(buff_);
            var headNum = {spec_header_magicnum};
            var headTitle = @'{spec_header_title}';
            var loadBuff = false;
            try {{
                loadBuff = (
                    buffer_read(buff_, buffer_u32) == headNum &&
                    buffer_read(buff_, buffer_string) == headTitle
                );
            }} catch (ex) {{
                __catspeak_error_silent("failed to read buffer header:\\n", ex.message);
            }}
            if (loadBuff) {{
                // patch existing HIR file
                refCountOffset = buffer_tell(buff_);
                __catspeak_error_unimplemented("patching HIR");
            }} else {{
                // new HIR file
                buffer_seek(buff_, buffer_seek_start, buffOffset);
                buffer_write(buff_, buffer_u32, headNum);
                buffer_write(buff_, buffer_string, headTitle);
                // pointer to number of local vars
                refCountOffset = buffer_tell(buff_);
                buffer_write(buff_, buffer_u32, 0);
            }}
            buff = buff_;
        """);
    script.writeln("}")

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
    for term_name, term in spec["terms"].items():
        script.writeln()
        if "desc" in term:
            term_desc = "Emit an instruction to " + term["desc"] + "."
            script.writedoc(term_desc, common.COMMENT_DOC)
        script.write(f"static emit{common.case_camel_upper(term_name)} = function (")
        if "args" in term:
            script.write(", ".join(term["args"]))
        script.write(") {")
        script.writeln()
        with script.indent():
            if "args" in term:
                for arg_name, arg in term["args"].items():
                    ir_type_check(script, arg["type"], arg_name)
            script.writedoc(f"""
                buffer_write(buff, buffer_u8, CatspeakHIRInst.{common.case_snake_upper(term_name)});
            """);
            if "args" in term:
                for arg_name, arg in term["args"].items():
                    ir_type_write(script, arg["type"], arg_name)
        script.writeln("};")
script.writeln("}")

# build the IR reader
script.writeln()
script.writedoc("""
    TODO
""", common.COMMENT_DOC)
script.writeln("function CatspeakHIRReader() constructor {")
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
        script.writedoc(f"""
            buff = undefined;
            __catspeak_assert(buffer_exists(buff_), "buffer doesn't exist");
            var headNum = {spec_header_magicnum};
            var headTitle = @'{spec_header_title}';
            if (
                buffer_read(buff_, buffer_u32) == headNum &&
                buffer_read(buff_, buffer_string) == headTitle
            ) {{
                // successfully loaded HIR
                var refCount = buffer_read(buff_, buffer_u32);
                var handler = __handleHeader__;
                if (handler != undefined) {{
                    handler(refCount);
                }}
            }} else {{
                __catspeak_error("failed to read Catspeak cartridge, it may be corrupted");
            }}
            buff = buff_;
        """);
    script.writeln("}")

    # chunk reader
    script.writeln("")
    script.writedoc("TODO", common.COMMENT_DOC)
    script.writeln("static readChunk = function () {")
    with script.indent():
        script.writedoc("""
            var instType = buffer_read(buff, buffer_u8);
            __catspeak_assert(instType >= 0 && instType < CatspeakHIRInst.__SIZE__,
                "invalid cartridge instruction"
            );
            var instReader = __readerLookup[instType];
            instReader();
        """)
    script.writeln("};")

    # instruction readers
    for term_name, term in spec["terms"].items():
        term_name_camel = common.case_camel_upper(term_name)
        term_handler_name = f"__handle{term_name_camel}__"
        term_reader_name = f"__read{term_name_camel}"
        script.writeln()
        script.writedoc("TODO", common.COMMENT_DOC)
        script.writeln(f"self.{term_handler_name} = undefined;")
        script.writeln()
        script.writedoc("@ignore", common.COMMENT_DOC)
        script.write(f"static {term_reader_name} = function () {{")
        script.writeln()
        with script.indent():
            if "args" in term:
                for arg_name, arg in term["args"].items():
                    ir_type_read(script, arg["type"], arg_name)
            script.writedoc(f"""
                var handler = {term_handler_name};
                if (handler != undefined) {{
            """)
            with script.indent():
                script.write("handler(")
                if "args" in term:
                    script.write(", ".join(term["args"]))
                script.writeln(");")
            script.writeln("}")
        script.writeln("};")

    # instruction readers lookup table
    script.writeln()
    script.writedoc("@ignore", common.COMMENT_DOC)
    script.writeln(f"static __readerLookup = (function () {{")
    with script.indent():
        script.writeln("var lookupDB = array_create(CatspeakHIRInst.__SIZE__);")
        for term_name, term in spec["terms"].items():
            term_name_camel = common.case_camel_upper(term_name)
            term_name_snake = common.case_snake_upper(term_name)
            script.writeln(f"lookupDB[@ CatspeakHIRInst.{term_name_snake}] = __read{term_name_camel};")
        script.writeln("return lookupDB;")
    script.writeln("})();")
script.writeln("}")

# disassembler
script.writeln()
script.writedoc("""
    TODO
""", common.COMMENT_DOC)
script.writeln("function __CatspeakDisassembler() : CatspeakHIRReader() constructor {")
with script.indent():
    script.writedoc("""
        self.str = undefined;
        self.__handleHeader__ = function (refCount) {
            str = "[main, refs=" + string(refCount) + "]\\nfun ():";
        };
    """)
    for term_name, term in spec["terms"].items():
        script.write(f"self.__handle{common.case_camel_upper(term_name)}__ = function (")
        if "args" in term:
            script.write(", ".join(term["args"]))
        script.writeln(") {")
        with script.indent():
            script.writeln(f"str += \"\\n  {common.case_snake_upper(term_name)}\";")
            if "args" in term:
                for arg_name in term["args"]:
                    script.writeln(f"str += \"  \" + string({arg_name});")
        script.writeln("};")
script.writeln("}")

debug = False
if debug:
    print(script)
else:
    ir_path = "src-lts/scripts/scr_catspeak_cartridge/scr_catspeak_cartridge.gml"
    with open(ir_path, "w", encoding="utf-8") as file:
        file.write(str(script))