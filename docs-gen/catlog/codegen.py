from dataclasses import dataclass
from textwrap import dedent

@dataclass
class BasicCodegen:
    content : str = ""
    disable : bool = False

    def write(self, x):
        if self.disable:
            return
        self.content += str(x)

    def writeln(self, n = 1):
        if self.disable:
            return
        for _ in range(n):
            self.content += "\n"

    def write_heredoc(self, doc):
        if self.disable:
            return
        self.content += dedent(doc).lstrip()

    def block(f):
        class WithHandler:
            def __init__(self, value, on_exit = None):
                do_nothing = lambda: None
                self.value = value
                self.on_exit = on_exit or do_nothing

            def __enter__(self): return self.value
            def __exit__(self, exc_type, exc_value, exc_traceback): self.on_exit()

        def inner(*args, **kwargs):
            gen = f(*args, **kwargs)

            def gen_event():
                try:
                    return next(gen)
                except StopIteration:
                    return None

            return WithHandler(gen_event(), gen_event)

        return inner

class HTMLCodegen(BasicCodegen):
    EXT = "html"

    KEYWORDS = {
        "class_" : "class"
    }

    @BasicCodegen.block
    def tag(self, tag, **attrs):
        self.write(f"<{tag}")
        for key, val in attrs.items():
            key = HTMLCodegen.KEYWORDS.get(key, key)
            self.write(f" {key}=\"{val}\"")
        self.write(">")
        yield
        self.write(f"</{tag}>")

    # METADATA

    @BasicCodegen.block
    def root(self, **attrs):
        self.write_heredoc("""
            <!DOCTYPE html>
            <!--
                AUTOMATICALLY GENERATED USING THE CATSPEAK BOOK GENERATOR:
                https://github.com/katsaii/catspeak-lang
            -->
        """)
        with self.tag("html", **attrs):
            yield

    @BasicCodegen.block
    def meta(self, **attrs):
        with self.tag("head", **attrs):
            self.tag("meta", charset="utf-8")
            self.tag("meta",
                name="viewport",
                content="width=device-width, initial-scale=1.0"
            )
            yield
            self.tag("link", rel="stylesheet", href="./style.css")

    def meta_data(self, **meta_tags):
        for key, val in meta_tags.items():
            key = HTMLCodegen.KEYWORDS.get(key, key)
            self.tag("meta", name=key, content=val)

    @BasicCodegen.block
    def meta_title(self, **attrs):
        with self.tag("title", **attrs): yield

    # LAYOUT

    @BasicCodegen.block
    def body(self, **attrs):
        with self.tag("body", **attrs): yield

    @BasicCodegen.block
    def header(self, **attrs):
        with self.tag("header", **attrs): yield

    @BasicCodegen.block
    def nav(self, **attrs):
        with self.tag("nav", **attrs): yield

    @BasicCodegen.block
    def aside(self, **attrs):
        with self.tag("aside", **attrs): yield

    @BasicCodegen.block
    def main(self, **attrs):
        with self.tag("main", **attrs): yield

    @BasicCodegen.block
    def article(self, **attrs):
        with self.tag("article", **attrs): yield

    @BasicCodegen.block
    def section(self, **attrs):
        with self.tag("section", **attrs): yield

    @BasicCodegen.block
    def footer(self, **attrs):
        with self.tag("footer", **attrs): yield

    # ELEMENTS

    @BasicCodegen.block
    def heading(self, level, **attrs):
        if level < 1:
            level = 1
        if level > 6:
            level = 6
        with self.tag(f"h{level}", **attrs):
            if id := attrs.get("id"):
                with self.tag("a", href=f"#{id}"):
                    self.write("§")
                self.write(" ")
            yield

    @BasicCodegen.block
    def link(self, hyperlink, **attrs):
        with self.tag("a", href=hyperlink, **attrs): yield

    @BasicCodegen.block
    def bold(self, **attrs):
        with self.tag("strong", **attrs): yield

    @BasicCodegen.block
    def emphasis(self, **attrs):
        with self.tag("em", **attrs): yield

    @BasicCodegen.block
    def paragraph(self, **attrs):
        with self.tag("p", **attrs): yield

    @BasicCodegen.block
    def figure(self, **attrs):
        with self.tag("figure", **attrs): yield

    @BasicCodegen.block
    def caption(self, **attrs):
        with self.tag("figcaption", **attrs): yield

    # CSS

    DEFAULT_STYLE = dedent(r"""
        html { box-sizing : border-box }
        *, *:before, *:after { box-sizing : inherit }

        * { outline : red solid 1px }

        :root {
            --c-bg : #f9f9f9;
            --c-fg : #202424;
            --c-fg-2 : #526666;
            --c-accent : #007ffd;

            --f-mono : "Courier New", Courier, monospace;
            --f-prop : "Segoe UI", 'Source Sans Pro', sans-serif;

            font-size : 0.8em;
        }
    """)

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

    def additional_pages():
        yield ("style.css", HTMLCodegen.minify_css(HTMLCodegen.DEFAULT_STYLE))