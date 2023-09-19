from pathlib import Path
from . import lib
import re

def script_name_to_module_name(module):
    name = module.replace("scr_", "").replace("catspeak_", "")
    return name

def parse_module(fullpath):
    name = script_name_to_module_name(Path(fullpath).with_suffix("").name)
    module = lib.Module(name, "")
    doc = lib.DocComment()
    with open(fullpath, "r", encoding="utf-8") as file:
        print(f"...parsing gml module '{name}'")
        for line in file.readlines():
            if match := re.search("^\s*//!(.*)", line):
                module.overview += f"{match.group(1)}\n"
            elif match := re.search("^\s*///(.*)", line):
                doc.current().desc += f"{match.group(1)}\n"
            elif match := re.search("^\s*#macro\s*([A-Za-z0-9_]+)\s*(.*)", line):
                # MACROS
                module.definitions.append(lib.Macro(
                    name = match.group(1),
                    documentation = doc,
                    expands_to = match.group(2)
                ))
                doc = lib.DocComment()
            elif match := re.search("^\s*enum\s*([A-Za-z0-9_]+)", line):
                # ENUMS
                module.definitions.append(lib.Enum(
                    name = match.group(1),
                    documentation = doc
                ))
                doc = lib.DocComment()
            elif match := re.search("^\s*function\s*([A-Za-z0-9_]+)", line):
                # NAMED FUNCTION
                module.definitions.append(lib.Function(
                    name = match.group(1),
                    documentation = doc
                ))
                doc = lib.DocComment()
    return module