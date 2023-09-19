from .codegen import BasicCodegen

class HTMLCodegen(BasicCodegen):
    EXT = ".html"

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
        with self.tag("a", href=f"#{id}", **attrs): yield

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

    # CSS

    DEFAULT_STYLE = """
        html { box-sizing : border-box }
        *, *:before, *:after { box-sizing : inherit }

        * { /* outline : red solid 1px * / }

        :root {
            --c-bg : #f9f9f9;
            --c-fg-light : #cacecf;
            --c-fg : #202424;
            --c-fg-2 : #526666;
            --c-accent : #007ffd;

            --f-mono : "Courier New", Courier, monospace;
            --f-prop : "Segoe UI", 'Source Sans Pro', sans-serif;

            --pad : 1rem;
        }

        body {
            margin : 1rem 15%;
            background-color : var(--c-bg);
        }

        @media screen and (max-width: 16in) {
            body {
                margin : 1rem 2rem;
            }
        }

        header {
            padding : 0;
            background-color : var(--c-bg);
        }

        @media screen and (min-width: 3in) {
            header {
                position : sticky;
                top : 0; /* required for sticky */
            }
        }

        header > h1 {
            margin : 0;
            color : var(--c-fg-2);
            font-family : var(--f-prop);
            font-weight : 500;
            font-size : 1.5em;
        }

        footer { padding : 0 }

        footer > article {
            color : var(--c-fg-2);
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

        nav > ul > li + li {
            padding-left : 1rem;
        }

        hr {
            border : 0;
            border-bottom : var(--c-fg-light) solid 1px;
        }

        a {
            cursor : pointer;
            color : var(--c-fg);
            transition : color 0.25s;
        }

        a:hover { color : var(--c-accent) }

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
            min-width : 60%;
            order : 2;
            flex-grow : 4;
        }

        @media screen and (max-width: 10in) {
            #chapter-content > #contents { order : 1!important }
            #chapter-content { flex-wrap : wrap }
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
        #contents ul ul {
            padding-left : 0.75em;
        }

        #chapters ul > li,
        #contents ul > li {
            overflow : hidden;
            font-family : var(--f-prop);
        }

        .heading {
            margin : 0;
            color : var(--c-fg-2);
            font-family : var(--f-prop);
            font-weight : 500;
        }

        h1.heading { font-size : 15.5pt }
        h2.heading { font-size : 14pt }
        h3.heading,
        h4.heading,
        h5.heading,
        h6.heading { font-size : 11pt }

        section > section {
            padding-top : 1rem;
        }

        .heading > a {
            color : var(--c-fg-light);
            font-family : var(--f-mono);
            font-weight : bold;
            font-size : 1.25em;
            text-decoration : none;
        }

        .chapter-title {
            color : var(--c-fg-2);
            font-family : var(--f-mono);
            font-weight : bold;
            font-size : 25pt;
            margin : 0 0 20px 0;
        }

        @keyframes keyframes-fade {
            from {
                background : var(--c-accent);
            }
        }

        :target {
            animation : keyframes-fade 0.5s;
        }

        mark {
            font-weight : bold;
            color : inherit;
            background-color : transparent;
        }

        p {
            color : var (--c-fg);
            font-family : var(--f-prop);
            text-align : justify;
        }

        @media screen and (max-width: 10in) {
            p {
                text-wrap : balance;
                text-align : initial!important;
            }
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