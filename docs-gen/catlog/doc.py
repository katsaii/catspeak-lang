from dataclasses import dataclass, field

@dataclass
class RichText:
    inner : ... = None

@dataclass
class Bold(RichText): pass

@dataclass
class Emphasis(RichText): pass

@dataclass
class InlineCode(RichText): pass

@dataclass
class Paragraph(RichText): pass

@dataclass
class CodeBlock:
    code : str = None
    caption : str = None

@dataclass
class Media:
    type : str = "image"
    url : str = None
    caption : str = None

@dataclass
class Section:
    title : str = "Section"
    content : ... = None
    subsections : ... = field(default_factory=list)

@dataclass
class Chapter:
    title : str = "Chapter"
    sections : ... = field(default_factory=list)

@dataclass
class Book:
    title : str = "Page"
    brief : str = None
    chapters : ... = field(default_factory=list)

@dataclass
class Link:
    url : str = "https://example.com/"
    name : str = "Example"

@dataclass
class Metadata:
    title : str = "Manual"
    author : str = None
    version : ... = (0, 0, 0)
    footer : ... = None
    links : ... = field(default_factory=list)

def debug_document_create_example_metadata():
    return Metadata(
        title = "Test Book",
        author = "Test Author",
        version = (9, 9, 9),
        links = [Link()]
    )

def debug_document_create_example():
    return Book(
        brief = "Something about stuff.",
        chapters = [
            Chapter(
                sections=[
                    Section(
                        content = [
                            "hi, ",
                            Bold("this is bold"),
                            ", bye"
                        ],
                        subsections = [Section(
                            title = "Other",
                            content = "this is the other section",
                            subsections = [
                                Section(
                                    title = "Another Other",
                                    content = Emphasis(
                                        "this is another other section"
                                    )
                                )
                            ]
                        )]
                    )
                ]
            ),
            Chapter(
                title = "Other Page",
                sections=[
                    Section(
                        content=Paragraph("hi from the other page")
                    )
                ]
            )
        ]
    )