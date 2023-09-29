from . import doc
from textwrap import dedent

# TODO: don't depend on this external library
import mistletoe

def parse_content(content):
    root = mistletoe.Document.read(dedent(content))

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
                return oc.Bold(list(map(ast_to_doc, term.children)))
            case mistletoe.span_tokens.Link:
                return doc.LinkText(list(map(ast_to_doc, term.children)), term.target)
            case mistletoe.span_tokens.RawText:
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

    a = doc.RichText(children = list(map(ast_to_doc, root.children)))
    return a