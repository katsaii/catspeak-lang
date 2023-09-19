from dataclasses import dataclass, field
from . import doc

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

@dataclass
class Definition:
    name : str = None
    documentation : ... = None

@dataclass
class Macro(Definition):
    expands_to : str = None

@dataclass
class Module():
    name : str = None
    overview : str = None
    definitions : ... = field(default_factory=list)

    def into_chapter(self):
        return doc.Chapter(
            title = self.name,
            overview = doc.parse_content(self.overview)
        )