from pydantic import BaseModel, ConfigDict


class Author(BaseModel):
    id: int
    name: str

    model_config = ConfigDict(from_attributes=True)


class Book(BaseModel):
    id: int
    name: str
    author_id: int

    model_config = ConfigDict(from_attributes=True)


class BookDetails(Book):
    author: Author