from dataclasses import dataclass, field

@dataclass
class RichText:
    type : ... = "span"
    inner : ... = None

@dataclass
class Section:
    title : str = "Section"
    content : ... = None
    subsections : ... = field(default_factory=list)

@dataclass
class Book:
    title : str = "Page"
    brief : str = None
    sections : ... = field(default_factory=list)

@dataclass
class Link:
    url : str = "https://example.com/"
    name : str = "Example"

@dataclass
class Metadata:
    title : str = "Manual"
    author : str = None
    version : ... = (0, 0, 0)
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
        sections = [
            Section(
                content = [
                    "hi, ",
                    RichText("bold", "this is bold"),
                    ", bye"
                ],
                subsections = [Section(
                    title = "Other",
                    content = "this is the other section",
                    subsections = [
                        Section(
                            title = "Another Other",
                            content = RichText("emphasis", "this is another other section")
                        )
                    ]
                )]
            ),
            Section(
                title = "Other Page",
                content="hi from the other page"
            )
        ]
    )