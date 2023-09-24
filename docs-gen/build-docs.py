from datetime import datetime
from textwrap import dedent
import catlog.catlog as cl

meta = cl.doc.Metadata(
    title = "Catspeak Reference",
    author = "Katsaii",
    version = (3, 0, 0),
)

book_home = cl.doc.Book(
    title = "Home",
    brief = "A brief overview of Catspeak.",
    chapters = [cl.doc.Chapter(
        title = "Welcome",
        overview = cl.doc.parse_content("""
            Welcome to the Catspeak documentation, this page is **extremely**
            work-in-progress. See the "Library Reference" tab for the library
            documentation.
        """)
    )]
)

def compile_gml_book(title, brief, pages):
    book = cl.doc.Book(title, brief)
    for page in pages:
        module = cl.gml.parse_module(f"./src-lts/scripts/{page}/{page}.gml")
        module.sort()
        book.chapters.append(module.into_content())
    return book

book_api = compile_gml_book(
    "Library Reference",
    "The Catspeak library documentation.",
    [
        # basic
        "scr_catspeak_init",
        "scr_catspeak_environment",
        "scr_catspeak_presets",

        # intermediate
        "scr_catspeak_location",
        "scr_catspeak_lexer",
        "scr_catspeak_parser",
        "scr_catspeak_codegen",
        "scr_catspeak_ir",
        "scr_catspeak_operators",

        # advanced
        "scr_catspeak_alloc",
    ]
)

compiled_books = cl.compile_books(cl.html.HTMLCodegen, meta,
    book_home,
    book_api
)

version = f"{meta.version[0]}.{meta.version[1]}.{meta.version[2]}"
cl.write_book_pages(f"docs/{version}", compiled_books)