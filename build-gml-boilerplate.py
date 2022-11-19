import types
import re

EMPTY_STRING = ""

# Converts a CamelCase name into snake_case.
def camel_to_snake(name):
    name = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', name)
    return re.sub('([a-z0-9])([A-Z])', r'\1_\2', name).lower()

# Reads a file as a complete string and returns its contents.
def read_string(fileIn):
    try:
        with open(fileIn) as file:
            print("Reading file: {}".format(fileIn))
            return file.read()
    except FileNotFoundError:
        return None

# Parses a file containing whitespace separated values into a list of those
# values.
def read_values(fileIn):
    content = read_string(fileIn) or ""
    return [field for field in content.split()]

# Updates a script file with this name.
def write_string(fileOut, lines):
    try:
        with open(fileOut):
            # (っ °Д °;)っ why is python making me do this! give me file_exists
            pass
    except FileNotFoundError:
        return None
    with open(fileOut, "w") as file:
        print("Updating file: {}".format(fileOut))
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
def impl_enum(name, desc, private=False):
    lowerName = camel_to_snake(name)
    typeName = "Catspeak{}".format(name)
    typeNameLower = "catspeak_{}".format(lowerName)
    privateDesc = "/// @ignore"
    if private:
        typeName = "__{}".format(typeName)
        typeNameLower = "__{}".format(typeNameLower)
    fields = read_values("enums/{}.tsv".format(lowerName))
    lines = flatten([
        "//! Boilerplate for the [{}] enum.".format(typeName),
        EMPTY_STRING,
        "// NOTE: AVOID EDITING THIS FILE, IT HAS BEEN AUTOMATICALLY GENERATED!",
        EMPTY_STRING,
        "//# feather use syntax-errors",
        EMPTY_STRING,
        privateDesc if private else "/// {}".format(desc),
        "enum {} {{".format(typeName), (
            "    {},".format(field)
            for field in fields
        ), "}",
        EMPTY_STRING,
        privateDesc if private else [
            "/// Gets the name for a value of [{}].".format(typeName),
            "/// Will return `<unknown>` if the value is unexpected.",
            "///",
            "/// @param {{Enum.{}}} value".format(typeName),
            "///   The value of [{}] to convert.".format(typeName),
            "///",
            "/// @return {String}",
        ],
        "function {}_show(value) {{".format(typeNameLower),
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
        privateDesc if private else [
            "/// Parses a string into a value of [{}].".format(typeName),
            "/// Will return `undefined` if the value cannot be parsed.",
            "///",
            "/// @param {Any} str",
            "///   The string to parse.",
            "///",
            "/// @return {{Enum.{}}}".format(typeName),
        ],
        "function {}_read(str) {{".format(typeNameLower),
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
        "}",
        EMPTY_STRING,
        privateDesc if private else [
            "/// Returns the integer representation for a value of [{}]."
                    .format(typeName),
            "/// Will return `undefined` if the value is unexpected.",
            "///",
            "/// @param {{Enum.{}}} value".format(typeName),
            "///   The value of [{}] to convert.".format(typeName),
            "///",
            "/// @return {Real}",
        ],
        "function {}_valueof(value) {{".format(typeNameLower),
        "    gml_pragma(\"forceinline\");",
        "    return value;",
        "}",
        EMPTY_STRING,
        privateDesc if private else [
            "/// Returns the number of elements of [{}].".format(typeName),
            "///",
            "/// @return {Real}",
        ],
        "function {}_sizeof() {{".format(typeNameLower),
        "    gml_pragma(\"forceinline\");",
        "    return {}.{} + 1;".format(typeName, fields[-1])
                if fields else "    return 0;",
        "}",
    ])
    write_string(
        "src/scripts/scr_catspeak_{}/scr_catspeak_{}.gml"
                .format(lowerName, lowerName),
        lines,
    )

# Generates the boilerplate code for a schema of enum flags.
def impl_enum_flags(name, desc, private=False):
    lowerName = camel_to_snake(name)
    typeName = "Catspeak{}".format(name)
    typeNameLower = "catspeak_{}".format(lowerName)
    privateDesc = "/// @ignore"
    if private:
        typeName = "__{}".format(typeName)
        typeNameLower = "__{}".format(typeNameLower)
    fields = read_values("enums/{}.tsv".format(lowerName))
    lines = flatten([
        "//! Boilerplate for the [{}] enum.".format(typeName),
        EMPTY_STRING,
        "//NOTE: AVOID EDITING THIS FILE, IT HAS BEEN AUTOMATICALLY GENERATED!",
        EMPTY_STRING,
        "//# feather use syntax-errors",
        EMPTY_STRING,
        privateDesc if private else "/// {}".format(desc),
        "enum {} {{".format(typeName),
        "    NONE = 0,",
        (
            "    {} = (1 << {}),".format(field, i)
            for i, field in enumerate(fields)
        ),
        "    ALL = (",
        "        {}.NONE".format(typeName),
        (
            "        | {}.{}".format(typeName, field)
            for i, field in enumerate(fields)
        ),
        "    ),",
        "}",
        EMPTY_STRING,
        privateDesc if private else [
            "/// Compares instances of [{}].".format(typeName),
            "/// Returns whether one contains another.",
            "///",
            "/// @param {Any} value",
            "///   The value to check for flags of, must be a numeric value.",
            "///",
            "/// @param {{Enum.{}}} flags".format(typeName),
            "///   The flags of [{}] to check.".format(typeName),
            "///",
            "/// @return {Bool}",
        ],
        "function {}_contains(value, flags) {{".format(typeNameLower),
        "    gml_pragma(\"forceinline\");",
        "    return (value & flags) == flags;",
        "}",
        EMPTY_STRING,
        privateDesc if private else [
            "/// Compares instances of [{}].".format(typeName),
            "/// Returns whether they are equal to each other.",
            "///",
            "/// @param {Any} value",
            "///   The value to check for flags of, must be a numeric value.",
            "///",
            "/// @param {{Enum.{}}} flags".format(typeName),
            "///   The flags of [{}] to check.".format(typeName),
            "///",
            "/// @return {Bool}",
        ],
        "function {}_equals(value, flags) {{".format(typeNameLower),
        "    gml_pragma(\"forceinline\");",
        "    return value == flags;",
        "}",
        EMPTY_STRING,
        privateDesc if private else [
            "/// Compares instances of [{}].".format(typeName),
            "/// Returns whether their flags intersect.",
            "///",
            "/// @param {Any} value",
            "///   The value to check for flags of, must be a numeric value.",
            "///",
            "/// @param {{Enum.{}}} flags".format(typeName),
            "///   The flags of [{}] to check.".format(typeName),
            "///",
            "/// @return {Bool}",
        ],
        "function {}_intersects(value, flags) {{".format(typeNameLower),
        "    gml_pragma(\"forceinline\");",
        "    return (value & flags) != 0;",
        "}",
        EMPTY_STRING,
        privateDesc if private else [
            "/// Gets the name for an instance of [{}].".format(typeName),
            "/// Will return the empty string if the value is unexpected.",
            "///",
            "/// @param {{Enum.{}}} value".format(typeName),
            "///   The value of [{}] to convert, must be a numeric value."
                    .format(typeName),
            "///",
            "/// @return {String}",
        ],
        "function {}_show(value) {{".format(typeNameLower),
        "    var msg = \"\";",
        "    var delimiter = undefined;",
        (
            """    if ((value & {}.{}) != 0) {{
        msg += delimiter ?? "";
        delimiter ??= " | ";
        msg += \"{}\";
    }}""".format(typeName, field, field)
            for i, field in enumerate(fields)
        ),
        "    return msg;",
        "}",
    ])
    write_string(
        "src/scripts/scr_catspeak_{}/scr_catspeak_{}.gml"
                .format(lowerName, lowerName),
        lines,
    )

impl_enum("Token", "Represents a kind of Catspeak token.")
impl_enum("Intcode", "Represents a kind of Catspeak VM instruction.")
impl_enum_flags(
    "ASCIIDesc",
    "Simple tags that identify ASCII characters read from a GML buffer.",
    private=True,
)