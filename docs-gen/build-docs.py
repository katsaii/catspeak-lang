import catlog.catlog as cl
from datetime import datetime

DATE_START = 2021
DATE_END = datetime.now().year

meta = cl.doc.debug_document_create_example_metadata()
meta.footer = [
    cl.doc.Emphasis([
        f"Catspeak (c) {DATE_START}-{DATE_END} ",
        cl.doc.Link("https://www.katsaii.com/", "Katsaii"),
        ", ",
        cl.doc.Link("https://github.com/katsaii/catspeak-lang/blob/main/LICENSE", "LICENSE"),
        "."
    ])
]

book = cl.doc.debug_document_create_example()
book2 = cl.doc.debug_document_create_example()
book2.title = "Other Page"
book2.chapters.append(book2.chapters[0])
book2.chapters[1].sections.pop()

pages = cl.compile_books(cl.html.HTMLCodegen, meta, book, book2)
for page in pages:
    #print(pages)
    pass

version = f"{meta.version[0]}.{meta.version[0]}.{meta.version[0]}"
cl.write_book_pages(f"docs/{version}", pages)