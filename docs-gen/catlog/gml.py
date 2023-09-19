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
                line = match.group(1)
                if match := re.search("^\s*(?:@ignore)", line):
                    doc.add(lib.DocComment.Ignore())
                elif match := re.search("^\s*(?:@unstable)", line):
                    doc.add(lib.DocComment.Unstable())
                elif match := re.search("^\s*(?:@pure)", line):
                    doc.add(lib.DocComment.Pure())
                elif match := re.search("^\s*(?:@desc|@description)", line):
                    doc.add(lib.DocComment.Description())
                elif match := re.search("^\s*(?:@deprecated)\s*(since [0-9]+\.[0-9]+\.[0-9]+)?", line):
                    doc.add(lib.DocComment.Deprecated(since = match.group(1)))
                elif match := re.search("^\s*(?:@throws|@throw)\s*\{?([A-Za-z0-9_.]+)?\}?", line):
                    doc.add(lib.DocComment.Throws(type = match.group(1)))
                elif match := re.search("^\s*(?:@returns|@return)\s*\{?([^}]+)?\}?", line):
                    doc.add(lib.DocComment.Returns(type = match.group(1)))
                elif match := re.search("^\s*(?:@remark|@rem)", line):
                    doc.add(lib.DocComment.Remark())
                elif match := re.search("^\s*(?:@warning|@warn)", line):
                    doc.add(lib.DocComment.Warning())
                elif match := re.search("^\s*(?:@example)\s*(.+)?", line):
                    doc.add(lib.DocComment.Example(title = match.group(1)))
                elif match := re.search("^\s*(?:@param|@parameter|@arg|@argument)\s*\{?([A-Za-z0-9_.]+)?\}? (\[)?([A-Za-z0-9_.]+)\]?", line):
                    doc.add(lib.DocComment.Param(
                        type = match.group(1),
                        optional = match.group(2) != None,
                        name = match.group(3)
                    ))
                else:
                    doc.current().desc += f"{line}\n"
            elif match := re.search("^//.*", line):
                pass
            else:
                definition = None
                if match := re.search("^\s*#macro\s*([A-Za-z0-9_]+)\s*(.*)", line):
                    # MACROS
                    definition = lib.Macro(
                        name = match.group(1),
                        documentation = doc,
                        expands_to = match.group(2)
                    )
                elif match := re.search("^\s*enum\s*([A-Za-z0-9_]+)", line):
                    # ENUMS
                    definition = lib.Enum(
                        name = match.group(1),
                        documentation = doc
                    )
                elif match := re.search("^\s*function\s*([A-Za-z0-9_]+)", line):
                    # NAMED FUNCTION
                    definition = lib.Function(
                        name = match.group(1),
                        documentation = doc
                    )
                if definition:
                    module.definitions.append(definition)
                doc = lib.DocComment()
    return module