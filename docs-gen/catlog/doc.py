from dataclasses import dataclass, field
from textwrap import dedent

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
class Metadata:
    title : str = "Manual"
    author : str = None
    version : ... = (0, 0, 0)
    footer : ... = None