from dataclasses import dataclass, field
from pathlib import Path
from . import doc
import re

def partitian(xs, p):
    good = [x for x in xs if p(x)]
    bad = [x for x in xs if not p(x)]
    return good, bad

@dataclass
class DocDescription:
    text : str = ""

class DocDeprecated(DocDescription): pass
class DocUnstable(DocDescription): pass
class DocRemark(DocDescription): pass
class DocWarning(DocDescription): pass
class DocExample(DocDescription): pass

@dataclass
class DocThrow(DocDescription):
    type : str = None

@dataclass
class DocReturn(DocDescription):
    type : str = None

@dataclass
class DocParam(DocDescription):
    name : str = None
    type : str = None
    optional : bool = False

    def signature(self):
        sig = self.name or "argument"
        if self.optional:
            sig += "?"
        if self.type:
            sig += f" : {self.type}"
        return sig

class DocComment:
    def __init__(self):
        self.ignore = False
        self.pure = False
        self.desc = None
        self.deprecated = None
        self.unstable = None
        self.remarks = []
        self.warnings = []
        self.params = []
        self.returns = None
        self.throws = []
        self.examples = []

        self.current_tag = None

    def into_richtext(self):
        text = doc.RichText()

        def make_heading(title):
            p = doc.Paragraph()
            p.children.append(doc.Bold(title))
            return p

        if self.desc and self.desc.text.strip():
            text.children.append(doc.parse_content(self.desc.text))
        else:
            text.children.append(doc.parse_content("Undocumented!"))
        if self.params and any(param.text.strip() for param in self.params):
            param_list = doc.List()
            text.children.append(make_heading("Arguments"))
            text.children.append(param_list)
            for i, param in enumerate(self.params):
                if param.name and param.text.strip():
                    optional_text = "_(optional)_ " if param.optional else ""
                    desc = f"`{param.name}` {optional_text}\n\n{param.text}"
                    param_list.elements.append(doc.parse_content(desc))
        return text

@dataclass
class Definition:
    name : str = None
    doc : ... = None

    def into_section(self):
        return doc.Section(
            title = self.name,
            content = self.doc.into_richtext()
        )

@dataclass
class Macro(Definition):
    expands_to : str = None

    def signature(self):
        sig = f"#macro {self.name}"
        if self.expands_to:
            sig += " " + self.expands_to
        return sig

    def into_section(self):
        section = super().into_section()
        section.content = doc.RichText([
            doc.CodeBlock([self.signature()]),
            section.content
        ])
        return section

@dataclass
class EnumField(Definition):
    def signature(self):
        return f"{self.name}"

@dataclass
class Enum(Definition):
    fields : ... = field(default_factory=list)

    def signature_inline(self):
        sig = f"enum {self.name} {{ "
        i = 0

        def add_delimiter():
            nonlocal i
            nonlocal sig
            if i > 0:
                sig += ", "
            i += 1

        ignored = 0
        for field in self.fields:
            if field.doc.ignore:
                ignored += 1
                continue
            add_delimiter()
            sig += field.signature()
        if ignored > 0:
            add_delimiter()
            sig += f"/* +{ignored} fields omitted */"
        sig += "}"
        return sig

    def signature_block(self):
        sig = f"enum {self.name} {{ "
        i = 0

        def add_delimiter():
            nonlocal i
            nonlocal sig
            if i > 0:
                sig += ","
            sig += "\n  "
            i += 1

        ignored = 0
        if len(self.fields) > 0:
            for field in self.fields:
                if field.doc.ignore:
                    ignored += 1
                    continue
                add_delimiter()
                sig += field.signature()
            if ignored > 0:
                add_delimiter()
                sig += f"// +{ignored} fields omitted"
            sig += "\n"
        sig += "}"
        return sig

    def signature(self):
        sig = self.signature_inline()
        if len(sig) > 30 and len(self.fields) > 0:
            sig = self.signature_block()
        return sig

    def into_section(self):
        section = super().into_section()
        section.content = doc.RichText([
            doc.CodeBlock([self.signature()]),
            section.content
        ])
        return section

@dataclass
class Function(Definition):
    def signature_inline(self):
        sig = f"function {self.name}("
        for i, param in enumerate(self.doc.params):
            if i > 0:
                sig += ", "
            sig += param.signature()
        sig += ")"
        if self.doc.returns:
            sig += f" -> {self.doc.returns.type}"
        return sig

    def signature_block(self):
        sig = f"function {self.name}("
        if len(self.doc.params) > 0:
            for i, param in enumerate(self.doc.params):
                sig += "\n  "
                sig += param.signature()
                sig += ","
            sig += "\n"
        sig += ")"
        if self.doc.returns:
            if len(self.doc.params) < 1:
                sig += "\n "
            sig += f" -> {self.doc.returns.type}"
        return sig

    def signature(self):
        sig = self.signature_inline()
        if len(sig) > 30 and len(self.doc.params) > 0:
            sig = self.signature_block()
        return sig

    def into_section(self):
        section = super().into_section()
        section.content = doc.RichText([
            doc.CodeBlock([self.signature()]),
            section.content
        ])
        return section

@dataclass
class Constructor(Function):
    # TODO: inheritance
    fields : ... = field(default_factory=list)

    def signature_inline(self):
        sig = super().signature_inline()
        sig += " constructor { "

        sig += "}"
        return sig

    def signature_block(self):
        sig = super().signature_block()
        sig += " constructor { "

        sig += "}"
        return sig

@dataclass
class Field(Definition):
    is_static : bool = False

    def into_section(self):
        section = super().into_section()
        return section

@dataclass
class Module():
    name : str = None
    overview : str = None
    definitions : ... = field(default_factory=list)

    def into_chapter(self):
        public_defs = [defn for defn in self.definitions if not defn.doc.ignore]
        return doc.Chapter(
            title = self.name,
            overview = doc.parse_content(self.overview),
            sections = [defn.into_section() for defn in public_defs]
        )

# PARSING

def script_name_to_module_name(module):
    name = module.replace("scr_", "").replace("catspeak_", "")
    return name

def feather_name_to_type_name(typename):
    if typename == None:
        typenane = "Any"
    new_elements = []
    for i, element in enumerate(typename.split(".")):
        element = element.strip()
        if i == 0:
            element = element.lower()
        new_elements.append(element)
    return ".".join(new_elements)

def parse_module(fullpath):
    name = script_name_to_module_name(Path(fullpath).with_suffix("").name)
    module = Module(name, "")
    doc = DocComment()
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
                    doc_target = doc.unstable or DocUnstable()
                    doc.unstable = doc_target
                elif match := re.search("^\s*(?:@pure)", line):
                    doc.pure = True
                elif match := re.search("^\s*(?:@desc|@description)", line):
                    doc_target = doc.desc
                elif match := re.search("^\s*(?:@deprecated)", line):
                    doc_target = doc.deprecated or DocDeprecated()
                    doc.deprecated = doc_target
                elif match := re.search("^\s*(?:@throws|@throw)\s*\{?([A-Za-z0-9_.]+)\}?", line):
                    doc_target = DocThrow(
                        type = feather_name_to_type_name(match.group(1))
                    )
                    doc.throws.append(doc_target)
                elif match := re.search("^\s*(?:@returns|@return)\s*\{?([A-Za-z0-9_.]+)\}?", line):
                    doc_target = doc.returns or DocReturn(
                        type = feather_name_to_type_name(match.group(1))
                    )
                    doc.returns = doc_target
                elif match := re.search("^\s*(?:@remark|@rem)", line):
                    doc_target = DocRemark()
                    doc.remarks.append(doc_target)
                elif match := re.search("^\s*(?:@warning|@warn)", line):
                    doc_target = DocWarning()
                    doc.warnings.append(doc_target)
                elif match := re.search("^\s*(?:@example)", line):
                    doc_target = DocExample()
                    doc.examples.append(doc_target)
                elif match := re.search("^\s*(?:@param|@parameter|@arg|@argument)\s*\{?([A-Za-z0-9_.]+)?\}? (\[)?([A-Za-z0-9_.]+)\]?", line):
                    doc_target = DocParam(
                        type = feather_name_to_type_name(match.group(1)),
                        optional = match.group(2) != None,
                        name = match.group(3)
                    )
                    doc.params.append(doc_target)
                else:
                    if doc_target == None:
                        doc_target = doc.desc or DocDescription()
                        doc.desc = doc_target
                    doc_target.text += f"{line}\n"
            elif match := re.search("^//.*", line):
                pass
            else:
                definition = None
                if match := re.search("^\s*#macro\s*([A-Za-z0-9_]+)\s*(.*)", line):
                    # MACROS
                    definition = Macro(
                        name = match.group(1),
                        doc = doc,
                        expands_to = match.group(2)
                    )
                elif match := re.search("^\s*enum\s*([A-Za-z0-9_]+)", line):
                    # ENUMS
                    definition = Enum(
                        name = match.group(1),
                        doc = doc
                    )
                    current_enum = definition
                elif match := re.search("^\s*function\s*([A-Za-z0-9_]+).*constructor", line):
                    # NAMED CONSTRUCTOR
                    definition = Constructor(
                        name = match.group(1),
                        doc = doc
                    )
                elif match := re.search("^\s*function\s*([A-Za-z0-9_]+)", line):
                    # NAMED FUNCTION
                    definition = Function(
                        name = match.group(1),
                        doc = doc
                    )
                elif match := re.search("^\s*([A-Za-z0-9_]+)", line):
                    # FREE VARIABLE
                    if current_enum != None:
                        current_enum.fields.append(EnumField(
                            name = match.group(1),
                            doc = doc
                        ))
                else:
                    current_enum = None
                if definition:
                    module.definitions.append(definition)
                doc = DocComment()
                doc_target = None
    return module