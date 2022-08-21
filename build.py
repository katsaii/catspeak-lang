import types

# Parses a file containing whitespace separated values into a list of those
# values.
def read_values(fileIn):
    print("Reading file: {}".format(fileIn))
    with open(fileIn) as file:
        return [field for field in file.read().split()]

# Updates a script file with this name.
def write_script(fileOut, lines):
    print("Updating file: {}".format(fileOut))
    with open(fileOut, "w") as file:
        file.writelines("{}\n".format(line) for line in lines)

# Flattens an iterable into a single list.
def flatten(iterable):
    def go(target, iterable):
        if isinstance(iterable, types.GeneratorType) \
        or type(iterable) is list:
            for item in iterable:
                go(target, item)
        else:
            target.append(iterable)
    out = []
    go(out, iterable)
    return out

# Generates the boilerplate code for a schema of enum values.
def generate_enum_stub(name, desc):
    lowerName = name.lower()
    typeName = "Catspeak{}".format(name)
    fields = read_values("enums/{}.tsv".format(lowerName))
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
    write_script(
        "src/scripts/scr_catspeak_{}/scr_catspeak_{}.gml"
                .format(lowerName, lowerName),
        lines,
    )

generate_enum_stub("Token", "Represents a kind of Catspeak token.")
generate_enum_stub("Intcode", "Represents a kind of Catspeak VM instruction.")