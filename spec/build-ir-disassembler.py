"""
builds the Catspeak IR disassembler from the catspeak-ir.yaml file
"""

import common

spec_path = "spec/catspeak-ir.yaml"
spec = common.load_yaml(spec_path)
script_header = common.get_header(spec_path, __file__)
script = common.SimpleStringBuilder(script_header)

script.writedoc("""
    Responsible for disassembling a Catspeak cartridge and printing its content
    in a human-readable bytecode format.
""", common.COMMENT_BANGDOC)

# IR sections
spec_header = spec["header"]
spec_instrs = spec["instrs"]

# disassembler
script.writeln()
script.writedoc("""
    TODO
""", common.COMMENT_DOC)
script.writeln("function catspeak_cart_disassemble(buff) {")

script.writeln("}")
script.writeln()
script.writedoc("@ignore", common.COMMENT_DOC)
script.writeln("function __CatspeakCartDisassembler() : CatspeakCartReader() constructor {")
with script.indent():
    script.writedoc("""
        self.str = undefined;
        self.__handleHeader__ = function (refCount) {
            str = "[main, refs=" + string(refCount) + "]\\nfun ():";
        };
    """)
    for instr in spec_instrs["set"]:
        instr_name = instr["name"]
        script.write(f"self.__handle{common.case_camel_upper(instr_name)}__ = function (")
        if "args" in instr:
            script.write(", ".join(arg["name"] for arg in instr["args"]))
        script.writeln(") {")
        with script.indent():
            script.writeln(f"str += \"\\n  {common.case_snake_upper(instr_name)}\";")
            if "args" in instr:
                for arg in instr["args"]:
                    arg_name = arg["name"]
                    script.writeln(f"str += \"  \" + string({arg_name});")
        script.writeln("};")
script.writeln("}")

common.save_gml(script, "src-lts/scripts/scr_catspeak_disassembler/scr_catspeak_disassembler.gml")