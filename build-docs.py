from os.path import basename
from itertools import chain
import re

ANONYMOUS_SECTION_COUNT = 0
H1_SEPARATOR = "=" * 80
H2_SEPARATOR = "-" * 80

# Converts snake_case into Title Case.
def snake_to_title(s):
    if s.startswith("scr_catspeak"):
        return s
    elif s.startswith("not_catspeak_"):
        s = s[len("not_catspeak_"):]
    elif s == "not_catspeak":
        return "Catspeak"
    return " ".join([x[0].upper() + x[1:] for x in s.split("_") if x])

# Replaces simple markdown styles with HTML elements.
def simple_markdown(s):
    def control(s):
        bold = s == "`" or s == "```"
        return "<{elem} class=\"control\">{}</{elem}>".format(s, elem="b" if bold else "span")
    s = re.sub(r"\*\*([^*]*)\*\*", r"{c}<b>\1</b>{c}".format(c=control("**")), s)
    s = re.sub(r"_([^_]*)_", r"{c}<em>\1</em>{c}".format(c=control("_")), s)
    s = re.sub(r"```([^`]*)```", r"{c}<code>\1</code>{c}".format(c=control("```")), s)
    s = re.sub(r"`([^`]+)`", r"{c}<code>\1</code>{c}".format(c=control("`")), s)
    s = re.sub(r"\[([^]]+)\]\(([^)]+)\)",
            r"""{}<a href="\2">\1</a>{}""".format(control("["), control("]")), s)
    s = re.sub(r"\[([^]<>]+)\]",
            r"""{}<a href="#\1">\1</a>{}""".format(control("["), control("]")), s)
    return s

def header(sep, s, ext=""):
    if ext:
        ext = "." + ext
    return (
        "\n<span id={}>".format(s) + sep +
        "\n<b>" + snake_to_title(s) + "</b>" +
        " (<a href=\"#{}\">link</a>) {}".format(s, ext) +
        "\n" + sep + "</span>"
    )

# Stores information about a specific section of the docs, such as its title,
# description, and any definitions it may contain.
class Section:
    ANONYMOUS_SECTION_COUNT += 1
    title = "anon_section_{}".format(ANONYMOUS_SECTION_COUNT)
    extension = ""
    description = ""

    def render(self):
        out = header(H1_SEPARATOR, self.title, self.extension)
        if self.description.strip():
            description = self.description
            if self.extension in { "md", "txt" }:
                description = simple_markdown(description)
            out += "\n<div>" + description + "</div>"
        return out

    def from_content(title, content):
        sec = Section()
        parts = title.split(".")
        sec.title = parts[0]
        if len(parts) > 1:
            sec.extension = parts[1]
        if sec.extension == "gml":
            pass
        else:
            sec.description = content
        return sec

    def from_file(path):
        with open(path) as file:
            print("Reading documentation file: {}".format(path))
            content = file.read()
        title = basename(path)
        return Section.from_content(title, content)

# Stores information about the docs homepage and its sections.
class Page:
    sections = []

    def add_section_string(self, title, content):
        sec = Section.from_content(title, content)
        self.sections.append(sec)

    def add_section(self, path):
        sec = Section.from_file(path)
        self.sections.append(sec)

    def add_section_note(self, *names):
        for name in names:
            self.add_section("./src/notes/{scr}/{scr}.txt".format(scr=name))

    def add_section_script(self, *names):
        for name in names:
            self.add_section("./src/scripts/{scr}/{scr}.gml".format(scr=name))

    def render(self):
        body = ""
        body += "<b>{}</b>".format(HEADER)
        body += "<span>{}</span>".format(ABSTRACT)
        contents = header(H1_SEPARATOR, "contents")
        for sec in self.sections:
            contents += (
                "\n - <a href=\"#{}\">".format(sec.title) +
                snake_to_title(sec.title) +
                "</a>"
            )
        body += contents
        for sec in self.sections:
            body += sec.render()
        body += "\n" + H2_SEPARATOR + "\n"
        body += "<span>{}</span>".format(FOOTER)

        return TEMPLATE.replace("%BODY%", body)

HEADER = r"""
     _             _                                                       
    |  `.       .'  |     <span class="title">               _                             _    </span>
    |    \_..._/    |               the <span class="title">| |                           | |   </span>
   /    _       _    \    <span class="title">  |\_/|  __ _ | |_  ___  _ __    ___   __ _ | | __</span>
`-|    / \     / \    |-' <span class="title">  / __| / _` || __|/ __|| '_ \  / _ \ / _` || |/ /</span>
--|    | |     | |    |-- <span class="title"> | (__ | (_| || |_ \__ \| |_) ||  __/| (_| ||   < </span>
 .'\   \_/ _._ \_/   /`.  <span class="title">  \___| \__,_| \__||___/| .__/  \___| \__,_||_|\_\</span>
    `~..______    .~'     <span class="title">                   _____| |                       </span>
              `.  |       <span class="title">                  / ._____/ </span>reference           
                `.|       <span class="title">                  \_)                             </span>
"""

ABSTRACT = r"""
A cross-platform, expression oriented programming language for implementing
modding support into your GameMaker Studio 2.3 games. ( o`w o`) b

Developed by <a href="https://www.katsaii.com/">katsaii</a>.
Logo design by <a href="https://mashmerlow.github.io/">mashmerlow</a>.
"""

FOOTER = r"""
 |\ /|
>(OwO)< Little Catspeak
   \(
"""

TEMPLATE = """
<!DOCTYPE html>
<!-- AUTO GENERATED BY KAT/KATSAII -->

<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="author" content="Kat @katsaii">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Catspeak Reference</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link
      rel="stylesheet"
      href="https://fonts.googleapis.com/css2?family=Ubuntu+Mono:ital,wght@0,400;0,700;1,400&display=swap">
    <link
      rel="stylesheet"
      href="https://fonts.googleapis.com/css2?family=Courier+Prime&display=swap">
    <style>
      html { box-sizing : border-box }
      *, *:before, *:after { box-sizing : inherit }
      body { background-color : #f9f9f9 }

      body > div.content {
        margin : auto;
        width : fit-content;
      }

      :not(body) {
        --c : #292929;
        white-space : pre;
        color : var(--c);
      }

      :not(b) {
        --c : #202424;
      }

      :not(pre, code) {
        font-family : 'Ubuntu Mono', monospace;
      }

      pre, code {
        font-family: 'Courier Prime', monospace;
        --c : #000;
      }

      a {
        --c : #6082b6;
        text-decoration: none;
        cursor: pointer;
      }

      .title { --c : #526666 }
      .control { opacity : 0.75 }
      .short-pause { height : 2em }
    </style>
  </head>
  <body>
    <div class="content">
%BODY%
    </div>
  </body>
</html>
"""

page = Page()
page.add_section_note(
    "not_catspeak_features"
)
page.add_section_script(
    "scr_catspeak",
    "scr_catspeak_init",
    "scr_catspeak_process",
    "scr_catspeak_builtins",
    "scr_catspeak_error",
    "scr_catspeak_vm",
    "scr_catspeak_ir",
    "scr_catspeak_intcode",
    "scr_catspeak_compiler",
    "scr_catspeak_lexer",
    "scr_catspeak_token",
    "scr_catspeak_ascii_desc",
    "scr_catspeak_alloc",
    "scr_catspeak_compatibility",
)
page.add_section("./LICENSE")

with open("docs/index.html", "w") as file:
    print("Writing docs...")
    file.write(page.render())
    print("Done!")