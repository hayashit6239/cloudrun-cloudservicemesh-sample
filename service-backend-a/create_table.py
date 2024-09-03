from sqlalchemy import create_engine
from sqlalchemy.orm import Session

from src.database import Author, Base, Book


def initialize():
    engine = create_engine("sqlite:///db.sqlite3")
    Base.metadata.drop_all(engine)
    Base.metadata.create_all(engine)
    with Session(engine) as session:
        book1 = Book(id=None, name="吾輩は猫である", author_id=None, author=None)
        book2 = Book(id=None, name="高野聖", author_id=None, author=None)
        author1 = Author(id=None, name="夏目漱石", books=[book1])
        author2 = Author(id=None, name="泉鏡花", books=[book2])
        session.add_all([author1, author2])
        session.commit()


initialize()
