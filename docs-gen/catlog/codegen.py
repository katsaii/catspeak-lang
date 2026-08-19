from dataclasses import dataclass
from textwrap import dedent

@dataclass
class BasicCodegen:
    content : str = ""
    disable : bool = False

    def write(self, x):
        if self.disable:
            return
        self.content += str(x)

    def writeln(self, n = 1):
        if self.disable:
            return
        for _ in range(n):
            self.content += "\n"

    def write_heredoc(self, doc):
        self.write(dedent(doc).strip())

    def block(f):
        class WithHandler:
            def __init__(self, value, on_exit = None):
                do_nothing = lambda: None
                self.value = value
                self.on_exit = on_exit or do_nothing

            def __enter__(self): return self.value
            def __exit__(self, exc_type, exc_value, exc_traceback): self.on_exit()

        def inner(*args, **kwargs):
            gen = f(*args, **kwargs)

            def gen_event():
                try:
                    return next(gen)
                except StopIteration:
                    return None

            return WithHandler(gen_event(), gen_event)

        return inner

    @block
    def no_style(self, **attrs):
        yield