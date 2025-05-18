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