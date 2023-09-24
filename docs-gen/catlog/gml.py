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

@dataclass
class DocComment:
    ignore : bool = False
    pure : bool = False
    desc : ... = None
    deprecated : ... = None
    unstable : ... = None
    remarks : ... = field(default_factory=list)
    warnings : ... = field(default_factory=list)
    params : ... = field(default_factory=list)
    returns : ... = None
    throws : ... = field(default_factory=list)
    examples : ... = field(default_factory=list)
    current_tag : ... = None

    def is_empty(self):
        if self.ignore or self.pure or self.desc or self.deprecated \
                or self.unstable or self.remarks or self.warnings \
                or self.params or self.returns or self.throws \
                or self.examples or self.current_tag:
            return False
        else:
            return True

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
        if self.examples:
            for i, example  in enumerate(self.examples):
                if len(self.examples) > 1:
                    text.children.append(make_heading(f"Example #{i + 1}"))
                else:
                    text.children.append(make_heading(f"Example"))
                text.children.append(doc.parse_content(example.text))
        return text

@dataclass
class Definition:
    name : str = None
    doc : ... = None
    subdefinitions : ... = field(default_factory=list)

    def is_ignored(self):
        return self.doc.ignore if self.doc != None else False

    def is_valid_subdefinition(self, subdefinition):
        return True

    def add_subdefinition(self, subdefinition):
        if subdefinition.is_ignored() or not self.is_valid_subdefinition(subdefinition):
            return
        self.subdefinitions.append(subdefinition)

    def get_subdefinitions(self):
        return sorted(self.subdefinitions, key = lambda x: x.name)

    def get_doc_richtext(self):
        if self.doc == None:
            return None
        return self.doc.into_richtext()

    def into_content(self):
        raise Exception(f"`into_content` not implemented for type `{type(self)}`")

    def sort(self):
        for subdefinition in self.subdefinitions:
            subdefinition.sort()
        self.subdefinitions = sorted(
            self.subdefinitions,
            key = lambda x: x.name.lower()
        )

@dataclass
class Module(Definition):
    def into_content(self):
        overview = self.get_doc_richtext()
        sections, subchapters = partitian([
            definition.into_content() for definition in self.subdefinitions
        ], lambda x: isinstance(x, doc.Section))
        return doc.Chapter(
            title = f"{self.name}",
            overview = overview,
            sections = sections,
            subchapters = subchapters
        )

@dataclass
class Macro(Definition):
    expands_to : str = None

    def is_valid_subdefinition(self, subdefinition):
        return False

    def signature(self):
        sig = f"#macro {self.name}"
        if self.expands_to:
            sig += " " + self.expands_to
        return sig

    def into_content(self):
        content = doc.RichText([
            doc.CodeBlock([self.signature()]),
            self.get_doc_richtext()
        ])
        return doc.Section(
            title = self.name,
            content = content
        )

@dataclass
class Variable(Definition):
    prefix : str = None

    def is_valid_subdefinition(self, subdefinition):
        return False

    def signature(self):
        sig = self.name
        if self.doc and self.doc.returns:
            sig = f"{sig} : {self.doc.returns.type}"
        return sig

    def into_content(self):
        content = doc.RichText([
            doc.CodeBlock([self.signature()]),
            self.get_doc_richtext()
        ])
        return doc.Section(
            title = self.name,
            content = content
        )

@dataclass
class GlobalVariable(Variable):
    def signature(self):
        return f"globalvar {super().signature()}"

@dataclass
class InstanceVariable(Variable):
    def signature(self):
        return f"self.{super().signature()}"

@dataclass
class StaticVariable(Variable):
    def signature(self):
        return f"static {super().signature()}"

@dataclass
class Enum(Definition):
    expands_to : str = None

    def is_valid_subdefinition(self, subdefinition):
        return isinstance(subdefinition, Variable)

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
        for field in self.subdefinitions:
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
        if len(self.subdefinitions) > 0:
            for field in self.subdefinitions:
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
        if len(sig) > 30 and len(self.subdefinitions) > 0:
            sig = self.signature_block()
        return sig

    def into_content(self):
        content = doc.RichText([
            doc.CodeBlock([self.signature()]),
            self.get_doc_richtext()
        ])
        return doc.Chapter(
            title = f"enum {self.name}",
            overview = content,
            sections = [
                definition.into_content()
                for definition in self.subdefinitions
            ]
        )

    def sort(self): pass

@dataclass
class Function(Definition):
    is_static : bool = False
    is_expr : bool = False

    def is_valid_subdefinition(self, subdefinition):
        return False

    def signature_inline(self):
        sig = "static " if self.is_static else ""
        if self.is_expr:
            sig += f"{self.name} = function("
        else:
            sig += f"function {self.name}("
        for i, param in enumerate(self.doc.params):
            if i > 0:
                sig += ", "
            sig += param.signature()
        sig += ")"
        if self.doc.returns:
            sig += f" -> {self.doc.returns.type}"
        return sig

    def signature_block(self):
        sig = "static " if self.is_static else ""
        if self.is_expr:
            sig += f"{self.name} = function("
        else:
            sig += f"function {self.name}("
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

    def into_content(self):
        content = doc.RichText([
            doc.CodeBlock([self.signature()]),
            self.get_doc_richtext()
        ])
        return doc.Section(
            title = self.name,
            content = content,
            subsections = [
                definition.into_content()
                for definition in self.subdefinitions
            ]
        )

@dataclass
class Constructor(Function):
    # TODO: inheritance

    def is_valid_subdefinition(self, subdefinition):
        return isinstance(subdefinition, InstanceVariable) or \
                isinstance(subdefinition, StaticVariable) or \
                isinstance(subdefinition, Function)

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

    def into_content(self):
        content = doc.RichText([
            doc.CodeBlock([self.signature()]),
            self.get_doc_richtext()
        ])
        return doc.Chapter(
            title = f"struct {self.name}",
            overview = content,
            sections = [
                definition.into_content()
                for definition in self.subdefinitions
            ]
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

def parse_jsdoc_line(doc, line):
    if match := re.search("^\s*(?:@ignore)", line):
        doc.ignore = True
    elif match := re.search("^\s*(?:@unstable)", line):
        doc.current_tag = doc.unstable or DocUnstable()
        doc.unstable = doc.current_tag
    elif match := re.search("^\s*(?:@pure)", line):
        doc.pure = True
    elif match := re.search("^\s*(?:@desc|@description)", line):
        doc.current_tag = doc.desc
    elif match := re.search("^\s*(?:@deprecated)", line):
        doc.current_tag = doc.deprecated or DocDeprecated()
        doc.deprecated = doc.current_tag
    elif match := re.search("^\s*(?:@throws|@throw)\s*\{?([A-Za-z0-9_.]+)\}?", line):
        doc.current_tag = DocThrow(
            type = feather_name_to_type_name(match.group(1))
        )
        doc.throws.append(doc.current_tag)
    elif match := re.search("^\s*(?:@returns|@return)\s*\{?([A-Za-z0-9_.]+)\}?", line):
        doc.current_tag = doc.returns or DocReturn(
            type = feather_name_to_type_name(match.group(1))
        )
        doc.returns = doc.current_tag
    elif match := re.search("^\s*(?:@remark|@rem)", line):
        doc.current_tag = DocRemark()
        doc.remarks.append(doc.current_tag)
    elif match := re.search("^\s*(?:@warning|@warn)", line):
        doc.current_tag = DocWarning()
        doc.warnings.append(doc.current_tag)
    elif match := re.search("^\s*(?:@example)", line):
        doc.current_tag = DocExample()
        doc.examples.append(doc.current_tag)
    elif match := re.search("^\s*(?:@param|@parameter|@arg|@argument)\s*\{?([A-Za-z0-9_.]+)?\}? (\[)?([A-Za-z0-9_.]+)\]?", line):
        doc.current_tag = DocParam(
            type = feather_name_to_type_name(match.group(1)),
            optional = match.group(2) != None,
            name = match.group(3)
        )
        doc.params.append(doc.current_tag)
    else:
        if doc.current_tag == None:
            doc.current_tag = doc.desc or DocDescription()
            doc.desc = doc.current_tag
        doc.current_tag.text += f"{line}\n"

def parse_module(fullpath):
    name = script_name_to_module_name(Path(fullpath).with_suffix("").name)
    module = Module(name, DocComment())
    current_doc = DocComment()
    definition_stack = [(-999, module)]
    brace_balance = 0
    with open(fullpath, "r", encoding="utf-8") as file:
        print(f"...parsing gml module '{name}'")
        for line in file.readlines():
            top_definition = definition_stack[-1][1]
            if match := re.search("^\s*//!(.*)", line):
                parse_jsdoc_line(top_definition.doc, match.group(1))
            elif match := re.search("^\s*///(.*)", line):
                parse_jsdoc_line(current_doc, match.group(1))
            elif match := re.search("^//.*", line):
                pass
            else:
                new_definition = None
                if match := re.search("^\s*#macro\s*([A-Za-z0-9_]+)\s*(.*)", line):
                    # MACROS
                    new_definition = Macro(
                        name = match.group(1),
                        doc = current_doc,
                        expands_to = match.group(2)
                    )
                elif match := re.search("^\s*enum\s*([A-Za-z0-9_]+)", line):
                    # ENUMS
                    new_definition = Enum(
                        name = match.group(1),
                        doc = current_doc
                    )
                elif match := re.search("^\s*function\s*([A-Za-z0-9_]+).*constructor", line):
                    # NAMED CONSTRUCTOR
                    new_definition = Constructor(
                        name = match.group(1),
                        doc = current_doc
                    )
                elif match := re.search("^\s*function\s*([A-Za-z0-9_]+)", line):
                    # NAMED FUNCTION
                    new_definition = Function(
                        name = match.group(1),
                        doc = current_doc
                    )
                elif match := re.search("^\s*static\s*([A-Za-z0-9_]+)\s*=\s*function", line):
                    # ANONYMOUS FUNCTION
                    new_definition = Function(
                        is_static = True,
                        is_expr = True,
                        name = match.group(1),
                        doc = current_doc
                    )
                elif not current_doc.is_empty():
                    # VARIABLES
                    if match := re.search("^\s*globalvar\s*([A-Za-z0-9_]+)", line):
                        new_definition = GlobalVariable(
                            name = match.group(1),
                            doc = current_doc
                        )
                    elif match := re.search("^\s*self\s*\.\s*([A-Za-z0-9_]+)", line):
                        new_definition = InstanceVariable(
                            name = match.group(1),
                            doc = current_doc
                        )
                    elif match := re.search("^\s*static\s*([A-Za-z0-9_]+)", line):
                        new_definition = StaticVariable(
                            name = match.group(1),
                            doc = current_doc
                        )
                    elif match := re.search("^\s*([A-Za-z0-9_]+)", line):
                        new_definition = Variable(
                            name = match.group(1),
                            doc = current_doc
                        )
                current_doc = DocComment()
                if new_definition:
                    definition_stack.append((brace_balance + 1, new_definition))
                    top_definition.add_subdefinition(new_definition)
                brace_balance += line.count("{") - line.count("}")
                while brace_balance < definition_stack[-1][0]:
                    definition_stack.pop()[1]
    return module