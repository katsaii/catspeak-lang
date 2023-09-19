from dataclasses import dataclass, field
from textwrap import dedent

# TODO: don't depend on this external library
import mistletoe

@dataclass
class RawText():
    text : str = None

class Code(RawText): pass
class CodeBlock(RawText): pass

@dataclass
class RichText():
    children : ... = field(default_factory=list)

class Paragraph(RichText): pass
class Bold(RichText): pass
class Emphasis(RichText): pass

@dataclass
class LinkText():
    children : ... = None
    url : str = None

@dataclass
class Section:
    title : str = "Section"
    content : ... = None
    subsections : ... = field(default_factory=list)

@dataclass
class Chapter:
    title : str = "Chapter"
    overview : ... = None
    sections : ... = field(default_factory=list)

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

def parse_content(content):
    doc = mistletoe.Document.read(dedent(content))

    def ast_to_doc(term):
        match type(term):
            case mistletoe.block_tokens.Paragraph:
                return Paragraph(list(map(ast_to_doc, term.children)))
            case mistletoe.span_tokens.Link:
                return Link(list(map(ast_to_doc, term.children)), term.target)
            case mistletoe.span_tokens.RawText:
                return RawText(term.content)
            case mistletoe.span_tokens.Strong:
                return Bold(list(map(ast_to_doc, term.children)))
            case mistletoe.span_tokens.Emphasis:
                return Emphasis(list(map(ast_to_doc, term.children)))
            case mistletoe.span_tokens.LineBreak:
                return RawText("")
            case other:
                return RawText(f"(unknown content {other} {dir(other)})".replace("<", "&lt;"))

    a = RichText(children = list(map(ast_to_doc, doc.children)))
    return a
