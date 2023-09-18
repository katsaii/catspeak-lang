from dataclasses import dataclass, field
from . import doc

@dataclass
class Module():
    name : str = None
    overview : str = None

    def into_chapter(self):
        return doc.Chapter(
            title = self.name,
            overview = self.overview
        )