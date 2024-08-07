from dataclasses import dataclass
from .codegen import BasicCodegen
from . import highlight

@dataclass
class HTMLCodegen(BasicCodegen):
    EXT = ".html"

    KEYWORDS = {
        "class_" : "class"
    }

    highlighter : ... = None

    def write(self, x):
        if self.highlighter == None:
            super().write(x)
            return
        token_styles = {
            highlight.Comment : "kw-com",
            highlight.Keyword : "kw-key",
            highlight.Value : "kw-val",
            highlight.Variable : "kw-var",
            highlight.FunctionName : "kw-fun",
            highlight.TypeName : "kw-typ",
            highlight.MacroName : "kw-mac",
        }
        for kind, content in self.highlighter(x):
            style = token_styles.get(type(kind))
            if not style:
                super().write(content)
                continue
            with self.tag("span", class_=style):
                super().write(content)

    @BasicCodegen.block
    def tag(self, tag, **attrs):
        super().write(f"<{tag}")
        for key, val in attrs.items():
            key = HTMLCodegen.KEYWORDS.get(key, key)
            super().write(f" {key}=\"{val}\"")
        super().write(">")
        yield
        super().write(f"</{tag}>")

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
            with self.tag("script"):
                self.write_heredoc("""
                    function copyToClipboard(id) {
                        let e = document.getElementById(id);
                        navigator.clipboard.writeText(e.textContent);
                    }
                """)
            with self.tag("noscript"):
                with self.tag("style"):
                    self.write("a.code-copy { display : none }")

    def meta_data(self, **meta_tags):
        for key, val in meta_tags.items():
            key = HTMLCodegen.KEYWORDS.get(key, key)
            self.tag("meta", name=key, content=val)

    @BasicCodegen.block
    def meta_title(self, **attrs):
        with self.tag("title", **attrs): yield

    # LAYOUT

    def hr(self, **attrs):
        self.tag("hr", **attrs)

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
    def list(self, **attrs):
        @BasicCodegen.block
        def list_element(**attrs):
            with self.tag("li", **attrs):
                yield

        with self.tag("ul", **attrs):
            yield list_element

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
    def anchor(self, id, **attrs):
        if id == None:
            with self.tag("a", **attrs): yield
        else:
            with self.tag("a", href=f"#{id}", **attrs): yield

    @BasicCodegen.block
    def code(self, **attrs):
        with self.tag("code", class_="inline-code", **attrs):
            highlight_prev = self.highlighter
            self.highlighter = None
            yield
            self.highlighter = highlight_prev

    code_block_idx : ... = 0

    @BasicCodegen.block
    def code_block(self, **attrs):
        with self.tag("pre", class_="code-block", **attrs):
            lang_data = None
            if lang := attrs.get("lang"):
                if lang == "gml":
                    lang_data = "GameMaker Language", ".gml", highlight.tokenise_gml
                elif lang == "meow":
                    lang_data = "Catspeak", ".meow", highlight.tokenise_meow
            highlight_prev = self.highlighter
            self.highlighter = None
            if lang_data:
                lang_name, lang_ext, _ = lang_data
                with self.tag("div", class_="code-triangle"):
                    pass
                with self.tag("div", class_="code-title"):
                    self.write(f"{lang_name} ({lang_ext})")
                
            code_block_tag = f"cb-{self.code_block_idx}"
            self.code_block_idx += 1
            with self.anchor(None,
                class_="code-copy",
                onclick=f"copyToClipboard('{code_block_tag}')"
            ):
                self.write("Copy")
            if lang_data:
                _, _, lang_highlighter = lang_data
                self.highlighter = lang_highlighter
            with self.tag("code", id = code_block_tag):
                yield
            self.highlighter = highlight_prev

    def code_block_lang(self, lang):
        @BasicCodegen.block
        def do_(**attrs):
            with self.code_block(lang = lang, **attrs):
                yield
        return do_

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

    @BasicCodegen.block
    def mark(self, **attrs):
        with self.tag("mark", **attrs): yield

    @BasicCodegen.block
    def quote(self, **attrs):
        with self.tag("blockquote", **attrs): yield

    @BasicCodegen.block
    def stab(self, **attrs):
        attrs["class_"] = "stab " + attrs.get("class_", "")
        with self.tag("blockquote", **attrs): yield

    @BasicCodegen.block
    def table(self, **attrs):
        with self.tag("div", class_="responsive-overflow"):
            with self.tag("table", **attrs):
                yield

    @BasicCodegen.block
    def table_row(self, **attrs):
        with self.tag("tr", **attrs): yield

    @BasicCodegen.block
    def table_cell(self, **attrs):
        with self.tag("td", **attrs): yield

    @BasicCodegen.block
    def table_header(self, **attrs):
        with self.tag("th", **attrs): yield

    # CSS

    DEFAULT_STYLE = """
        html { box-sizing : border-box }
        *, *:before, *:after { box-sizing : inherit }

        * { /* outline : red solid 1px * / }

        :root {
            --c-bg : #f9f9f9;
            --c-bg-dark : #2024240f; /* #ecebeb; */
            --c-fg : #202424;
            --c-fg-light : #cacecf;
            --c-fg-2 : #1c5353; /* #526666; */
            --c-accent : #007ffd;
            --c-stab : #fff2dc;

            --f-mono : "Courier New", Courier, monospace;
            --f-prop : "Segoe UI", 'Source Sans Pro', sans-serif;

            --pad : 1rem;
            --code-title-height : 20px;
        }

        @media (prefers-color-scheme: dark) {
            :root {
                --c-bg : #1b1e1f;
                --c-bg-dark : #d3cfc90f; /* #232627; */
                --c-fg : #d3cfc9;
                --c-fg-light : #3e4346;
                --c-fg-2 : #a2947d;
                --c-accent : #34a4ff;
                --c-stab : #362c2c;

                color-scheme : dark;
            }
        }

        body {
            margin : 1rem 15%;
            background-color : var(--c-bg);
            overflow-y : scroll;
        }

        @media screen and (max-width: 18in) {
            body { margin : 1rem 2rem }
        }

        header {
            padding : 0;
            background-color : var(--c-bg);
        }

        header > h1 {
            margin : 0;
            color : var(--c-fg-2);
            font-family : var(--f-prop);
            font-weight : 300;
            font-size : 30pt;
        }

        footer { padding : 0 }

        footer > article {
            color : var(--c-fg);
            font-family : var(--f-prop);
            font-size : 0.8em;
        }

        nav { padding : var(--pad) 0 0 0 }

        nav > ul {
            list-style-type : none;
            margin-top : 0;
            margin-bottom : 0;
            padding : 0;
        }

        nav > ul > li {
            padding : 0;
            display : inline-block;
            vertical-align : middle;
            overflow : hidden;
            font-family : var(--f-prop);
        }

        nav > ul > li + li { padding-left : 1rem }

        article > ul > li + li,
        section > ul > li + li { padding-top : 0.5rem }

        hr {
            border : 0;
            border-bottom : var(--c-fg-light) solid 1px;
        }

        a {
            cursor : pointer;
            color : var(--c-fg);
            transition : color 0.25s;
        }

        a:hover { color : var(--c-accent)!important }

        #chapter-content {
            display : flex;
            gap : 2em;
            justify-content : flex-start;
            align-items : flex-start;
            flex-wrap : nowrap;
            flex-direction : row;
        }

        #chapter-content > #chapters {
            order : 0;
            width : 200px;
        }

        #chapter-content > #contents {
            order : 3;
            width : 200px;
        }

        #chapter-content > main {
            width : 60%;
            order : 2;
            flex-grow : 4;
        }

        @media screen and (max-width: 14in) {
            #chapter-content > #contents { order : 1!important }
            #chapter-content > main { width : 100%!important }
            #chapter-content { flex-wrap : wrap }
        }

        @media screen and (min-width: 14in) {
            #contents,
            #chapters {
                position : sticky;
                top : 25px; /* required for sticky */
            }
        }

        #contents,
        #chapters {
            overflow-y : scroll;
            max-height : 75vh;
        }

        #chapters > h2,
        #contents > h2 {
            margin : 0;
            padding-bottom : 0.5rem;
            color : var(--c-fg-2);
            font-family : var(--f-prop);
            font-weight : 500;
            font-size : 1.1em;
        }

        #chapters ul,
        #contents ul {
            list-style-type : none;
            margin-top : 0;
            margin-bottom : 0;
            padding : 0;
        }

        #chapters ul ul,
        #contents ul ul { padding-left : 0.75em }

        #chapters ul > li,
        #contents ul > li {
            overflow : hidden;
            text-overflow : ellipsis;
            text-wrap : nowrap;
            white-space : nowrap;
            font-family : var(--f-prop);
        }

        #chapters li > a,
        #contents li > a { text-decoration : none!important }

        .heading {
            margin : 0;
            color : var(--c-fg-2);
            font-family : var(--f-prop);
            font-weight : 500;
            font-size : 16pt;
        }

        h1.heading,
        h2.heading { border-bottom : var(--c-fg-light) solid 1px }

        section > section {
            padding-left : 1rem;
        }

        section {
            padding-top : 2rem;
        }

        .heading > a:not(.heading-top) {
            color : var(--c-fg-light);
            font-family : var(--f-mono);
            font-weight : bold;
            font-size : 1.25em;
            text-decoration : none;
        }

        .heading > .heading-top {
            float : right;
            color : var(--c-fg-2);
            font-family : monospace;
            font-weight : bold;
            font-size : 0.5em;
            text-decoration : none;
        }

        .heading > pre {
            display : inline-block;
            vertical-align : text-top;
            margin : 5px;
            font-size : x-large;
        }

        .heading {
            background-color : var(--c-bg);
            position : sticky;
            scroll-margin-top : 38px;
            top : 36px;
            z-index : 98;
        }

        .chapter-title {
            background-color : var(--c-bg);
            color : var(--c-fg-2);
            font-family : var(--f-mono);
            font-weight : bold;
            font-size : 25pt;
            margin : 0 0 20px 0;
            position : sticky;
            top : 0px;
            z-index : 99;
        }

        .subchapter-title {
            color : var(--c-fg-2);
            font-family : var(--f-mono);
            font-weight : bold;
            font-size : 15pt;
        }

        @keyframes keyframes-fade {
            from { background : var(--c-accent) }
        }

        :target { animation : keyframes-fade 0.5s }

        mark {
            font-weight : bold;
            color : inherit;
            background-color : transparent;
        }

        p {
            color : var (--c-fg);
            font-family : var(--f-prop);
            text-wrap : balance;
        }

        li > p { margin : 0 }

        code {
            font-family : var(--f-mono) !important;
            font-size : 0.9em;
            color : var(--c-fg);
            background-color : var(--c-bg-dark);
        }

        .code-block {
            position : relative;
        }

        .code-block > code {
            display : block;
            padding : 1rem;
            white-space : pre;
            overflow-x : auto;
        }

        a.code-copy {
            position : absolute;
            right : 5px;
            text-decoration : none;
            color : var(--c-fg-2);
        }

        code.inline-code {
            padding : 0.025rem 0.15rem;
            border-radius : 5px;
        }

        blockquote:not(.stab) {
            --colour : 0, 0, 0;
            border-left : rgb(var(--colour)) solid 5px;
            background-color : rgba(var(--colour), 0.1);
            padding : 0.5rem;
        }

        blockquote.remark { --colour : 112, 145, 198 }
        blockquote.warning { --colour : 216, 180, 107 }

        .remark > strong,
        .warning > strong {
            font-family : var(--f-mono) !important;
            font-size : 1.25em;
            color : var(--c-fg-2);
        }

        blockquote.stab {
            width : fit-content;
            padding : 0.5rem;
            margin-left : 0.5rem;
            background-color : var(--c-stab);
        }

        .stab {
            font-family : var(--f-prop) !important;
            font-size : 0.9em;
            color : var(--c-fg);
        }

        .stab p {
            display : inline-block;
            padding : 0 0.5rem;
            margin : 0;
        }

        table {
            width : fit-content;
            max-width : 750px;
            border-collapse : collapse;
            border : 1px solid var(--c-fg);
        }

        .responsive-overflow { overflow-x : auto }

        th { font-weight : bold }

        th, td {
            color : var(--c-fg);
            font-family : var(--f-prop);
            padding : 10px;
            border : 1px solid var(--c-fg-light);
        }

        tbody tr:nth-child(even) {
            background-color: var(--c-bg-dark);
        }

        tbody tr:nth-child(1) {
            border-bottom : 2px solid var(--c-fg);
        }

        .code * { color : var(--c-fg) }

        .code-triangle {
            display : inline;
            width : 0;
            height : 0;
            border-bottom : var(--code-title-height) solid var(--c-fg-light);
            border-left : var(--code-title-height) solid transparent;
        }

        .code-title {
            height : var(--code-title-height);
            padding : 2px;
            background-color : var(--c-fg-light);
            margin-left : var(--code-title-height);
            font-family : monospace;
            font-weight : bold;
            color : var(--c-fg-2);
        }

        .kw-com { color : #080!important; font-style : italic }
        .kw-key { color : #34347e!important; font-weight : bold }
        .kw-val { color : #fa3232!important }
        .kw-var { opacity : 0.9 }
        .kw-fun { color : #808!important }
        .kw-typ { color : #7b7c26!important; font-weight : bold }
        .kw-mac { color : #ff2558!important; font-weight : bold }

        @media (prefers-color-scheme: dark) {
            .kw-com { color : #416e41!important }
            .kw-key { color : #5c5c9b!important; font-weight : bold }
            .kw-val { color : #c78888!important }
            .kw-var { opacity : 0.9 }
            .kw-fun { color : #8f5c8f!important }
            .kw-typ { color : #7b7c26!important; font-weight : bold }
            .kw-mac { color : #a72555!important; font-weight : bold }
        }
    """

    def minify_css(css_in):
        char_is_graphic = lambda x: x.isalnum() or x in { "_" }
        css_out = ""
        force_space = False
        ended_in_graphic = False
        for phrase in css_in.split():
            if force_space or (ended_in_graphic and char_is_graphic(phrase[0])):
                css_out += " "
            css_out += phrase
            ended_in_graphic = char_is_graphic(phrase[-1])
            # `and` is a special keyword here because `screen and(...)` is not valid
            force_space = phrase == "and"
        return css_out

    def additional_pages():
        yield ("style.css", HTMLCodegen.minify_css(HTMLCodegen.DEFAULT_STYLE))