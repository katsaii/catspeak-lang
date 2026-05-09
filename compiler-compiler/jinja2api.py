import jinja2

JINJA2_FUNCS = [
    map, max, min, len, str, list,
]

def jinja2_export(func):
    JINJA2_FUNCS.append(func)
    return func

# case conversion

def case_explode(ident):
    return [
        kebab_and_snake_idents
        for word in ident.split()
        for snake_idents in word.split("_")
        for kebab_and_snake_idents in snake_idents.split("-")
    ]

@jinja2_export
def case_capitalise(ident):
    if not ident:
        return ident
    return ident[0].upper() + ident[1:]

@jinja2_export
def case_sentence(ident):
    ident = case_capitalise(ident)
    return ident + "." if ident else ident

@jinja2_export
def case_snake(ident):
    return "_".join(case_explode(ident))

@jinja2_export
def case_snake_upper(ident):
    return case_snake(ident).upper()

@jinja2_export
def case_camel(ident):
    match case_explode(ident):
        case []: return ""
        case [x]: return x
        case [x, *xs]: return x + "".join(map(case_capitalise, xs))

@jinja2_export
def case_camel_upper(ident):
    return case_capitalise(case_camel(ident))

@jinja2_export
def case_kebab(ident):
    return "-".join(case_explode(ident))

@jinja2_export
def case_kebab_upper(ident):
    return case_kebab(ident).upper()

# utils

@jinja2_export
def compose(g, f):
    def inner_(*args, **kwargs):
        return g(f(*args, **kwargs))
    return inner_

@jinja2_export
def join(sep, *iters):
    return sep.join(item for iter_ in iters for item in iter_)

@jinja2_export
def get(*idxs):
    def inner_(collection):
        value = collection
        for idx in idxs:
            value = value[idx]
        return value
    return inner_

@jinja2_export
def args(iter_):
    return [getattr(x, "name_id", x.name) for x in iter_]

@jinja2_export
def ir_enum(collection, idx):
    iter_ = collection.get(idx, [])
    iter_order = collection.get(f"{idx}-order")
    if iter_order == None:
        if type(iter_) == dict:
            gen = iter_.items()
        else:
            gen = enumerate(iter_)
    else:
        gen = ((i, iter_[i]) for i in iter_order)
    return gen

@jinja2_export
def ir_enum_ids(collection, idx, case=case_camel):
    def get_name_(x):
        idx, item = x
        if type(idx) == str:
            return idx
        elif type(item) == dict and "name" in item:
            return item["name"]
        else:
            raise Exception("enum iten has no id")
    return map(compose(case, get_name_), ir_enum(collection, idx))

@jinja2_export
def type_to_gml_literal(type_name, value=None):
    match type_name:
        case "i32" | "u32" | "i16" | "u16" | "i8" | "u8" | "f64":
            return str(value) if value else "0"
        case "string":
            if value:
                if all(ch != '"' for ch in value):
                    return f"\"{value}\""
                else:
                    return f"@'{value}'"
            else:
                return '""'
        case "char":
            return f"ord(\"{value}\")" if value else "0"
        case "bool":
            return f"real({value})" if value else "0"
        case t: raise Exception(f"unknown value type: {t}")

@jinja2_export
def type_to_gml_format(type_name, expr):
    match type_name:
        case "i32" | "u32" | "i16" | "u16" | "i8" | "u8" | "f64":
            return f"string({expr})"
        case "string":
            return f'("\\"" + ({expr}) + "\\"")'
        case "char":
            return f'("\'" + chr({expr}) + "\'")'
        case "bool":
            return f'({expr} ? "true" : "false")'
        case t: raise Exception(f"unknown value type: {t}")

@jinja2_export
def type_to_gml_feather(type_name):
    match type_name:
        case "i32" | "u32" | "i16" | "u16" | "i8" | "u8" | "f64" | "char":
            return "{Real}"
        case "string": return "{String}"
        case "bool": return "{Bool}"
        case t: raise Exception(f"unknown feather type: {t}")

@jinja2_export
def type_to_gml_buffer(type_name):
    match type_name:
        case "u32" | "u16" | "u8" | "f64" | "string":
            return f"buffer_{type_name}"
        case "i32": return "buffer_s32"
        case "i16": return "buffer_s16"
        case "i8": return "buffer_s8"
        case "char" | "bool": return "buffer_u8"
        case t: raise Exception(f"unknown buffer type: {t}")