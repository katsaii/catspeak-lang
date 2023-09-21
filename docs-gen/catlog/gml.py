from pathlib import Path
from . import lib
import re

def script_name_to_module_name(module):
    name = module.replace("scr_", "").replace("catspeak_", "")
    return name

def feather_name_to_type_name(typename):
    typenane = typename or "Any"
    new_elements = []
    for i, element in enumerate(typename.split(".")):
        element = element.strip()
        if i == 0:
            element = element.lower()
        new_elements.append(element)
    return ".".join(new_elements)

def parse_module(fullpath):
    name = script_name_to_module_name(Path(fullpath).with_suffix("").name)
    module = lib.Module(name, "")
    doc = lib.DocComment()
    doc_target = None
    current_enum = None
    with open(fullpath, "r", encoding="utf-8") as file:
        print(f"...parsing gml module '{name}'")
        for line in file.readlines():
            if match := re.search("^\s*//!(.*)", line):
                module.overview += f"{match.group(1)}\n"
            elif match := re.search("^\s*///(.*)", line):
                line = match.group(1)
                if match := re.search("^\s*(?:@ignore)", line):
                    doc.ignore = True
                elif match := re.search("^\s*(?:@unstable)", line):
                    doc_target = doc.unstable or lib.DocUnstable()
                    doc.unstable = doc_target
                elif match := re.search("^\s*(?:@pure)", line):
                    doc.pure = True
                elif match := re.search("^\s*(?:@desc|@description)", line):
                    doc_target = doc.desc
                elif match := re.search("^\s*(?:@deprecated)", line):
                    doc_target = doc.deprecated or lib.DocDeprecated()
                    doc.deprecated = doc_target
                elif match := re.search("^\s*(?:@throws|@throw)\s*\{?([A-Za-z0-9_.]+)\}?", line):
                    doc_target = lib.DocThrow(
                        type = feather_name_to_type_name(match.group(1))
                    )
                    doc.throws.append(doc_target)
                elif match := re.search("^\s*(?:@returns|@return)\s*\{?([A-Za-z0-9_.]+)\}?", line):
                    doc_target = doc.returns or lib.DocReturn(
                        type = feather_name_to_type_name(match.group(1))
                    )
                    doc.returns = doc_target
                elif match := re.search("^\s*(?:@remark|@rem)", line):
                    doc_target = lib.DocRemark()
                    doc.remarks.append(doc_target)
                elif match := re.search("^\s*(?:@warning|@warn)", line):
                    doc_target = lib.DocWarning()
                    doc.warnings.append(doc_target)
                elif match := re.search("^\s*(?:@example)", line):
                    doc_target = lib.DocExample()
                    doc.examples.append(doc_target)
                elif match := re.search("^\s*(?:@param|@parameter|@arg|@argument)\s*\{?([A-Za-z0-9_.]+)?\}? (\[)?([A-Za-z0-9_.]+)\]?", line):
                    doc_target = lib.DocParam(
                        type = feather_name_to_type_name(match.group(1)),
                        optional = match.group(2) != None,
                        name = match.group(3)
                    )
                    doc.params.append(doc_target)
                else:
                    if doc_target == None:
                        doc_target = doc.desc or lib.DocDescription()
                        doc.desc = doc_target
                    doc_target.text += f"{line}\n"
            elif match := re.search("^//.*", line):
                pass
            else:
                definition = None
                if match := re.search("^\s*#macro\s*([A-Za-z0-9_]+)\s*(.*)", line):
                    # MACROS
                    definition = lib.Macro(
                        name = match.group(1),
                        doc = doc,
                        expands_to = match.group(2)
                    )
                elif match := re.search("^\s*enum\s*([A-Za-z0-9_]+)", line):
                    # ENUMS
                    definition = lib.Enum(
                        name = match.group(1),
                        doc = doc
                    )
                    current_enum = definition
                elif match := re.search("^\s*function\s*([A-Za-z0-9_]+)", line):
                    # NAMED FUNCTION
                    definition = lib.Function(
                        name = match.group(1),
                        doc = doc
                    )
                elif match := re.search("^\s*([A-Za-z0-9_]+)", line):
                    # FREE VARIABLE
                    if current_enum != None:
                        current_enum.fields.append(lib.EnumField(
                            name = match.group(1),
                            doc = doc
                        ))
                else:
                    current_enum = None
                if definition:
                    module.definitions.append(definition)
                doc = lib.DocComment()
                doc_target = None
    return module