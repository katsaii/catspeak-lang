from . import doc, gml, html, md, gml
from pathlib import Path
from textwrap import dedent
import os
import re

TITLE_ID_DATABASE = { }
TITLE_ID_CLASHES = { }
TITLE_ID_MAX_LENGTH = 30
def title_to_uid(*titles):
    titles_short = []
    if titles:
        # shorten every title, except for the final subtitle
        for item in titles:
            if titles[-1] == item:
                titles_short.append(item)
            else:
                titles_short.append(item[:3])
    else:
        titles_short.append("empty")
    title = "/".join(titles_short)
    if title in TITLE_ID_DATABASE:
        return TITLE_ID_DATABASE[title]
    title_words = [word.lower() for word in re.split("[^A-Za-z0-9_\.]+", title)]
    title_id = "-".join(title_words)
    if len(title_id) > TITLE_ID_MAX_LENGTH:
        title_id = title_id[:TITLE_ID_MAX_LENGTH] + "+s" # s: short for "short"
    while title_id in TITLE_ID_CLASHES:
        TITLE_ID_CLASHES[title_id] += 1
        title_id = f"{title_id}+{TITLE_ID_CLASHES[title_id]}"
    TITLE_ID_DATABASE[title] = title_id
    TITLE_ID_CLASHES[title_id] = 0
    return title_id

def uid_to_path(uid, ext=None):
    path = Path(uid)
    return path.with_suffix(ext) if ext else path

def write_meta(sb, meta, book, chapter):
    with sb.meta():
        sb.meta_data(author = meta.author, description = book.brief)
        with sb.meta_title():
            sb.write(f"{meta.title} :: {chapter.title} of {book.title}")

def write_header(sb, meta, books, current_book):
    with sb.header():
        with sb.heading(1):
            sb.write(meta.title)
        with sb.nav():
            with sb.list() as list_element:
                for book in books:
                    if len(book.chapters) < 1:
                        continue
                    with list_element():
                        uid = title_to_uid(book.title, book.chapters[0].title)
                        with sb.link(uid_to_path(uid, sb.EXT)):
                            if book == current_book:
                                with sb.mark():
                                    sb.write(book.title)
                            else:
                                sb.write(book.title)
        sb.hr()

def write_chapters(sb, book, current_chapter):
    def contains_chapter(got, expect):
        if got == expect:
            return True
        for chapter in got.subchapters:
            if contains_chapter(chapter, expect):
                return True
        return False

    def write_contents_chapter(sb, chapter, depth):
        uid = title_to_uid(book.title, chapter.title)
        with sb.link(uid_to_path(uid, sb.EXT)):
            if chapter == current_chapter:
                with sb.mark():
                    sb.write(chapter.title)
            else:
                sb.write(chapter.title)
        if contains_chapter(chapter, current_chapter) and chapter.subchapters:
            with sb.list() as list_element:
                for subchapter in chapter.subchapters:
                    with list_element():
                        write_contents_chapter(sb, subchapter, depth + 1)

    def chapter_count(chapters):
        return len(chapters) + sum([
            chapter_count(chapter.subchapters) for chapter in chapters
        ])

    with sb.aside(id="chapters"):
        if chapter_count(book.chapters) > 1:
            with sb.heading(2):
                sb.write("Chapters")
            with sb.list() as list_element:
                for chapter in book.chapters:
                    with list_element():
                        write_contents_chapter(sb, chapter, 0)

def write_contents(sb, chapter):
    def write_contents_section(sb, section, depth):
        uid = title_to_uid(section.title)
        with sb.anchor(uid):
            sb.write(section.title)
        if section.subsections:
            with sb.list() as list_element:
                for subsection in section.subsections:
                    with list_element():
                        write_contents_section(sb, subsection, depth + 1)

    def section_count(sections):
        return len(sections) + sum([
            section_count(section.subsections) for section in sections
        ])

    with sb.aside(id="contents"):
        if section_count(chapter.sections) > 1:
            with sb.heading(2):
                sb.write("Contents")
            with sb.list() as list_element:
                for section in chapter.sections:
                    with list_element():
                        write_contents_section(sb, section, 0)

def write_main(sb, book, chapter):
    with sb.main():
        with sb.article():
            with sb.heading(0, class_="chapter-title"):
                sb.write(chapter.title)
            for subchapter in chapter.subchapters:
                with sb.tag("div", class_="subchapter-title"):
                    sb.write("↳ ")
                    uid = title_to_uid(book.title, subchapter.title)
                    with sb.link(uid_to_path(uid, sb.EXT), class_="subchapter-title"):
                        sb.write(subchapter.title)
            if chapter.overview:
                write_richtext(sb, chapter.overview)
            for section in chapter.sections:
                write_section(sb, section, 1)

def write_section(sb, section, depth):
    with sb.section():
        with sb.heading(depth, class_="heading", id=title_to_uid(section.title)):
            if section.title_content:
                write_richtext(sb, section.title_content)
            else:
                sb.write(section.title)
            with sb.link("#", class_="heading-top"):
                sb.write("top ^")
        write_richtext(sb, section.content)
        for subsection in section.subsections:
            write_section(sb, subsection, depth + 1)

def write_richtext(sb, textdata):
    if isinstance(textdata, str):
        sb.write(textdata)
    elif isinstance(textdata, doc.Remark):
        with sb.quote(class_="remark"):
            with sb.bold():
                sb.write("📝 Note")
            for child in textdata.children:
                write_richtext(sb, child)
    elif isinstance(textdata, doc.Warning):
        with sb.quote(class_="warning"):
            with sb.bold():
                sb.write("⚠️ Warning")
            for child in textdata.children:
                write_richtext(sb, child)
    elif isinstance(textdata, doc.Deprecated):
        with sb.stab(class_="deprecated"):
            with sb.bold():
                sb.write("👎 Deprecated")
                if textdata.since:
                    sb.write(f" since {textdata.since}")
            for child in textdata.children:
                write_richtext(sb, child)
    elif isinstance(textdata, doc.Experimental):
        with sb.stab(class_="experimental"):
            with sb.bold():
                sb.write("🔬 This is an experimental feature. It may change at any moment.")
            for child in textdata.children:
                write_richtext(sb, child)
    elif isinstance(textdata, doc.EmbeddedHTML):
        sb.write(textdata.content)
    elif isinstance(textdata, doc.Table):
        with sb.table():
            with sb.table_row():
                for header_cell in textdata.header:
                    with sb.table_header():
                        for child in header_cell.children:
                            write_richtext(sb, child)
            for child in textdata.children:
                write_richtext(sb, child)
    elif isinstance(textdata, doc.RichText):
        writers = {
            doc.Paragraph : lambda _: sb.paragraph,
            doc.CodeBlock : lambda cb: sb.code_block_lang(cb.lang),
            doc.InlineCode : lambda _: sb.code,
            doc.Bold : lambda _: sb.bold,
            doc.Emphasis : lambda _: sb.emphasis,
            doc.TableRow : lambda _: sb.table_row,
            doc.TableCell : lambda _: sb.table_cell,
        }
        writer = writers.get(type(textdata))
        if writer:
            writer = writer(textdata)
        else:
            writer = sb.no_style
        with writer():
            for child in textdata.children:
                write_richtext(sb, child)
    elif isinstance(textdata, doc.LinkText):
        writers = { }
        writer = writers.get(type(textdata)) or sb.link
        with writer(textdata.url):
            for child in textdata.children:
                write_richtext(sb, child)
    elif isinstance(textdata, doc.List):
        with sb.list() as list_element:
            for element in textdata.elements:
                with list_element():
                    write_richtext(sb, element)
    else:
        sb.write(f"(unknown {repr(textdata)})")

def write_footer(sb, meta):
    with sb.footer():
        sb.hr()
        with sb.article():
            write_brand(sb)
        with sb.article():
            for copyright in meta.copyrights:
                with sb.emphasis():
                    write_links(sb, copyright.assets)
                    sb.write(" (c) ")
                    write_links(sb, copyright.authors)
                    if copyright.license:
                        sb.write(", ")
                        with sb.link(copyright.license):
                            sb.write("LICENSE")
                        sb.write(".")


def write_brand(sb):
    with sb.emphasis(id="brand"):
        sb.write("Built using Catlog, the ")
        with sb.link("https://www.katsaii.com/catspeak-lang/"):
            sb.write("Catspeak")
        sb.write(" book generator.")

def write_links(sb, links):
    first = True
    for link in links:
        if not first:
            sb.write(", ")
        first = False
        with sb.link(link.url):
            sb.write(link.name)

def compile_books(codegen, meta, *books):
    pages = [page for page in codegen.additional_pages()]

    def compile_chapter_pages(chapters):
        for chapter in chapters:
            sb = codegen()
            uid = title_to_uid(book.title, chapter.title)
            path = uid_to_path(uid, codegen.EXT)
            with sb.root(lang = "en"):
                write_meta(sb, meta, book, chapter)
                with sb.body():
                    write_header(sb, meta, books, book)
                    with sb.article(id="chapter-content"):
                        write_chapters(sb, book, chapter)
                        write_contents(sb, chapter)
                        write_main(sb, book, chapter)
                    write_footer(sb, meta)
            pages.append((path, sb.content))
            if chapter.subchapters:
                compile_chapter_pages(chapter.subchapters)

    for book in books:
        compile_chapter_pages(book.chapters)
    return pages

def write_book_pages(dir, pages):
    for (path, content) in pages:
        fullpath = Path(dir).joinpath(path)
        if not fullpath.parent.exists():
            os.makedirs(fullpath.parent)
        with open(fullpath, "w", encoding="utf-8") as file:
            print(f"...writing '{fullpath}'")
            file.write(content or "whoops! nothing here! /(.0_0.)_b")
    print("done!")