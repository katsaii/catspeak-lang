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
                #[c:author]<meta name="author" content="[v:author]">[/]
                #[c:description]<meta name="description" content="[v:description]">[/]
                #[c:title]<meta name="title" content="[v:title]">[/]
                pass
            with self.write_tag("body"):
                yield
                pass