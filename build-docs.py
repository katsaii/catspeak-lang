from os.path import basename
from itertools import chain
import re

ANONYMOUS_SECTION_COUNT = 0
LINE_WIDTH = 80

# Stores information about a specific section of the docs, such as its title,
# description, and any definitions it may contain.
class Section:
    def __init__(self):
        global ANONYMOUS_SECTION_COUNT
        ANONYMOUS_SECTION_COUNT += 1
        self.id = "anon_section_{}".format(ANONYMOUS_SECTION_COUNT)
        self.title = None
        self.extension = ""
        self.description = ""
        self.subsections = []
        self.depth = 0

    def render(self):
        out = header(self.depth, self.id, self.title, self.extension)
        if self.description.strip():
            description = "\n".join(
                " " * self.depth + line
                for line in self.description.splitlines()
            )
            if self.extension in { "md", "txt", "gml" }:
                description = simple_markdown(description)
            out += "\n<div>" + description + "</div>"
        for subsec in self.subsections:
            out += subsec.render()
        return out

    def from_content(title, content):
        content = content or "Undocumented."
        escapes = { "\"": "&quot;", "\'": "&#39;", "<": "&lt;", ">": "&gt;" }
        #content = content.replace('&', '&amp;')
        for seq in escapes:
            content = content.replace(seq, escapes[seq])
        sec = Section()
        parts = title.split(".")
        sec.id = parts[0]
        if (sec.id.startswith("not_catspeak_")):
            sec.id = sec.id[len("not_catspeak_"):]
        sec.id = "_".join(item.lower() for item in sec.id.split())
        if len(parts) > 1:
            sec.extension = parts[1]
        if sec.extension == "gml":
            sec.title = "<span class=\"name-script\">" + sec.id + "</span>"
            sec.description = "\n".join(
                (line[1:] if line else "") for line in (
                    line[len("//!"):] for line in content.splitlines()
                    if line.startswith("//!")
                )
            )
            doc = ""
            for line in content.splitlines():
                derives = None
                if match := re.search('^\s*function\s*([A-Z]+[A-Za-z0-9_]*)[^:]*:\s*([A-Z]+[A-Za-z0-9_]*)', line):
                    name = match.group(1)
                    derives = match.group(2)
                    prefix = "struct "
                elif match := re.search('^\s*function\s*([A-Z]+[A-Za-z0-9_]*)', line):
                    name = match.group(1)
                    prefix = "struct "
                elif match := re.search('^\s*function\s*([A-Za-z0-9_]+)', line):
                    name = match.group(1)
                    prefix = "function "
                elif match := re.search('^\s*#macro\s*([A-Za-z0-9_]+)', line):
                    name = match.group(1)
                    prefix = "macro "
                elif match := re.search('^\s*enum\s*([A-Za-z0-9_]+)', line):
                    name = match.group(1)
                    prefix = "enum "
                elif match := re.search('^\s*static\s*([A-Za-z0-9_]+)\s*=\s*function', line):
                    name = match.group(1)
                    prefix = "method "
                elif match := re.search('^\s*static\s*([A-Za-z0-9_]+)', line):
                    name = match.group(1)
                    prefix = "field "
                elif match := re.search('^\s*///(.*)', line):
                    doc_line = match.group(1)
                    if doc_line and doc_line[0] == " ":
                        # skip first space
                        doc_line = doc_line[1:]
                    if doc:
                        doc += "\n"
                    doc += doc_line
                    continue
                else:
                    continue
                this_doc = doc
                doc = ""
                if name.startswith("__") or "@ignore" in this_doc:
                    continue
                subsec = Section.from_content(name, this_doc)
                subsec.extension = "gml"
                subsec.title = (
                    "<span class=\"keyword\">" + prefix + "</span>" +
                    "<span class=\"name\">" + name + "</span>"
                )
                if derives:
                    subsec.title += (
                        " <span class=\"keyword\">extends</span>" +
                        " <span class=\"name\">" + derives + "</span>"
                    )
                if prefix.startswith("method") or prefix.startswith("field"):
                    # add methods to the previous definition
                    subsec_parent = sec.subsections[-1]
                    if "function " in (subsec_parent.title or ""):
                        # if the previous context was a function, then we dont
                        # want to include it in the documentation
                        continue
                    subsec_parent.subsections.append(subsec)
                else:
                    sec.subsections.append(subsec)
        elif sec.extension in { "md", "txt" }:
            # put headings into subsections
            current_sec = sec
            for line in content.splitlines():
                if match := re.search('^\s*(#+)(.*)', line):
                    heading_depth = len(match.group(1))
                    heading = match.group(2).strip()
                    subsec_parent = sec
                    for _ in range(heading_depth - 1):
                        if not subsec_parent.subsections:
                            break
                        subsec_parent = subsec_parent.subsections[-1]
                    current_sec = Section()
                    current_sec.id = "_".join(item.lower() for item in heading.split())
                    current_sec.extension = sec.extension
                    subsec_parent.subsections.append(current_sec)
                else:
                    if current_sec.description:
                        current_sec.description += "\n"
                    current_sec.description += line
        else:
            sec.description = content
        sec.update_depths()
        return sec

    def from_file(path):
        with open(path) as file:
            print("Reading documentation file: {}".format(path))
            content = file.read()
        title = basename(path)
        return Section.from_content(title, content)

    def update_depths(self):
        for subsec in self.subsections:
            subsec.depth = self.depth + 2
            subsec.update_depths()

# Stores information about the docs homepage and its sections.
class Page:
    sections = []

    def add_section_string(self, title, content):
        sec = Section.from_content(title, content)
        self.sections.append(sec)

    def add_section(self, path, parent=None):
        sec = Section.from_file(path)
        if parent:
            parent.subsections.append(sec)
            parent.update_depths()
        else:
            self.sections.append(sec)

    def add_section_note(self, *names):
        for name in names:
            self.add_section("./src/notes/{scr}/{scr}.txt".format(scr=name))

    def add_section_script(self, *names):
        parent = self.sections[-1]
        for name in names:
            self.add_section(
                "./src/scripts/{scr}/{scr}.gml".format(scr=name),
                parent
            )

    def render(self):
        def render_sections(sections):
            out = ""
            for sec in sections:
                if sec.subsections:
                    checkbox_id = sec.id + "-checkbox"
                    out += """\n<input id="{}" class="toggle" type="checkbox">""".format(checkbox_id)
                    out += """<label for="{}">{} - </label>""".format(
                        checkbox_id,
                        " " * sec.depth
                    )
                else:
                    out += "\n" + " " * (sec.depth + 3) + " - "
                out += (
                    "<a href=\"#{}\">".format(sec.id) +
                    (sec.title or snake_to_title(sec.id)) +
                    "</a>"
                )
                if sec.subsections:
                    out += """<div class="collapsible-content">"""
                    out += render_sections(sec.subsections)
                    out += """</div>"""
            return out
        body = ""
        body += "<b>{}</b>".format(HEADER)
        body += "<span>{}</span>".format(simple_markdown(ABSTRACT))
        contents = header(0, "contents")
        contents += render_sections(self.sections)
        body += contents + "\n"
        for sec in self.sections:
            body += sec.render()
        body += "\n" + ("-" * LINE_WIDTH) + "\n"
        body += "<span>{}</span>".format(FOOTER)

        return TEMPLATE.replace("%BODY%", body)

# Converts snake_case into Title Case, with some exceptions for GML scripts.
def snake_to_title(s):
    if s.startswith("not_catspeak_"):
        s = s[len("not_catspeak_"):]
    elif s == "not_catspeak":
        return "Catspeak"
    return " ".join([x[0].upper() + x[1:] for x in s.split("_") if x])

# Performs simple syntax highlighting on Feather types.
def simple_syntax_higlight_types(s):
    s = re.sub(r"[|]", " | ", s)
    items = re.split(r'([<.>|\(\)\[\]\{\}]|&lt;|&gt;)', s)
    highlight = True
    out = ""
    for item in items:
        if highlight:
            if item.strip().lower() in {
                "real", "bool", "string", "array", "pointer", "function",
                "struct", "id", "asset", "constant", "any", "undefined",
                "enum"
            }:
                item_ = "<b class=\"keyword\">" + item + "</b>"
                item_ = "<a href=\"https://manual.yoyogames.com/The_Asset_Editors/Code_Editor_Properties/Feather_Data_Types.htm\">{}</a>".format(item_)
                out += item_
            else:
                item_ = "<span class=\"name\">" + item + "</span>"
                if item.strip().lower().startswith("catspeak") or \
                    item.strip().lower().startswith("future"):
                    item_ = "<a href=\"#{}\">{}</a>".format(item.lower(), item_)
                out += item_
        else:
            out += item
        highlight = not highlight
    return out

# Creates the HTML for a control character element.
def control(s):
    bold = s == "`" or s == "```"
    return "<{elem} class=\"control\">{}</{elem}>".format(
            s, elem="b" if bold else "span")

# Creates a simple hyperlink to a resource.
def simple_link(s, link=None):
    if not link:
        if "_" in s:
            link = "#" + s
        else:
            link = "#" + "_".join(item.lower() for item in s.split())
    return r"""{}<a href="{}">{}</a>{}""".format(
            control("["), link, s, control("]"))

# Replaces simple markdown styles with HTML elements.
def simple_markdown(s):
    s = re.sub(r"@deprecated", r"{}<b>deprecated</b> <em>This function is deprecated and its usage is discouraged!</em>".format(control("@")), s)
    s = re.sub(
        r"@param\s*\{([^\}]*)\}\s*\[([A-Za-z0-9_]*)\]",
        lambda match: \
            r"{}<b>param</b> <i>(optional)</i> <code>{}</code><b>:</b> <i>{}</i>".format(
                control("@"),
                match.group(2),
                simple_syntax_higlight_types(match.group(1))
            ),
        s
    )
    s = re.sub(
        r"@param\s*\{([^\}]*)\}\s*([A-Za-z0-9_]*)",
        lambda match: \
            r"{}<b>param</b> <code>{}</code><b>:</b> <i>{}</i>".format(
                control("@"),
                match.group(2),
                simple_syntax_higlight_types(match.group(1))
            ),
        s
    )
    s = re.sub(r"NOTE:", r"<em>NOTE</em>:".format(control("@")), s)
    s = re.sub(
        r"@return\s*\{([^\}]*)\}",
        lambda match: \
            r"{}<b>returns</b> a value of <i>{}</i>".format(
                control("@"),
                simple_syntax_higlight_types(match.group(1))
            ),
        s
    )
    s = re.sub(r"\*\*([^*]*)\*\*", r"{c}<b>\1</b>{c}".format(c=control("**")), s)
    #s = re.sub(r"_([^_]*)_", r"{c}<em>\1</em>{c}".format(c=control("_")), s)
    s = re.sub(r"```([^`]*)```", r"{c}<code>\1</code>{c}".format(c=control("```")), s)
    s = re.sub(r"`([^`<>]+)`", r"{c}<code>\1</code>{c}".format(c=control("`")), s)
    s = re.sub(
        r"\[([^]]+)\]\(([^)]+)\)",
        lambda match: simple_link(match.group(1), match.group(2)),
        s
    )
    s = re.sub(
        r"\[([A-Za-z0-9_ ]+)\]",
        lambda match: simple_link(match.group(1)),
        s
    )
    return s

# Creates a simple section header.
def header(depth, id, title=None, ext=""):
    title_text = title or snake_to_title(id)
    indent = " " * depth
    sep_top = "=" * (LINE_WIDTH if depth == 0 else 0)
    sep_bot = ("=" if depth <= 2 else "-") * (LINE_WIDTH - depth)
    if ext:
        ext = "." + ext
    return (
        "\n" + (indent if sep_top else "") + "<span id={}>".format(id) + sep_top +
        ("\n" if sep_top else "") + indent + "<b>" + title_text + "</b>" +
        " (<a href=\"#{}\">link</a>) {}".format(id, ext) +
        "\n" + indent + sep_bot + "</span>"
    )

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
modding support into your GameMaker Studio 2.3 games. /( > w <") b

Developed by [katsaii](https://www.katsaii.com/) ([GitHub](https://github.com/NuxiiGit/catspeak-lang) page).
Logo design by [mashmerlow](https://mashmerlow.github.io/).
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
    <link rel="shortcut icon" href="./catspeak-icon.svg">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="A cross-platform, expression oriented programming language for implementing modding support into your GameMaker Studio 2.3 games. >(OwO)<">
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

      * {
        font-family : 'Ubuntu Mono', monospace;
      }

      pre, code {
        --c : #385787;
      }

      a {
        --c : #007ffd;
        text-decoration : none;
        cursor : pointer;
      }

      .collapsible-content {
        max-height : 0px;
        overflow : hidden;
        display : none;
      }

      .toggle:checked + label + a + .collapsible-content {
        max-height : 100%;
        display : block;
      }

      input[type='checkbox'] {
        display : inline;
        position : absolute;
        visibility : hidden;
      }

      .toggle + label::before {
        content : '[+]';
      }

      .toggle:checked + label::before {
        content : '[-]';
      }

      .title { --c : #526666 }
      .keyword { --c : #34347e }
      .name { --c : #808 }
      .name-script { --c : #d54a07 }
      .control { opacity : 0.5 }

      @keyframes keyframes-fade {
        from { background-color : #ff43a4 }
      }

      :target { animation : keyframes-fade 0.5s }
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
    "not_catspeak_installation",
    "not_catspeak_disclaimer",
    "not_catspeak_features",
    "not_catspeak_configuration",
    "not_catspeak_basic_usage",
    "not_catspeak_syntax",
    "not_catspeak_standard_library",
)
page.add_section_string("library_reference.md", """\
The following sections feature documentation for all public Catspeak functions,
macros, and structs.
""")
page.add_section_script(
    "scr_catspeak",
    "scr_catspeak_init",
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
page.add_section_string("futures_reference.md", """\
The [Future library](https://github.com/NuxiiGit/future) is used by Catspeak in order to better organise
asynchronous processes. The following sections document its usage.
""")
page.add_section_script(
    "scr_future",
    "scr_future_file",
)
page.add_section_note(
    "not_catspeak_theory"
)
page.add_section("./LICENSE")

with open("docs/index.html", "w") as file:
    print("Writing docs...")
    file.write(page.render())
    print("Done!")