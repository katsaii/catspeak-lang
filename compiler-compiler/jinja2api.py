import jinja2

JINJA2_FUNCS = [
    map, max, min, len, str, list,
]

def jinja2_export(func):
    JINJA2_FUNCS.append(func)
    return func

# case conversion

def case_explode(ident):
    return [x for word in ident.split() for x in word.split("-")]

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
def join(sep, iter_):
    return sep.join(iter_)

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
def type_to_gml_literal(type_name, value=None):
    match type_name:
        case "i32" | "u32" | "f64" | "u8":
            return str(value) if value != None else "0"
        case "string":
            if value != None:
                if all(ch != '"' for ch in value):
                    return f"\"{value}\""
                else:
                    return f"@'{value}'"
            else:
                return '""'
        case t: ir_unknown_type(t)

@jinja2_export
def type_to_gml_feather(type_name):
    match type_name:
        case "i32" | "u32" | "f64" | "u8":
            return "{Real}"
        case "string": return "{String}"
        case t: ir_unknown_type(t)

@jinja2_export
def type_to_gml_buffer(type_name):
    match type_name:
        case "i32" | "u32" | "f64" | "u8" | "string":
            return f"buffer_{type_name}"
        case t: ir_unknown_type(t)

@jinja2_export
class HeadItem():
    def __init__(self, name, ir):
        self.ir = ir
        self.name = name
        self.name_id = case_camel(name)
        self.type = ir["type"]
        self.type_buffer = type_to_gml_buffer(self.type)
        self.type_feather = type_to_gml_feather(self.type)
        self.value = ir["value"]
        self.value_lit = type_to_gml_literal(self.type, self.value)
        self.value_lit_default = type_to_gml_literal(self.type)

    def enum(ir):
        return (HeadItem(name, ir_) for name, ir_ in ir_enum(ir, "head"))

@jinja2_export
class MetaItem():
    def __init__(self, name, ir):
        self.ir = ir
        self.name = name
        self.name_id = case_camel(name)
        self.desc = ir["desc"]
        self.type = ir["type"]
        self.type_buffer = type_to_gml_buffer(self.type)
        self.type_feather = type_to_gml_feather(self.type)
        self.value_default = ir.get("default", None)
        self.value_lit = type_to_gml_literal(self.type, self.value_default)
        self.value_lit_default = type_to_gml_literal(self.type)

    def enum(ir):
        return (MetaItem(name, ir_) for name, ir_ in ir_enum(ir, "meta"))

@jinja2_export
class InstrItem():
    def __init__(self, ir):
        self.ir = ir
        self.name = ir["name"]
        self.name_short = ir.get("name-short", self.name)
        self.name_id = case_camel(self.name)
        self.name_id_op = case_snake(self.name_short)
        self.name_handler = "handleInstr" + case_camel_upper(self.name)
        self.desc = ir["desc"]
        self.opcode = ir["opcode"]
        if self.opcode == 0x00:
            raise Exception("opcode cannot be 0x00")
        if self.opcode == 0xFF:
            raise Exception("opcode cannot be 0xFF")
        self.comptime = ir.get("comptime", None)
        is_intrinsic = ir.get("intrinsic", False)
        self.intrinsic = f"__intrinsic{case_camel_upper(self.name)}" if is_intrinsic else None

    def enum(ir):
        return (InstrItem(ir_) for _, ir_ in ir_enum(ir, "instr"))

    def max_opcode(ir):
        return max(ir_["opcode"] for _, ir_ in ir_enum(ir, "instr"))

@jinja2_export
class InstrArgItem():
    def __init__(self, idx, ir):
        self.idx = idx
        self.ir = ir
        self.name = ir["name"]
        if not all(ch.isalnum() or ch == "_" for ch in self.name):
            raise Exception("argument names must be alphanumeric")
        self.desc = ir["desc"]
        self.type = ir["type"]
        self.type_buffer = type_to_gml_buffer(self.type)
        self.type_feather = type_to_gml_feather(self.type)

    def enum(ir):
        return (InstrArgItem(idx, ir_) for idx, ir_ in ir_enum(ir, "args"))

@jinja2_export
class InstrStackargItem():
    def __init__(self, idx, ir):
        self.idx = idx
        self.ir = ir
        self.name = ir["name"]
        if not all(ch.isalnum() or ch == "_" for ch in self.name):
            raise Exception("argument names must be alphanumeric")
        self.desc = ir["desc"]

    def enum(ir):
        return (InstrStackargItem(idx, ir_) for idx, ir_ in ir_enum(ir, "stackargs"))

@jinja2_export
class InstrInlineItem():
    def __init__(self, args, ir):
        arg_2_types = { arg.name: arg.type for arg in args }
        self.ir = ir
        self.name = ir["name"]
        if not all(ch.isalnum() or ch == "_" for ch in self.name):
            raise Exception("force-inline names must be alphanumeric")
        self.conditions = {
            name: type_to_gml_literal(arg_2_types[name], value)
            for name, value in ir.get("conditions", [])
        }

    def has_default_impl(ir):
        return not ir.get("force-inline-always", False)

    def enum(ir):
        args = [x for x in InstrArgItem.enum(ir)]
        return (InstrInlineItem(args, ir_) for _, ir_ in ir_enum(ir, "force-inline"))

@jinja2_export
class FuncItem():
    def __init__(self, ir):
        self.ir = ir