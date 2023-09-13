from . import gml, doc, codegen
import os

def compile_book_pages(codegen, meta, book):
    pages = [page for page in codegen.additional_pages()]

    return pages

def write_book_pages(dir, pages):
    for (path, content) in pages:
        fullpath = f"{dir}/{path}"
        fulldir = os.path.dirname(fullpath)
        if not os.path.exists(fulldir):
            os.makedirs(fulldir)
        with open(fullpath, "w") as file:
            file.write(content or "whoops! nothing here! /(.0_0.)_b")