"""
builds the Catspeak IR compilers from the def-catspeak-ir.yaml file
"""

import common
import yaml
import jinja2
from pathlib import Path

scripts = [
    "scr_catspeak_cart", ,
    "scr_catspeak_disassembler",
    "scr_catspeak_gen_gml",
    "__scr_catspeak_instrs_generated",
]

ir_path = "compiler-compiler/def-catspeak-ir-outdated.yaml"
with open(ir_path, "r", encoding="utf-8") as file:
    ir = yaml.safe_load(file)

env = jinja2.Environment(
    loader=jinja2.FileSystemLoader("compiler-compiler/template"),
    trim_blocks=True,
    lstrip_blocks=True,
    #autoescape=True
)
env_interface = { "ir": ir }
for func in common.JINJA2_FUNCS:
    env.globals[func.__name__] = func

debug = False
for script in scripts:
    script_path_src = f"{script}.gml"
    script_path_dest = f"compiler-gml/scripts/{script}/{script}.gml"
    temp_header = common.get_generated_header(
        ir_path, __file__, script_path_src
    )
    temp = env.get_template(script_path_src)
    temp_script = temp_header + "\n" + temp.render(env_interface)
    if debug:
        print(f"    src: {script_path_src}")
        print(f"   dest: {script_path_dest}")
        print(f"content: \n")
        print(temp_script)
    else:
        print(f"writing: {script_path_dest}")
        with open(script_path_dest, "w", encoding="utf-8") as file:
            file.write(str(temp_script))