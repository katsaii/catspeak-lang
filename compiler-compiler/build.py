"""
The Catspeak Compiler compiler. Generates source files from templated code.

- Reads IR from `def-catspeak-ir.yaml` and does some rough validation.
  Accessible from templated code with `ir`.
- Reads the `fnames-*` files and `gml-perms.txt`, then produces a list of GML
  function names, constants, and properties. Accessible from templated code
  with `fnames`.
"""

import yaml
import json
import os
import subprocess
import jinja2
import jinja2api
import re
from pathlib import Path
from collections import OrderedDict

DEBUG = False

TEMPLATE_PATH = "compiler-compiler/templates"
env = jinja2.Environment(
    loader=jinja2.FileSystemLoader(TEMPLATE_PATH),
    trim_blocks=True,
    lstrip_blocks=True,
    #autoescape=True
)
for func in jinja2api.JINJA2_FUNCS:
    env.globals[func.__name__] = func

SCRIPTS = [
    "compiler-gml/scripts/scr_catspeak_cart/scr_catspeak_cart.gml",
    "compiler-gml/scripts/scr_catspeak_disasm/scr_catspeak_disasm.gml",
    "compiler-gml/scripts/scr_catspeak_gen_gml/scr_catspeak_gen_gml.gml",
    "compiler-gml/scripts/scr_catspeak_api_gml/scr_catspeak_api_gml.gml",
]

GML_FNAMESES = [
    "fnames-vec3-vec4",
    "fnames-2022-lts",
    "fnames-2024-2-0-163",
    "fnames-2026-lts",
]

GML_BLOCKLIST = {
    "nameof",
    "_GMFILE_",
    "_GMLINE_",
    "_GMFUNCTION_",
    "GM_project_filename",
    # can't currently support enums
    "AudioEffectType",
    "AudioLFOType",
    # these symbols aren't needed in fnames because they're Catspeak primitives
    "self",
    "other",
    "true",
    "false",
    "undefined",
    "NaN",
    "infinity",
}
GML_BLOCKLIST_PREFIX = [
    "argument",
    "gml_",
    "phy_",
    "physics_",
    "rollback_",
    "wallpaper_",
]
def is_in_blocklist(symbol):
    global GML_BLOCKLIST
    global GML_BLOCKLIST_PREFIX
    if symbol in GML_BLOCKLIST:
        return True
    for prefix in GML_BLOCKLIST_PREFIX:
        if symbol.startswith(prefix):
            return True
    return False

GML_SYMBOL_MAP = {
    "method": "catspeak_method",
    "method_get_self": "catspeak_get_self",
    "method_get_index": "catspeak_get_index",
    "audio_3D": "audio_3d",
}
env.globals["GML_SYMBOL_MAP"] = GML_SYMBOL_MAP

TAG_NONE       = 0
TAG_FUNCTION   = 0b000001
TAG_CONST      = 0b000010
TAG_PROP_GET   = 0b000100
TAG_PROP_SET   = 0b001000
TAG_PROP_GET_I = 0b010000
TAG_PROP_SET_I = 0b100000
env.globals["TAG_NONE"]       = TAG_NONE
env.globals["TAG_FUNCTION"]   = TAG_FUNCTION
env.globals["TAG_CONST"]      = TAG_CONST
env.globals["TAG_PROP_GET"]   = TAG_PROP_GET
env.globals["TAG_PROP_SET"]   = TAG_PROP_SET
env.globals["TAG_PROP_GET_I"] = TAG_PROP_GET_I
env.globals["TAG_PROP_SET_I"] = TAG_PROP_SET_I

GML_FNAMES_PROP_OVERRIDE = {
    "room_width": TAG_PROP_SET, # these should have setters, according to #160
    "room_height": TAG_PROP_SET,
}

GML_FNAMES_MODIFIERS_OVERRIDE = {
    "debug_mode": "*", # for some reason this disappeared in LTS2026
}

def infer_comment_style_from_path(path):
    match os.path.splitext(path)[1]:
        case ".meow": return "--"
        case ".gml": return "//"
        case _: return "#"

GITHUB_URL = "https://github.com/katsaii/catspeak-lang/blob/main/"
def sanitise_file_path(path):
    if os.path.isfile(path):
        return GITHUB_URL + os.path.relpath(path)
    else:
        return path

def get_generated_header(comment_prefix, *paths):
    header = f"{comment_prefix} AUTO GENERATED, DO NOT MODIFY THIS FILE\n"
    if len(paths) == 1:
        header += f"{comment_prefix} see: {sanitise_file_path(paths[0])}\n"
    elif len(paths) > 1:
        header += f"{comment_prefix} see:\n"
        for path in paths:
            header += f"{comment_prefix}  - {sanitise_file_path(path)}\n"
    return header

# init ir
IR_PATH = "compiler-compiler/def-catspeak-ir.yaml"
with open(IR_PATH, "r", encoding="utf-8") as file:
    ir = yaml.safe_load(file)
ir_instrs_opcodes = { }
ir_instrs_opcode_max = 0
ir_instrs_name_conflict = None
for instr in ir["instr-ops"]:
    # check all opcode fields are unique
    instr_opcode = instr["opcode"]
    instr_name = instr.get("name-short", instr["name"])
    ir_instrs_opcode_max = max(ir_instrs_opcode_max, instr_opcode)
    if instr_opcode in ir_instrs_opcodes:
        ir_instrs_name_conflict = (instr_opcode, instr_name, ir_instrs_opcodes[instr_opcode])
    else:
        ir_instrs_opcodes[instr_opcode] = instr_name
free_opcodes = [
    hex(n)
    for n in range(1, ir_instrs_opcode_max + 1)
    if n not in ir_instrs_opcodes
]
if free_opcodes:
    print(
        "WARNING! there are gaps in the opcodes of IR instructions:\n  " +
        ", ".join(free_opcodes)
    )
if ir_instrs_name_conflict != None:
    (offending_opcode, instr_1, instr_2) = ir_instrs_name_conflict
    candidate_opcode = free_opcodes[0] if free_opcodes else hex(ir_instrs_opcode_max + 1)
    raise Exception(f"""
        instructions '{instr_1}' and '{instr_2}' both have the same opcode: {hex(offending_opcode)}
        (suggestion: change opcode for '{instr_2}' to {candidate_opcode})
    """)

# init fnames
symbols = { }
for fnames_path in GML_FNAMESES:
    with open(fnames_path, "r", encoding="utf-8") as fnames_raw:
        print(f"loading: {fnames_path}")
        for line in fnames_raw:
            symbol_data = line.strip()
            symbol = None
            modifiers = None
            is_function = False
            is_index = False
            if match := re.search(r"^([A-Za-z0-9_]+)\([^\)]*\)(.*)", line):
                symbol = match[1]
                modifiers = match[2]
                is_function = True
            elif match := re.search(r"^([A-Za-z0-9_]+)\[[^\]]*\](.*)", line):
                symbol = match[1]
                modifiers = match[2]
                is_index = True
            elif match := re.search(r"^([A-Za-z0-9_]+)(.*)", line):
                symbol = match[1]
                modifiers = match[2]
            else:
                continue
            if is_in_blocklist(symbol):
                continue
            if "@" in modifiers or \
                    "&" in modifiers or \
                    "?" in modifiers or \
                    "%" in modifiers or \
                    "^" in modifiers:
                # skip: 
                #   @ = instance variable
                #   & = obsolete
                #   % = property
                #   ? = struct variable
                #   ^ = do not add to autocomplete
                continue
            flags = GML_FNAMES_PROP_OVERRIDE.get(symbol, TAG_NONE)
            modifiers = modifiers + GML_FNAMES_MODIFIERS_OVERRIDE.get(symbol, "")
            if is_function:
                flags = flags | TAG_FUNCTION
            elif is_index:
                flags = flags | TAG_PROP_GET_I
                if "*" in modifiers:
                    # * = readonly
                    pass
                else:
                    flags = flags | TAG_PROP_SET_I
            elif "#" in modifiers:
                # # = constant
                flags = flags | TAG_CONST
            else:
                flags = flags | TAG_PROP_GET
                if "*" in modifiers:
                    # * = readonly
                    pass
                else:
                    flags = flags | TAG_PROP_SET
            (expect_flags, owners) = symbols.setdefault(symbol, (flags, []))
            if expect_flags != flags:
                raise Exception(
                    f"flags for symbol {symbol} are different from what " +
                    f"is expected! {flags} != {expect_flags}"
                )
            owners.append(fnames_path)
fnames = { }
for (symbol, (flags, owners)) in symbols.items():
    owners_unique = list(set(owners))
    owners_unique.sort()
    symbols_complete = fnames.setdefault(tuple(set(owners_unique)), [])
    symbols_complete.append((symbol, flags))

# build scripts
for script in SCRIPTS:
    comment_prefix = infer_comment_style_from_path(script)
    temp_header = get_generated_header(
        comment_prefix, IR_PATH, __file__, f"{TEMPLATE_PATH}/{script}"
    )
    temp = env.get_template(script)
    temp_script = temp_header + "\n" + temp.render({
        "ir": ir,
        "fnames": fnames,
    })
    if DEBUG:
        print(f"   path: {script}")
        print(f"content: \n")
        print(temp_script)
    else:
        print(f"writing: {script}")
        with open(script, "w", encoding="utf-8") as file:
            file.write(str(temp_script))