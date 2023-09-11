def write_nothing(): pass

class WriterWithableAdaptor:
    def __init__(self, on_enter = None, on_exit = None):
        self.on_enter = on_enter or write_nothing
        self.on_exit = on_exit or write_nothing

    def __enter__(self): return self.on_enter()
    def __exit__(self, exc_type, exc_value, exc_traceback): self.on_exit()

def withable(f):
    def inner(*args, **kwargs):
        gen = f(*args, **kwargs)
        def gen_event():
            try:
                return next(gen)
            except StopIteration:
                return None
        gen_event()
        return WriterWithableAdaptor(None, gen_event)
    return inner