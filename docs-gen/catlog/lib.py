from dataclasses import dataclass, field
from . import doc

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
            sig += f" :: {self.type}"
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
                    desc = f"**`{param.name}`**: {optional_text}{param.text}"
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

    def into_section(self):
        section = super().into_section()
        section.title = f"macro {section.title}"
        # TODO: `expands_to`
        return section

@dataclass
class Enum(Definition):
    # TODO: fields

    def signature(self):
        return f"enum {self.name} {{ ... }}"

    def into_section(self):
        section = super().into_section()
        section.title_content = doc.CodeBlock([self.signature()])
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
        section.title_content = doc.CodeBlock([self.signature()])
        return section

@dataclass
class StaticField(Definition):
    def into_section(self):
        section = super().into_section()
        section.title = f"static field {section.title}"
        return section

@dataclass
class Field(Definition):
    def into_section(self):
        section = super().into_section()
        section.title = f"field {section.title}"
        return section

@dataclass
class Module():
    name : str = None
    overview : str = None
    definitions : ... = field(default_factory=list)

    def into_chapter(self):
        return doc.Chapter(
            title = self.name,
            overview = doc.parse_content(self.overview),
            sections = [
                defn.into_section()
                for defn in self.definitions
                if not defn.doc.ignore
            ]
        )