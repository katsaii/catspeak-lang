from datetime import datetime
from textwrap import dedent
import catlog.catlog as cl
from pathlib import Path

def parse_gml_module(name):
    fullpath = name if Path(name).is_file() else f"./src-lts/scripts/{name}/{name}.gml"
    return cl.gml.parse_module(fullpath)

def parse_md_chapter(name):
    fullpath = name if Path(name).is_file() else f"./src-lts/notes/{name}/{name}.txt"
    return cl.md.parse_chapter(fullpath)

init_module = parse_gml_module("scr_catspeak_init")
version_def = init_module.find("CATSPEAK_VERSION")
version = version_def.expands_to.strip("\"").split(".") if version_def else (9, 9, 9)
print(f"COMPILING VERSION {version}")

meta = cl.doc.Metadata(
    title = "Catspeak Reference",
    author = "Katsaii",
    version = version,
)

book_home = cl.doc.Book(
    title = "Home",
    brief = "A brief overview of Catspeak.",
    chapters = [
        parse_md_chapter("not_catspeak_welcome"),
        parse_md_chapter("not_catspeak_getting_started"),
        parse_md_chapter("./LICENSE"),
    ]
)

def compile_gml_book(title, brief, pages):
    book = cl.doc.Book(title, brief)
    for page in pages:
        module = parse_gml_module(page)
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
        "scr_catspeak_lexer",
        "scr_catspeak_parser",
        "scr_catspeak_codegen",
        "scr_catspeak_ir",
    ]
)

book_api_dubious = compile_gml_book(
    "Dubiously Undocumented",
    "Dubiously undocumented behaviour and quirks.",
    [
        "scr_catspeak_compatibility_v2",
    ]
)

compiled_books = cl.compile_books(cl.html.HTMLCodegen, meta,
    book_home,
    book_api,
    book_api_dubious
)

version = f"{meta.version[0]}.{meta.version[1]}.{meta.version[2]}"
cl.write_book_pages(f"docs/{version}", compiled_books)