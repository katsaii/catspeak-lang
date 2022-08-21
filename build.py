
# Generates the boilerplate code for a schema of enum values.
def generate_enum_stub(fileIn, fileOut, name, desc):
    with open(fileIn) as file:
        contents = file.read()
    fields = [field for field in contents.split()]
    typeName = "Catspeak{}".format(name)
    lines = []
    lines.append("//! Boilerplate for the `{}` enum.".format(typeName))
    lines.append("")
    lines.append("//# feather use syntax-errors")
    lines.append("")
    lines.append("/// {}".format(desc))
    lines.append("enum {} {{".format(typeName))
    lines.extend("    {},".format(field) for field in fields)
    lines.append("}")
    lines.append("")
    lines.append("/// Gets the name for a value of `{}`.".format(typeName))
    lines.append("/// Will return `<unknown>` if the value is unexpected.")
    lines.append("///")
    lines.append("/// @param {{Enum.{}}} value".format(typeName))
    lines.append("///   The value of `{}` to convert.".format(typeName))
    lines.append("///")
    lines.append("/// @return {String}")
    lines.append("function catspeak_{}_show(value) {{".format(name.lower()))
    lines.append("    switch (value) {")
    lines.extend("    case {}.{}:\n        return \"{}\";"
            .format(typeName, field, field)
            for field in fields
            if not field.startswith("__"))
    lines.append("    }")
    lines.append("    return \"<unknown>\";")
    lines.append("}")
    lines.append("")
    lines.append("/// Parses a string into a value of `{}`.".format(typeName))
    lines.append("/// Will return `undefined` if the value cannot be parsed.")
    lines.append("///")
    lines.append("/// @param {Any} str")
    lines.append("///   The string to parse.")
    lines.append("///")
    lines.append("/// @return {{Enum.{}}}".format(typeName))
    lines.append("function catspeak_{}_read(str) {{".format(name.lower()))
    lines.append("    switch (str) {")
    lines.extend("    case \"{}\":\n        return {}.{};"
            .format(field, typeName, field)
            for field in fields
            if not field.startswith("__"))
    lines.append("    }")
    lines.append("    return undefined;")
    lines.append("}")
    with open(fileOut, "w") as file:
        file.writelines("{}\n".format(line) for line in lines)
    print("Updated file: {}".format(fileOut))

generate_enum_stub(
    "enums/token.tsv",
    "src/scripts/scr_catspeak_token/scr_catspeak_token.gml",
    "Token",
    "Represents a kind of Catspeak token."
)

generate_enum_stub(
    "enums/intcode.tsv",
    "src/scripts/scr_catspeak_intcode/scr_catspeak_intcode.gml",
    "Intcode",
    "Represents a kind of Catspeak VM instruction."
)