"""
takes the `fnames-lts` file, parses it, and then generates code so the
compiler can expose all standard library functions, constants, and properties
to Catspeak programs
"""

from pathlib import Path
from textwrap import dedent
import os
import re

blocklist = [
    "argument",
    "nameof",
    "self",
    "other",
    "gml_",
    "phy_",
    "physics_",
    "rollback_",
    "wallpaper_",
    # temp
    "AudioEffectType",
    "AudioLFOType",
]
def is_in_blocklist(symbol):
    global blocklist
    for item in blocklist:
        if symbol.startswith(item):
            return True
    return False

class FNamesDB:
    NONE       = 0
    FUNCTION   = 0b000001
    CONST      = 0b000010
    PROP_GET   = 0b000100
    PROP_SET   = 0b001000
    PROP_GET_I = 0b010000
    PROP_SET_I = 0b100000

    def __init__(self, path):
        self.path = path
        self.symbols = { }
        # do parse
        with open(self.path, "r", encoding="utf-8") as fnames:
            for line in fnames:
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
                flags = FNamesDB.NONE
                if is_function:
                    flags = flags | FNamesDB.FUNCTION
                elif is_index:
                    flags = flags | FNamesDB.PROP_GET_I
                    if "*" in modifiers:
                        # * = readonly
                        pass
                    else:
                        flags = flags | FNamesDB.PROP_SET_I
                elif "#" in modifiers:
                    # # = constant
                    flags = flags | FNamesDB.CONST
                else:
                    flags = flags | FNamesDB.PROP_GET
                    if "*" in modifiers:
                        # * = readonly
                        pass
                    else:
                        flags = flags | FNamesDB.PROP_SET
                self.symbols[symbol] = flags

fnameses = [
    FNamesDB("fnames-2022-lts"),
    FNamesDB("fnames-2024-2-0-163"),
]

fnames_symbols = { }
for fnames in fnameses:
    for (symbol, flags) in fnames.symbols.items():
        (expect_flags, owners) = fnames_symbols.setdefault(symbol, (flags, []))
        if expect_flags != flags:
            raise Exception(f"flags for symbol {symbol} are different from what is expected! {flags} != {expect_flags}")
        owners.append(fnames)

fnames_complete = { }
for (symbol, (flags, owners)) in fnames_symbols.items():
    owners_key_arr = [x.path for x in owners]
    owners_key_arr.sort()
    owners_key = tuple(owners_key_arr)
    fnames_complete_symbols = fnames_complete.setdefault(owners_key, [])
    fnames_complete_symbols.append((symbol, flags))

# write to GML file
CODEGEN_PATH = Path("src-lts/scripts/__scr_catspeak_gml_interface/__scr_catspeak_gml_interface.gml")
if not CODEGEN_PATH.parent.exists():
    os.makedirs(CODEGEN_PATH.parent)
with open(CODEGEN_PATH, "w", encoding="utf-8") as file:
    print(f"...writing '{CODEGEN_PATH}'")
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
                with ({ }) { // protects from incorrectly reading a missing function from an instance variable
    """).strip())
    for (fnameses, symbols) in fnames_complete.items():
        if len(symbols) < 1:
            continue
        file.write("\n            try {")
        for (symbol, flags) in symbols:
            if flags & FNamesDB.FUNCTION:
                func_subs = {
                    "method" : "catspeak_method",
                    "method_get_self" : "catspeak_get_self",
                    "method_get_index" : "catspeak_get_index",
                }
                if symbol in func_subs:
                    file.write(f"\n                db[$ \"{symbol}\"] = method(undefined, {func_subs[symbol]});")
                else:
                    file.write(f"\n                db[$ \"{symbol}\"] = method(undefined, {symbol});")
            if flags & FNamesDB.CONST:
                if symbol == "global":
                    file.write(f"\n                db[$ \"global\"] = catspeak_special_to_struct(global);")
                else:
                    file.write(f"\n                db[$ \"{symbol}\"] = {symbol};")
            if flags & FNamesDB.PROP_GET:
                file.write(f"\n                db[$ \"{symbol}_get\"] = method(undefined, function () {{ return {symbol} }});")
            if flags & FNamesDB.PROP_SET:
                file.write(f"\n                db[$ \"{symbol}_set\"] = method(undefined, function (__val) {{ {symbol} = __val }});")
            if flags & FNamesDB.PROP_GET_I:
                file.write(f"\n                db[$ \"{symbol}_get\"] = method(undefined, function (__idx) {{ return {symbol}[__idx] }});")
            if flags & FNamesDB.PROP_SET_I:
                file.write(f"\n                db[$ \"{symbol}_set\"] = method(undefined, function (__idx, __val) {{ {symbol}[__idx] = __val }});")
        file.write("\n            } catch (__err) {")
        file.write(f"\n               __catspeak_error_silent(\"skipping GML API versions: {', '.join(fnameses)} (your GameMaker version may be out of date) reason: \", __err.message);")
        file.write("\n            }")
    file.write(dedent("""
                }
            }
            return db;
        }
    """).rstrip())