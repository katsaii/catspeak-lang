from . import doc, catlog as cl
from textwrap import dedent
from pathlib import Path
from dataclasses import dataclass, field
import re

# TODO: don't depend on this external library
import mistletoe

# from: https://mistletoe-ebp.readthedocs.io/en/latest/api/core_block_tokens.html
def ast_to_doc(term):
    match type(term):
        case mistletoe.block_tokens.Paragraph:
            return doc.Paragraph(list(map(ast_to_doc, term.children)))
        case mistletoe.block_tokens.CodeFence:
            return doc.CodeBlock(list(map(ast_to_doc, term.children)))
        case mistletoe.block_tokens.List:
            return doc.List(list(map(ast_to_doc, term.children)))
        case mistletoe.block_tokens.ListItem:
            return doc.RichText(list(map(ast_to_doc, term.children)))
        case mistletoe.block_tokens.Heading:
            # TODO: actual markdown headers
            return doc.Bold(list(map(ast_to_doc, term.children)))
        case mistletoe.span_tokens.Link:
            return doc.LinkText(list(map(ast_to_doc, term.children)), term.target)
        case mistletoe.span_tokens.RawText:
            if match := re.search("\[\[([^\]]*)\]\]", term.content):
                return doc.LinkText(
                    children = match[1],
                    url = cl.uid_to_path(cl.title_to_uid(match[1]))
                )
            else:
                return term.content
        case mistletoe.span_tokens.EscapeSequence:
            return doc.RichText(list(map(ast_to_doc, term.children)))
        case mistletoe.span_tokens.Strong:
            return doc.Bold(list(map(ast_to_doc, term.children)))
        case mistletoe.span_tokens.Emphasis:
            return doc.Emphasis(list(map(ast_to_doc, term.children)))
        case mistletoe.span_tokens.InlineCode:
            return doc.InlineCode(list(map(ast_to_doc, term.children)))
        case mistletoe.span_tokens.LineBreak:
            return "\n"
        case other:
            return f"(unknown content {other})".replace("<", "&lt;")

# from: https://mistletoe-ebp.readthedocs.io/en/latest/api/core_block_tokens.html
def ast_to_id(term):
    match type(term):
        case mistletoe.block_tokens.Paragraph:
            return "+".join(list(map(ast_to_id, term.children)))
        case mistletoe.block_tokens.CodeFence:
            return "+".join(list(map(ast_to_id, term.children)))
        case mistletoe.block_tokens.List:
            return "+".join(list(map(ast_to_id, term.children)))
        case mistletoe.block_tokens.ListItem:
            return "+".join(list(map(ast_to_id, term.children)))
        case mistletoe.block_tokens.Heading:
            # TODO: actual markdown headers
            return "+".join(list(map(ast_to_id, term.children)))
        case mistletoe.span_tokens.Link:
            return "+".join(list(map(ast_to_id, term.children)), term.target)
        case mistletoe.span_tokens.RawText:
            return term.content
        case mistletoe.span_tokens.EscapeSequence:
            return "+".join(list(map(ast_to_id, term.children)))
        case mistletoe.span_tokens.Strong:
            return "+".join(list(map(ast_to_id, term.children)))
        case mistletoe.span_tokens.Emphasis:
            return "+".join(list(map(ast_to_id, term.children)))
        case mistletoe.span_tokens.InlineCode:
            return "+".join(list(map(ast_to_id, term.children)))
        case mistletoe.span_tokens.LineBreak:
            return "\n"
        case other:
            return f"(unknown content {other})".replace("<", "&lt;")

def parse_content(content):
    root = mistletoe.Document.read(dedent(content))
    a = doc.RichText(children = list(map(ast_to_doc, root.children)))
    return a

def note_name_to_module_name(module):
    name = module.replace("not_", "").replace("catspeak_", "").replace("_", " ")
    return name.title()

@dataclass
class ParseCtx():
    chapter : ...
    currentSection : ...

    def create_new_section(self, term):
        # TODO: support subsections
        sec = doc.Section(
            title = ast_to_id(term),
            title_content = ast_to_doc(term),
            content = doc.RichText(),
        )
        self.chapter.sections.append(sec)
        self.currentSection = sec.content.children

    def go(self, term):
        for child in term.children:
            if type(child) == mistletoe.block_tokens.Heading:
                self.create_new_section(child)
            else:
                self.currentSection.append(ast_to_doc(child))

def parse_chapter(fullpath):
    name = note_name_to_module_name(Path(fullpath).with_suffix("").name)
    chapter = doc.Chapter(title = name, overview = doc.RichText())
    currentSection = chapter.overview.children
    with open(fullpath, "r", encoding="utf-8") as file:
        print(f"...parsing md chapter  '{name}'")
        root = mistletoe.Document.read(dedent(file.read()))
        ParseCtx(chapter, currentSection).go(root)
    return chapter
