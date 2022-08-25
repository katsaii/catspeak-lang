import types

EMPTY_STRING = ""

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
def impl_enum(name, desc):
    lowerName = name.lower()
    typeName = "Catspeak{}".format(name)
    fields = read_values("enums/{}.tsv".format(lowerName))
    lines = flatten([
        "//! Boilerplate for the `{}` enum.".format(typeName),
        EMPTY_STRING,
        "//# feather use syntax-errors",
        EMPTY_STRING,
        "/// {}".format(desc),
        "enum {} {{".format(typeName), (
            "    {},".format(field)
            for field in fields
        ), "}",
        EMPTY_STRING,
        "/// Gets the name for a value of `{}`.".format(typeName),
        "/// Will return `<unknown>` if the value is unexpected.",
        "///",
        "/// @param {{Enum.{}}} value".format(typeName),
        "///   The value of `{}` to convert.".format(typeName),
        "///",
        "/// @return {String}",
        "function catspeak_{}_show(value) {{".format(name.lower()),
        "    switch (value) {",
        (
            [
                "    case {}.{}:".format(typeName, field),
                "        return \"{}\";".format(field)
            ]
            for field in fields
            if not field.startswith("__")
        ),
        "    }",
        "    return \"<unknown>\";",
        "}",
        EMPTY_STRING,
        "/// Parses a string into a value of `{}`.".format(typeName),
        "/// Will return `undefined` if the value cannot be parsed.",
        "///",
        "/// @param {Any} str",
        "///   The string to parse.",
        "///",
        "/// @return {{Enum.{}}}".format(typeName),
        "function catspeak_{}_read(str) {{".format(name.lower()),
        "    switch (str) {",
        (
            [
                "    case \"{}\":".format(field),
                "        return {}.{};".format(typeName, field)
            ]
            for field in fields
            if not field.startswith("__")
        ),
        "    }",
        "    return undefined;",
        "}"
    ])
    write_script(
        "src/scripts/scr_catspeak_{}/scr_catspeak_{}.gml"
                .format(lowerName, lowerName),
        lines,
    )

# Generates the boilerplate code for a schema of enum flags.
def impl_enum_flags(name, desc):
    lowerName = name.lower()
    typeName = "Catspeak{}".format(name)
    fields = read_values("enums/{}.tsv".format(lowerName))
    lines = flatten([
        "//! Boilerplate for the `{}` enum.".format(typeName),
        EMPTY_STRING,
        "//# feather use syntax-errors",
        EMPTY_STRING,
        "/// {}".format(desc),
        "enum {} {{".format(typeName),
        "    NONE = 0,",
        (
            "    {} = (1 << {}),".format(field, i)
            for i, field in enumerate(fields)
        ),
        "    ALL = (",
        (
            "        {}{}.{}".format("| " if i > 0 else "", typeName, field)
            for i, field in enumerate(fields)
        ),
        "    ),",
        "}",
    ])
    write_script(
        "src/scripts/scr_catspeak_{}/scr_catspeak_{}.gml"
                .format(lowerName, lowerName),
        lines,
    )

impl_enum("Token", "Represents a kind of Catspeak token.")
impl_enum("Intcode", "Represents a kind of Catspeak VM instruction.")
impl_enum_flags("Option", "The set of feature flags Catspeak can be configured with.")