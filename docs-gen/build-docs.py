import catlog.catlog as cl

meta = cl.doc.debug_document_create_example_metadata()
book = cl.doc.debug_document_create_example()

pages = cl.compile_book_pages(cl.codegen.HTMLCodegen, meta, book)
for page in pages:
    #print(pages)
    pass

version = f"{meta.version[0]}.{meta.version[0]}.{meta.version[0]}"
cl.write_book_pages(f"docs/{version}", pages)