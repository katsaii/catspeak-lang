from datetime import datetime
from textwrap import dedent
import catlog.catlog as cl

DATE_START = 2021
DATE_END = datetime.now().year

def debug_document_create_example_metadata():
    return cl.doc.Metadata(
        title = "Test Book",
        author = "Test Author",
        version = (9, 9, 9),
    )

def debug_document_create_example():
    return cl.doc.Book(
        brief = "Something about stuff.",
        chapters = [
            cl.doc.Chapter(
                sections=[
                    cl.doc.Section(
                        content = cl.doc.parse_content("hi, **this is bold**, bye"),
                        subsections = [cl.doc.Section(
                            title = "Other",
                            content = cl.doc.parse_content("this is the other section"),
                            subsections = [
                                cl.doc.Section(
                                    title = "Another Other",
                                    content = cl.doc.parse_content("_this is another other section_")
                                )
                            ]
                        )]
                    )
                ]
            ),
            cl.doc.Chapter(
                title = "Other Page",
                sections=[
                    cl.doc.Section(
                        content = cl.doc.parse_content("hi from the other page")
                    )
                ]
            )
        ]
    )

meta = debug_document_create_example_metadata()

book = debug_document_create_example()
book2 = debug_document_create_example()
book2.title = "Other Page"
book2.chapters.append(book2.chapters[0])
book2.chapters[1].sections.pop()

lexer_module = cl.gml.parse_module("./src-lts/scripts/scr_catspeak_lexer/scr_catspeak_lexer.gml")
book2.chapters.append(lexer_module.into_chapter())

pages = cl.compile_books(cl.html.HTMLCodegen, meta, book, book2)
for page in pages:
    #print(pages)
    pass

version = f"{meta.version[0]}.{meta.version[0]}.{meta.version[0]}"
cl.write_book_pages(f"docs/{version}", pages)