from . import gml, book, writers

def minify_css(css_in):
    char_is_graphic = lambda x: x.isalnum() or x in { "_" }
    css_out = ""
    ended_in_graphic = False
    for phrase in css_in.split():
        if ended_in_graphic and char_is_graphic(phrase[0]):
            css_out += " "
        css_out += phrase
        ended_in_graphic = char_is_graphic(phrase[-1])
    return css_out

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