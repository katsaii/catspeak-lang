"""
common functions used between all build scripts
"""

import yaml
import os
from textwrap import dedent

def load_yaml(path):
    with open(path, encoding="utf-8") as stream:
        return yaml.safe_load(stream)

def load_file(path):
    with open(path, "r", encoding="utf-8") as file:
        return file.read()

DEBUG_MODE = True
def save_gml(script, path):
    if DEBUG_MODE:
        print(script)
    else:
        with open(path, "w", encoding="utf-8") as file:
            file.write(str(script))

GITHUB_URL = "https://github.com/katsaii/catspeak-lang/blob/main/"
def get_path(path):
    if os.path.isfile(path):
        return GITHUB_URL + os.path.relpath(path)
    else:
        return path

COMMENT = "// "
COMMENT_FEATHER = "//# "
COMMENT_BANGDOC = "//! "
COMMENT_DOC = "/// "

def get_header(*paths):
    header = f"// AUTO GENERATED, DO NOT MODIFY THIS FILE\n"
    if len(paths) == 1:
        header += f"// see: {get_path(paths[0])}\n"
    elif len(paths) > 1:
        header += "// see:\n"
        for path in paths:
            header += f"//  - {get_path(path)}\n"
    return header

class WithHandler:
    def __init__(self, on_enter, on_exit):
        self.on_enter = on_enter
        self.on_exit = on_exit

    def __enter__(self): self.on_enter()
    def __exit__(self, exc_type, exc_value, exc_traceback): self.on_exit()

class SimpleStringBuilder:
    def __init__(self, s=""):
        self.content = s
        self.indent_ = 0
        self.do_indent = False

    def handle_indent(self):
        if self.do_indent:
            self.content += "    " * self.indent_
            self.do_indent = False

    def write(self, value):
        self.handle_indent()
        self.content += f"{value}"

    def writeln(self, value=""):
        if value:
            self.write(f"{value}\n")
        else:
            # skip indent
            self.content += "\n"
        self.do_indent = True

    def writedoc(self, value, prefix=""):
        doc = dedent(value).strip()
        if prefix or self.indent_ > 0:
            for line in doc.splitlines():
                self.writeln(prefix + line)
        else:
            self.writeln(doc)

    def indent(self):
        def inc(): self.indent_ += 1
        def dec(): self.indent_ -= 1
        return WithHandler(inc, dec)

    def __str__(self):
        return self.content

def case_snake(ident):
    return ident.replace(" ", "_")

def case_snake_upper(ident):
    return case_snake(ident).upper()

def case_capitalise(ident):
    if not ident:
        return ident
    return ident[0].upper() + ident[1:]

def case_camel_upper(ident):
    return "".join(map(case_capitalise, ident.split()))

def case_sentence(ident):
    ident = case_capitalise(ident)
    return ident + "." if ident else ident

def get_jinja2_funcs(dest_globals, *funcs):
    dest_globals["case_snake"] = case_snake
    dest_globals["case_snake_upper"] = case_snake_upper
    dest_globals["case_capitalise"] = case_capitalise
    dest_globals["case_camel_upper"] = case_camel_upper
    dest_globals["case_sentence"] = case_sentence
    for func in funcs:
        dest_globals[func.__name__] = func
