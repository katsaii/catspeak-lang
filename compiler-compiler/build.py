"""
The Catspeak Compiler compiler. Generates source files from templated code.

- Reads IR from `def-catspeak-ir.yaml` and does some rough validation.
  Accessible from templated code with `ir`.
- Reads the `fnames-*` files and `gml-perms.txt`, then produces a list of GML
  function names, constants, and properties. Accessible from templated code
  with `fnames`.
"""

import yaml
import os
import re
import jinja2
import jinja2api
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
    "fnames-2022-lts",
    "fnames-2024-2-0-163",
]

GML_PERMS_SORTED = False
GML_PERMS_KIND = { "COMPTIME", "SAFE", "EFFECTS", "IO", "DRAW", "OS", "UNSAFE" }
GML_PERMS_PATH = "api-gml-perms.txt"
GML_PERMS = { }
with open(GML_PERMS_PATH, "r", encoding="utf-8") as perms:
    for line in perms:
        perm_def = line.split()
        if len(perm_def) >= 2:
            perm = perm_def[1].upper()
            if perm in GML_PERMS_KIND:
                GML_PERMS[perm_def[0]] = perm
            else:
                raise Exception(f"invalid GML perm, expected one of {GML_PERMS_KIND}")
        else:
            GML_PERMS[line.strip()] = None

GML_BLOCKLIST = [
    "argument",
    "nameof",
    "self",
    "other",
    "gml_",
    "phy_",
    "physics_",
    "rollback_",
    "wallpaper_",
    "_GMFILE_",
    "_GMLINE_",
    "_GMFUNCTION_",
    "GM_project_filename",
    # temp
    "AudioEffectType",
    "AudioLFOType",
]
def is_in_blocklist(symbol):
    global GML_BLOCKLIST
    for item in GML_BLOCKLIST:
        if symbol.startswith(item):
            return True
    return False

GML_SYMBOL_MAP = {
    "method": "catspeak_method",
    "method_get_self": "catspeak_get_self",
    "method_get_index": "catspeak_get_index",
}

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
            flags = TAG_NONE
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
                if GML_PERMS[symbol] == None:
                    GML_PERMS[symbol] = "COMPTIME"
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

# re-export api-gml-perms.txt
perms_str = ""
symbols_full = list(OrderedDict.fromkeys(
    [symbol for (_, symbols) in fnames.items() for (symbol, _) in symbols] +
    [symbol for (symbol, _) in GML_PERMS.items()]
))
if GML_PERMS_SORTED:
    symbols_full = sorted(symbols_full, key=str.casefold)
symbols_max_len = max(len(symbol) for symbol in symbols_full)
for symbol in symbols_full:
    perm = GML_PERMS.get(symbol)
    if perm == None:
        perms_str += f"{symbol}\n"
    else:
        symbol_indent = " " * (symbols_max_len - len(symbol))
        perms_str += f"{symbol}{symbol_indent}{perm}\n"
if not DEBUG:
    print(f"updating {GML_PERMS_PATH}")
    with open(GML_PERMS_PATH, "w", encoding="utf-8") as file:
        file.write(perms_str)