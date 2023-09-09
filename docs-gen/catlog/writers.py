from .writer_utils import withable
from . import template

class HTMLWriter:
    content = ""

    @withable
    def header(self):
        self.content += template.HEAD_ENTER
        yield
        self.content += template.HEAD_EXIT

    @withable
    def body(self):
        self.content += template.BODY_ENTER
        yield
        self.content += template.BODY_EXIT