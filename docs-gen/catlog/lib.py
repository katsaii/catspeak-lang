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
        optional : bool = False

    def __init__(self):
        self.tags = [DocComment.Description()]

    def current(self):
        return self.tags[-1]

    def add(self, tag):
        self.tags.append(tag)

    def into_richtext(self):
        text = doc.RichText()

        def add_section(tags, title=None):
            if not tags:
                return
            if title:
                p = doc.Paragraph()
                p.children.append(doc.Bold(title))
                text.children.append(p)
            text.children += [doc.parse_content(tag.desc) for tag in tags]

        tags = self.tags
        tags_ignore, tags = partitian(tags, lambda x: isinstance(x, DocComment.Ignore))
        tags_unstable, tags = partitian(tags, lambda x: isinstance(x, DocComment.Unstable))
        tags_pure, tags = partitian(tags, lambda x: isinstance(x, DocComment.Pure))
        tags_desc, tags = partitian(tags, lambda x: isinstance(x, DocComment.Description))
        tags_deprecated, tags = partitian(tags, lambda x: isinstance(x, DocComment.Deprecated))
        tags_throws, tags = partitian(tags, lambda x: isinstance(x, DocComment.Throws))
        tags_returns, tags = partitian(tags, lambda x: isinstance(x, DocComment.Returns))
        tags_remark, tags = partitian(tags, lambda x: isinstance(x, DocComment.Remark))
        tags_warning, tags = partitian(tags, lambda x: isinstance(x, DocComment.Warning))
        tags_example, tags = partitian(tags, lambda x: isinstance(x, DocComment.Example))
        tags_param, tags = partitian(tags, lambda x: isinstance(x, DocComment.Param))
        add_section(tags_desc)
        #add_section(tags_ignore, "Ignore")
        #add_section(tags_unstable, "Unstable")
        #add_section(tags_pure, "Purity")
        #add_section(tags_deprecated, "Deprecated")
        #add_section(tags_throws, "Throws")
        #add_section(tags_returns, "Returns")
        #add_section(tags_remark, "Remark")
        #add_section(tags_warning, "Warning")
        #add_section(tags_example, "Example")
        add_section(tags_param, "Param")
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