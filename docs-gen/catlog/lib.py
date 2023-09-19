from dataclasses import dataclass, field
from . import doc

def partitian(xs, p):
    good = [x for x in xs if p(x)]
    bad = [x for x in xs if not p(x)]
    return good, bad

class DocComment:
    @dataclass
    class Tag:
        desc : str = ""

    class Ignore(Tag): pass
    class Unstable(Tag): pass
    class Pure(Tag): pass
    class Description(Tag): pass

    @dataclass
    class Deprecated(Tag):
        since : str = None

    @dataclass
    class Throws(Tag):
        type : str = None

    @dataclass
    class Returns(Tag):
        type : str = None

    class Remark(Tag): pass
    class Warning(Tag): pass

    @dataclass
    class Example(Tag):
        title : str = None

    @dataclass
    class Param(Tag):
        name : str = None
        type : str = None

    def __init__(self):
        self.tags = [DocComment.Description()]

    def current(self):
        return self.tags[-1]

    def into_richtext(self):
        text = doc.RichText()
        descs, other = partitian(self.tags, lambda x: isinstance(x, DocComment.Description))
        text.children += [doc.parse_content(x.desc) for x in descs]
        return text

@dataclass
class Definition:
    name : str = None
    documentation : ... = None

    def into_section(self):
        return doc.Section(
            title = self.name,
            content = self.documentation.into_richtext()
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

    def into_section(self):
        section = super().into_section()
        section.title = f"enum {section.title}"
        return section

@dataclass
class Function(Definition):
    # TODO: named args

    def into_section(self):
        section = super().into_section()
        section.title = f"function {section.title}"
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
            sections = [defn.into_section() for defn in self.definitions]
        )