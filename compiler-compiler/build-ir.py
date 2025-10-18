"""
builds the Catspeak IR compilers from the def-catspeak-ir.yaml file
"""

import yaml
import os
import jinja2
import jinja2api
from pathlib import Path

SCRIPTS = [
    "compiler-gml/scripts/scr_catspeak_cart/scr_catspeak_cart.gml",
]
def infer_comment_style_from_path(path):
    match os.path.splitext(path)[1]:
        case _: return "//"

GITHUB_URL = "https://github.com/katsaii/catspeak-lang/blob/main/"
def sanitise_file_path(path):
    if os.path.isfile(path):
        return GITHUB_URL + os.path.relpath(path)
    else:
        return path

def get_generated_header(comment_prefix, *paths):
    header = f"{comment_prefix} AUTO GENERATED, DO NOT MODIFY THIS FILE\n"
    if len(paths) == 1:
        header += f"{comment_prefix} see: {sanitise_file_path(paths[0])}\n"
    elif len(paths) > 1:
        header += f"{comment_prefix} see:\n"
        for path in paths:
            header += f"{comment_prefix}  - {sanitise_file_path(path)}\n"
    return header

# init ir
IR_PATH = "compiler-compiler/def-catspeak-ir.yaml"
with open(IR_PATH, "r", encoding="utf-8") as file:
    ir = yaml.safe_load(file)

# init jinja
TEMPLATE_PATH = "compiler-compiler/template"
env = jinja2.Environment(
    loader=jinja2.FileSystemLoader(TEMPLATE_PATH),
    trim_blocks=True,
    lstrip_blocks=True,
    #autoescape=True
)
env_interface = { "ir": ir }
for func in jinja2api.JINJA2_FUNCS:
    env.globals[func.__name__] = func

# build scripts
DEBUG = False
for script in SCRIPTS:
    comment_prefix = infer_comment_style_from_path(script)
    temp_header = get_generated_header(
        comment_prefix, IR_PATH, __file__, f"{TEMPLATE_PATH}/{script}"
    )
    temp = env.get_template(script)
    temp_script = temp_header + "\n" + temp.render(env_interface)
    if DEBUG:
        print(f"   path: {script}")
        print(f"content: \n")
        print(temp_script)
    else:
        print(f"writing: {script}")
        with open(script, "w", encoding="utf-8") as file:
            file.write(str(temp_script))