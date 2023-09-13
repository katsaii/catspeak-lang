from . import gml, doc, codegen
import os
import re

TITLE_ID_DATABASE = { }
TITLE_ID_CLASHES = { }
TITLE_ID_MAX_LENGTH = 30
def title_to_file_id(title):
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

def compile_book_pages(codegen, meta, book):
    pages = [page for page in codegen.additional_pages()]
    for section in book.sections:
        sb = codegen()
        with sb.root(lang = "en"):
            with sb.meta():
                sb.meta_data(author = meta.author, description = book.brief)
                with sb.meta_title():
                    sb.write(f"{meta.title} - {book.title}")
        path = title_to_file_id(book.title)
        if codegen.EXT:
            path = f"{path}.{codegen.EXT}"
        pages.append((path, sb.content))
    return pages

def write_book_pages(dir, pages):
    for (path, content) in pages:
        fullpath = f"{dir}/{path}"
        fulldir = os.path.dirname(fullpath)
        if not os.path.exists(fulldir):
            os.makedirs(fulldir)
        with open(fullpath, "w") as file:
            file.write(content or "whoops! nothing here! /(.0_0.)_b")