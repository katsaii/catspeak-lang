from dataclasses import dataclass, field

@dataclass
class RichText():
    children : ... = field(default_factory=list)

class Paragraph(RichText): pass
class Bold(RichText): pass
class Emphasis(RichText): pass
class Remark(RichText): pass
class Warning(RichText): pass
class Experimental(RichText): pass

@dataclass
class Table(RichText):
    header : ... = field(default_factory=list)

class TableRow(RichText): pass
class TableCell(RichText): pass

@dataclass
class CodeBlock(RichText):
    lang : str = "txt"

class InlineCode(RichText): pass

@dataclass
class Deprecated(RichText):
    since : str = None

@dataclass
class List():
    elements : ... = field(default_factory=list)

@dataclass
class LinkText():
    children : ... = None
    url : str = None

@dataclass
class EmbeddedHTML():
    content : str = ""

@dataclass
class Section:
    title : str = "Section"
    title_content : ... = None
    content : ... = None
    subsections : ... = field(default_factory=list)

@dataclass
class Chapter:
    title : str = "Chapter"
    overview : ... = None
    sections : ... = field(default_factory=list)
    subchapters : ... = field(default_factory=list)

@dataclass
class Book:
    title : str = "Page"
    brief : str = None
    chapters : ... = field(default_factory=list)

@dataclass
class Link:
    name : str = None
    url : str = None

@dataclass
class Copyright:
    assets : ... = field(default_factory=list)
    authors : ... = field(default_factory=list)
    year_start : int = None
    year_end : int = None
    license : ... = None

@dataclass
class Metadata:
    title : str = "Manual"
    author : str = None
    version : ... = (0, 0, 0)
    copyrights : ... = field(default_factory=list)