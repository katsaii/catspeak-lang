from . import gml, book, writers

def minify_css(stylesheet):
    # TODO
    return stylesheet.strip()

exBook = book.debug_document_create_example()
exMeta = book.debug_document_create_example_metadata()

html = writers.HTMLWriter()
exMeta.write_document(html, exBook)

print(html.content or "whoops! nothing!")

if html.content:
    version = "3.0.0"
    with open(f"docs/{version}/index.html", "w") as file:
        file.write(html.content)
    with open(f"docs/{version}/style.css", "w") as file:
        file.write(minify_css(writers.HTMLWriter.DEFAULT_STYLE))