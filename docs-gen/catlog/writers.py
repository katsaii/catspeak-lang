from .writer_utils import withable
from dataclasses import dataclass
from textwrap import dedent

@dataclass
class BasicWriter:
    content : str = ""

    def write(self, x):
        self.content += str(x)

    def writeln(self, n = 1):
        for _ in range(n):
            self.content += "\n"

    def write_heredoc(self, doc):
        self.content += dedent(doc).lstrip()

class HTMLWriter(BasicWriter):
    @withable
    def write_tag(self, tag, **attrs):
        self.write(f"<{tag}")
        for key, val in attrs.items():
            self.write(f" {key}=\"{val}\"")
        self.write(">")
        yield
        self.write(f"</{tag}>")

    @withable
    def meta(self, **metadata):
        self.write_heredoc("""
            <!DOCTYPE html>
            <!--
                AUTOMATICALLY GENERATED USING THE CATSPEAK BOOK GENERATOR:
                https://github.com/katsaii/catspeak-lang
            -->
        """)
        with self.write_tag("html", lang="en"):
            with self.write_tag("head"):
                self.write_tag("meta", charset="utf-8")
                self.write_tag("meta",
                    name="viewport",
                    content="width=device-width, initial-scale=1.0"
                )
                for key, val in metadata.items():
                    self.write_tag("meta", name=key, content=val)
                self.write_tag("link", rel="stylesheet", href="./style.css")
            with self.write_tag("body"):
                with self.write_tag("header"):
                    pass
                yield
                pass

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

        body {
            margin : 2.5% 15%;
            background-color : var(--c-bg);
        }

        .d-inline { display : inline }
        .d-inline-block { display : inline-block }
        .d-block { display : block }

        .t-break { word-break: break-all }
        .t-centre { text-align : center }
        .t-balanced { text-wrap : balance }
        .t-pre { white-space : pre }

        .f-mono { font-family : var(--f-mono) }
        .f-prop { font-family : var(--f-prop) }
        .f-thick { font-weight : bold; }

        .c-bg { color : var(--c-bg) }
        .c-fg { color : var(--c-fg) }
        .c-fg-2 { color : var(--c-fg-2) }
        .c-accent { color : var(--c-accent) }

        .blk-centre {
            display : block;
            margin-left : auto;
            margin-right : auto;
        }

        a {
            cursor : pointer;
            color : var(--c-fg);
            transition : color 0.25s;
        }

        a:hover { color : var(--c-accent) }

        img { max-width : 100% }

        .header { padding: 10rem 2rem 0 2rem }

        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            align-items: center;
        }

        .grid-centre {
            justify-items : center;
        }

        .grid > article {
            margin : 0.5rem;
            padding : 0.5rem;
        }

        .grid > article > img {
            height : 10rem;
            width : auto;
        }

        .grid > article p {
            font-size : 1.25rem;
            font-weight : 200;
        }

        .grid > article p b {
            font-weight : 400;
        }

        .nav {
            display : flex;
            flex-wrap : wrap;
            justify-content : space-evenly;
        }

        .nav > article {
            padding : 0.5rem;
            font-weight : bold;
            font-size : 1.5em;
            font-family : var(--f-prop);
        }

        @media screen and (max-width : 9in) {
            body { margin : 1rem 2rem }
            .grid { padding : 0 }
        }

        ul { text-align : left }

        .code {
            padding : 0.75rem;
            background-color : rgb(249, 243, 241);
            outline : rgb(49, 49, 49, 27%) solid 1px;
            border-radius : 10px;
            font-family : var(--f-mono) !important;
            white-space : pre;
            overflow : scroll;
        }

        .code * { color : var(--c-fg) }

        .kw-key { font-weight : bold }
        .kw-com { color : var(--c-fg-2)!important }
        .kw-val { color : var(--c-accent)!important }
    """)