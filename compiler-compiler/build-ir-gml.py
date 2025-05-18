"""
builds the Catspeak IR compiler from the def-catspeak-ir.yaml file
"""

import common
import jinja2
from pathlib import Path

scripts = [
    "scr_catspeak_cart",
    "scr_catspeak_disassembler",
    "scr_catspeak_gen_gml",
]

ir_path = "compiler-compiler/def-catspeak-ir.yaml"
ir = common.file_load_yaml(ir_path)
# post-process
ir_commonargs = ir.get("instr-commonargs") or []
ir_instrs = ir.get("instr") or []
ir_instrs_seen_reprs = { }
for instr in ir_instrs:
    # check all repr fields are unique
    instr_repr = instr["repr"]
    instr_name = instr["name"]
    if instr_repr in ir_instrs_seen_reprs:
        instr_name_conflict = ir_instrs_seen_reprs[instr_repr]
        raise Exception(f"instruction '{instr_name}' and '{instr_name_conflict}' both have the same representation: {instr_repr}")
    else:
        ir_instrs_seen_reprs[instr_repr] = instr_name
    # patch common args
    if ir_commonargs:
        if "args" not in instr:
            instr["args"] = []
        instr["args"].extend(ir_commonargs)

env = jinja2.Environment(trim_blocks=True, lstrip_blocks=True) #autoescape=True
env_interface = { "ir": ir }
for func in common.JINJA2_FUNCS:
    env.globals[func.__name__] = func

debug = False
for script in scripts:
    script_path_src = f"compiler-compiler/template/{script}.gml"
    script_path_dest = f"compiler-gml/scripts/{script}/{script}.gml"
    temp_header = common.get_generated_header(
        ir_path, __file__, script_path_src
    )
    temp = env.from_string(common.file_load(script_path_src))
    temp_script = temp_header + "\n" + temp.render(env_interface)
    if debug:
        print(f"    src: {script_path_src}")
        print(f"   dest: {script_path_dest}")
        print(f"content: \n")
        print(temp_script)
    else:
        print(f"writing: {script_path_dest}")
        common.file_save(script_path_dest, temp_script)