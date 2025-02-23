# takes the `fnames-lts` file, parses it, and then generates code so the
# compiler can expose all standard library functions, constants, and properties
# to Catspeak programs

from pathlib import Path
from textwrap import dedent
import os
import re

FNAMES_PATH = "fnames-2024-2-0-163"

blocklist = set([
    "argument",
    "gml_",
    "phy_",
    "physics_",
    "rollback_",
    "wallpaper_",
])
def is_in_blocklist(symbol):
    global blocklist
    for item in blocklist:
        if symbol.startswith(item):
            return True
    return False

# parse fnames
consts = []
functions = []
prop_get = []
prop_set = []
prop_get_i = []
prop_set_i = []
with open(FNAMES_PATH, "r", encoding="utf-8") as fnames:
    for line in fnames:
        symbol_data = line.strip()
        symbol = None
        modifiers = None
        is_function = False
        is_index = False
        if match := re.search("^([A-Za-z0-9_]+)\([^\)]*\)(.*)", line):
            symbol = match[1]
            modifiers = match[2]
            is_function = True
        elif match := re.search("^([A-Za-z0-9_]+)\[[^\]]*\](.*)", line):
            symbol = match[1]
            modifiers = match[2]
            is_index = True
        elif match := re.search("^([A-Za-z0-9_]+)(.*)", line):
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
        if is_function:
            functions.append(symbol)
        elif is_index:
            prop_get_i.append(symbol)
            if "*" in modifiers:
                # * = readonly
                continue
            prop_set_i.append(symbol)
        elif "#" in modifiers:
            # # = constant
            consts.append(symbol)
        else:
            prop_get.append(symbol)
            if "*" in modifiers:
                # * = readonly
                continue
            prop_set.append(symbol)

# write to gml file
codegen_path = Path("src-lts/scripts/__scr_catspeak_gml_interface/__scr_catspeak_gml_interface.gml")
if not codegen_path.parent.exists():
    os.makedirs(codegen_path.parent)
with open(codegen_path, "w", encoding="utf-8") as file:
    print(f"...writing '{codegen_path}'")
    writeln = lambda: file.write("\n")
    file.write(dedent("""
        //! AUTO GENERATED, DON'T MODIFY THIS FILE
        //! DELETE THIS FILE IF YOU DO NOT USE
        //!
        //! ```gml
        //! Catspeak.interface.exposeEverythingIDontCareIfModdersCanEditUsersSaveFilesJustLetMeDoThis = true;
        //! ```

        //# feather use syntax-errors

        /// @ignore
        function __catspeak_get_gml_interface() {
            static db = undefined;
            if (db == undefined) {
                db = { };
    """).strip())
    for symbol in functions:
        writeln()
        if symbol == "method":
            file.write(f"        db[$ \"method\"] = method(undefined, catspeak_method);")
        else:
            file.write(f"        db[$ \"{symbol}\"] = method(undefined, {symbol});")
    for symbol in consts:
        writeln()
        file.write(f"        db[$ \"{symbol}\"] = {symbol};")
    for symbol in prop_get:
        writeln()
        file.write(f"        db[$ \"{symbol}_get\"] = method(undefined, function() {{ return {symbol} }});")
    for symbol in prop_set:
        writeln()
        file.write(f"        db[$ \"{symbol}_set\"] = method(undefined, function(val) {{ {symbol} = val }});")
    file.write(dedent("""
            }
            return db;
        }
    """).rstrip())
    writeln()