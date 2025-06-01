"""
common functions used between all build scripts
"""

import jinja2
import yaml
import os
from textwrap import dedent

# file handling

def file_load_yaml(path):
    with open(path, "r", encoding="utf-8") as file:
        return yaml.safe_load(file)

def file_load(path):
    with open(path, "r", encoding="utf-8") as file:
        return file.read()

def file_save(path, script):
    with open(path, "w", encoding="utf-8") as file:
        file.write(str(script))

GITHUB_URL = "https://github.com/katsaii/catspeak-lang/blob/main/"
def sanitise_file_path(path):
    if os.path.isfile(path):
        return GITHUB_URL + os.path.relpath(path)
    else:
        return path

def get_generated_header(*paths):
    header = f"// AUTO GENERATED, DO NOT MODIFY THIS FILE\n"
    if len(paths) == 1:
        header += f"// see: {sanitise_file_path(paths[0])}\n"
    elif len(paths) > 1:
        header += "// see:\n"
        for path in paths:
            header += f"//  - {sanitise_file_path(path)}\n"
    return header

# jinja library

JINJA2_FUNCS = [
    map, max, min, len,
]

def jinja2_export(func):
    JINJA2_FUNCS.append(func)
    return func

def case_explode(ident):
    return ident.split()

@jinja2_export
def case_capitalise(ident):
    if not ident:
        return ident
    return ident[0].upper() + ident[1:]

@jinja2_export
def case_sentence(ident):
    ident = case_capitalise(ident)
    return ident + "." if ident else ident

@jinja2_export
def case_snake(ident):
    return "_".join(case_explode(ident))

@jinja2_export
def case_snake_upper(ident):
    return case_snake(ident).upper()

@jinja2_export
def case_camel(ident):
    match case_explode(ident):
        case []: return ""
        case [x]: return x
        case [x, *xs]: return x + "".join(map(case_capitalise, xs))

@jinja2_export
def case_camel_upper(ident):
    return case_capitalise(case_camel(ident))

@jinja2_export
def case_kebab(ident):
    return "-".join(case_explode(ident))

@jinja2_export
def case_kebab_upper(ident):
    return case_kebab(ident).upper()

def ir_unknown_type(type_name): raise Exception(f"unknown type '{type_name}'")

@jinja2_export
def gml_name(name):
    return f"{name}_"

@jinja2_export
def gml_literal(type_name, value):
    match type_name:
        case "i32" | "u32" | "f64" | "u8":
            return value
        case "string": return f"@'{value}'"
        case t: ir_unknown_type(t)

@jinja2_export
def gml_literal_default(type_name):
    match type_name:
        case "i32" | "u32" | "f64" | "u8":
            return "0"
        case "string": return "\"\""
        case t: ir_unknown_type(t)

@jinja2_export
def gml_type_feather(type_name):
    match type_name:
        case "i32" | "u32" | "f64" | "u8":
            return "{Real}"
        case "string": return "{String}"
        case t: ir_unknown_type(t)

@jinja2_export
def gml_type_buffer(type_name):
    match type_name:
        case "i32" | "u32" | "f64" | "u8" | "string":
            return f"buffer_{type_name}"
        case t: ir_unknown_type(t)

@jinja2_export
def gml_assert_cart(buff_name):
    return f"__catspeak_assert(__catspeak_buffer_exists({buff_name}), \"no cartridge loaded\");"

@jinja2_export
def gml_assert_type(type_name, var_name):
    match type_name:
        case "i32" | "u32" | "f64" | "u8":
            condition = f"is_numeric({var_name})"
        case "string":
            condition = f"is_string({var_name})"
        case t: ir_unknown_type(t)
    return f"__catspeak_assert({condition}, \"expected type of {type_name}\");"

@jinja2_export
def gml_chunk_ref(name):
    return "chunk" + case_camel_upper(name)

@jinja2_export
def gml_chunk_head(buff_name):
    return f"cartStart = buffer_tell({ buff_name });"

@jinja2_export
def gml_chunk_patch(ir, name, buff_name):
    if name in ir["chunk-order"]:
        chunk_ref = gml_chunk_ref(name)
        chunk_type = gml_type_buffer(ir["chunk"][name])
        return f"buffer_poke({buff_name}, {chunk_ref}, {chunk_type}, buffer_tell({buff_name}) - cartStart); // patch {name}"
    else:
        raise Exception(f"chunk '{name}' doesn't exist")

@jinja2_export
def gml_chunk_seek(ir, name, buff_name):
    if name in ir["chunk-order"]:
        chunk_ref = gml_chunk_ref(name)
        chunk_type = gml_type_buffer(ir["chunk"][name])
        return f"buffer_seek({buff_name}, buffer_seek_start, cartStart + {chunk_ref}); // seek {name}"
    else:
        raise Exception(f"chunk '{name}' doesn't exist")

@jinja2_export
def gml_var_ref(name, prefix = "v"):
    if prefix == None:
        return case_camel(name)
    return prefix + case_camel_upper(name)

@jinja2_export
def gml_func_arg(arg):
    arg_str = gml_var_ref(arg["name"], None)
    if "default" in arg:
        arg_str += f" = {arg['default']}"
    return arg_str

@jinja2_export
def gml_func_args(args):
    return ", ".join(map(gml_func_arg, args))

@jinja2_export
def gml_func_args_var_ref(args, prefix = "v"):
    return ", ".join(gml_var_ref(arg, prefix) for arg in args)

@jinja2_export
def gml_instr_get_comptime_vm(instr):
    comptime_str = instr["comptime"]
    for arg in (instr.get("args") or []):
        arg_name = arg["name"]
        comptime_str = comptime_str.replace(f"${arg_name}$", arg_name)
    for arg in (instr.get("stackargs") or []):
        arg_name = arg["name"]
        comptime_str = comptime_str.replace(f"${arg_name}$", f"{arg_name}()")
    return comptime_str

@jinja2_export
def util_enum(collection, idx):
    iter_ = collection[idx]
    iter_order = collection.get(f"{idx}-order")
    if iter_order == None:
        if type(iter_) == dict:
            gen = iter_.items()
        else:
            gen = enumerate(iter_)
    else:
        gen = ((i, iter_[i]) for i in iter_order)
    return gen

@jinja2_export
def util_op_index(idx):
    return lambda x: x[idx]

# compat

@jinja2_export
def ir_type_as_gml_literal(type_name, value):
    return gml_literal(type_name, value)

@jinja2_export
def ir_type_as_feather_type(type_name):
    return gml_type_feather(type_name)

@jinja2_export
def ir_type_as_buffer_type(type_name):
    return gml_type_buffer(type_name)

@jinja2_export
def ir_type_default(type_name):
    return gml_default(type_name)

@jinja2_export
def ir_assert_cart_exists(buff_name):
    return gml_assert_cart(buff_name)

@jinja2_export
def ir_assert_type(type_name, var_name):
    return gml_assert_type(type_name, var_name)

@jinja2_export
def ir_enumerate(obj, name):
    return util_enum(obj, name)

@jinja2_export
def fn_field(field_name):
    return util_op_index(field_name)