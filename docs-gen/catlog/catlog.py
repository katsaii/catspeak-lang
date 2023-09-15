from . import gml, doc, codegen
from pathlib import Path
import os
import re

TITLE_ID_DATABASE = { }
TITLE_ID_CLASHES = { }
TITLE_ID_MAX_LENGTH = 30
def title_to_uid(*title):
    title = "/".join(title)
    if title in TITLE_ID_DATABASE:
        return TITLE_ID_DATABASE[title]
    title_words = [word.lower() for word in re.split("[^A-Za-z0-9_\.]+", title)]
    title_id = "-".join(title_words)
    if len(title_id) > TITLE_ID_MAX_LENGTH:
        title_id = title_id[:TITLE_ID_MAX_LENGTH] + "+s" # s: short for "short"
    while title_id in TITLE_ID_CLASHES:
        TITLE_ID_CLASHES[title_id] += 1
        title_id = f"{title_id}+{TITLE_ID_CLASHES[title_id]}"
    TITLE_ID_DATABASE[title] = title_id
    TITLE_ID_CLASHES[title_id] = 0
    return title_id

def uid_to_path(uid, ext=None):
    path = Path(uid)
    return path.with_suffix(ext) if ext else path

def write_meta(sb, meta, book, chapter):
    with sb.meta():
        sb.meta_data(author = meta.author, description = book.brief)
        with sb.meta_title():
            sb.write(f"{meta.title} :: {chapter.title} of {book.title}")

def write_header(sb, meta, books):
    with sb.header():
        with sb.heading(1):
            sb.write(meta.title)
        with sb.nav():
            for book in books:
                if len(book.chapters) < 1:
                    continue
                uid = title_to_uid(book.title, book.chapters[0].title)
                with sb.link(uid_to_path(uid, sb.EXT)):
                    sb.write(book.title)

def write_chapters(sb, book):
    with sb.aside(id="chapters"):
        with sb.heading(2):
            sb.write("Chapters")
        for chapter in book.chapters:
            uid = title_to_uid(book.title, chapter.title)
            with sb.link(uid_to_path(uid, sb.EXT)):
                sb.write(chapter.title)

def write_contents(sb, chapter):
    def write_contents_section(sb, section, depth):
        uid = title_to_uid(section.title)
        with sb.anchor(uid):
            sb.write(section.title)
        for subsection in section.subsections:
            write_contents_section(sb, subsection, depth + 1)

    with sb.aside(id="contents"):
        with sb.heading(2):
            sb.write("Contents")
        for section in chapter.sections:
            write_contents_section(sb, section, 0)

def write_main(sb, chapter):
    with sb.main():
        with sb.article():
            for section in chapter.sections:
                write_section(sb, section)

def write_section(sb, section):
    with sb.section():
        with sb.heading(1, id=title_to_uid(section.title)):
            sb.write(section.title)
        write_richtext(sb, section.content)
        for subsection in section.subsections:
            write_section(sb, subsection)

def write_richtext(sb, content):
    if type(content) is str:
        sb.write(content)
    elif type(content) is list:
        for child_content in content:
            write_richtext(sb, child_content)
    elif type(content) is doc.RichText:
        style_writer = getattr(sb, content.type)
        if style_writer:
            with style_writer():
                write_richtext(sb, content.inner)
        else:
            write_richtext(sb, content.inner)
    else:
        sb.write(f"(unknown content {type(content)})".replace("<", "&lt;"))

def write_footer(sb, meta):
    with sb.footer():
        with sb.article():
            write_brand(sb)
        if meta.footer != None:
            with sb.article():
                write_richtext(sb, meta.footer)

def write_brand(sb):
    with sb.emphasis(id="brand"):
        sb.write("Built using ")
        with sb.link("#"):
            sb.write("Catlog")
        sb.write(", the ")
        with sb.link("https://github.com/katsaii/catspeak-lang"):
            sb.write("Catspeak")
        sb.write(" book generator.")

def compile_books(codegen, meta, *books):
    pages = [page for page in codegen.additional_pages()]
    for book in books:
        for chapter in book.chapters:
            sb = codegen()
            uid = title_to_uid(book.title, chapter.title)
            path = uid_to_path(uid, codegen.EXT)
            with sb.root(lang = "en"):
                write_meta(sb, meta, book, chapter)
                with sb.body():
                    write_header(sb, meta, books)
                    sb.hr()
                    write_chapters(sb, book)
                    write_contents(sb, chapter)
                    write_main(sb, chapter)
                    sb.hr()
                    write_footer(sb, meta)
            pages.append((path, sb.content))
    return pages

def write_book_pages(dir, pages):
    for (path, content) in pages:
        fullpath = Path(dir).joinpath(path)
        if not fullpath.parent.exists():
            os.makedirs(fullpath.parent)
        with open(fullpath, "w", encoding="utf-8") as file:
            print(f"...writing '{fullpath}'")
            file.write(content or "whoops! nothing here! /(.0_0.)_b")
    print("done!")