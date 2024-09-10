from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from .database import Author, Book

from opentelemetry import trace
import logging
import time

import requests, json

tracer = trace.get_tracer_provider().get_tracer("book-service-b")
logger = logging.getLogger()


async def get_service_backend(name: str, author_id: int, db: AsyncSession) -> Book | None:
    with tracer.start_as_current_span(__name__) as span:
        logger.info("FINISH")
        span.add_event(
            name="first service",
            timestamp=int(time.time()),
            attributes={
                "point": "first"
            }
        )
        author = await get_author(author_id, db)
        if not author:
            return None
        book = Book(id=None, name=name, author_id=author.id, author=author)  # type: ignore
        db.add(book)
        await db.commit()
        await db.refresh(book)
        return book

async def add_book(name: str, author_id: int, db: AsyncSession) -> Book | None:
    author = await get_author(author_id, db)
    if not author:
        return None
    book = Book(id=None, name=name, author_id=author.id, author=author)  # type: ignore
    db.add(book)
    await db.commit()
    await db.refresh(book)
    return book


async def get_books(db: AsyncSession):
    with tracer.start_as_current_span(__name__) as span:
        span.add_event(
            name="select all books",
            timestamp=int(time.time()),
            attributes={
                "sql": "select * from book"
            }
        )
        return await db.scalars(select(Book))

async def get_author(author_id: int, db: AsyncSession) -> Author | None:
    return await db.get(Author, author_id)