from . import gml, doc, codegen

def compile_book_pages(codegen, meta, book):
    return []

def compile_example_book_pages(codegen):
    meta = doc.debug_document_create_example_metadata()
    book = doc.debug_document_create_example()
    return compile_book_pages(codegen, meta, book)

def write_book_pages(dir, pages):
    for (path, content) in pages:
        with open(f"{dir}/{path}", "w") as file:
            file.write(content or "whoops! nothing here! /(.0_0.)_b")