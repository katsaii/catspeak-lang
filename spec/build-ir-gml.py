"""
builds the Catspeak IR compiler from the catspeak-ir.yaml file
"""

import common
import jinja2
from pathlib import Path

scripts = [
    "scr_catspeak_cartridge"
]

spec_path = "spec/catspeak-ir.yaml"
spec = common.load_yaml(spec_path)

def ir_unknown_type(type_name):
    raise Exception(f"unknown type '{type_name}'")

def ir_type_as_gml_literal(type_name, value):
    match type_name:
        case "i32" | "u32" | "f64" | "u8":
            return value
        case "string": return f"@'{value}'"
    ir_unknown_type(type_name)

def ir_type_as_feather_type(type_name):
    match type_name:
        case "i32" | "u32" | "f64" | "u8":
            return "{Real}"
        case "string": return "{String}"
    ir_unknown_type(type_name)

def ir_type_default(type_name):
    match type_name:
        case "i32" | "u32" | "f64" | "u8":
            return "0"
        case "string": return "\"\""
    ir_unknown_type(type_name)

def ir_assert_cart_exists(buff_name):
    return f"__catspeak_assert({buff_name} != undefined && buffer_exists({buff_name}), \"no cartridge loaded\");"

def ir_assert_type(type_name, var_name):
    match type_name:
        case "i32" | "u32" | "f64" | "u8":
            condition = f"is_numeric({var_name})"
        case "string":
            condition = f"is_string({var_name})"
    return f"__catspeak_assert({condition}, \"expected type of {type_name}\");"

def fn_field(field_name):
    return lambda x: x[field_name]

def gml_name(name):
    return f"{name}_"

env = jinja2.Environment(trim_blocks=True, lstrip_blocks=True) #autoescape=True
env_interface = { "spec": spec }
common.get_jinja2_funcs(env.globals, *[
    ir_type_as_gml_literal,
    ir_type_as_feather_type,
    ir_type_default,
    ir_assert_cart_exists,
    ir_assert_type,
    fn_field,
    gml_name,
    map
])

debug = False
for script in scripts:
    script_path_src = f"spec/template/{script}.gml"
    script_path_dest = f"src-lts/scripts/{script}/{script}.gml"
    temp_header = common.get_header(spec_path, __file__, script_path_src)
    temp = env.from_string(common.load_file(script_path_src))
    temp_script = temp_header + "\n" + temp.render(env_interface)
    if debug:
        print(f"    src: {script_path_src}")
        print(f"   dest: {script_path_dest}")
        print(f"content: \n")
        print(temp_script)
    else:
        print(f"writing: {script_path_dest}")
        common.save_file(script_path_dest, temp_script)