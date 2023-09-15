import catlog.catlog as cl

meta = cl.doc.debug_document_create_example_metadata()
meta.footer = ">(OwO)<"

book = cl.doc.debug_document_create_example()
book2 = cl.doc.debug_document_create_example()
book2.title = "Other Page"
book2.chapters.append(book2.chapters[0])
book2.chapters[1].sections.pop()

pages = cl.compile_books(cl.codegen.HTMLCodegen, meta, book, book2)
for page in pages:
    #print(pages)
    pass

version = f"{meta.version[0]}.{meta.version[0]}.{meta.version[0]}"
cl.write_book_pages(f"docs/{version}", pages)