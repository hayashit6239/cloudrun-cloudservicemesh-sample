from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from .database import Author, Book

from opentelemetry import trace, context
import logging
import time

import requests, json
from opentelemetry.propagate import extract, inject

tracer = trace.get_tracer_provider().get_tracer("book-service-a")
logger = logging.getLogger()


async def add_author(name: str, db: AsyncSession) -> Author:
    author = Author(id=None, name=name, books=[])  # type: ignore
    db.add(author)
    await db.commit()
    await db.refresh(author)
    return author

async def get_authors(db: AsyncSession):
    with tracer.start_as_current_span(__name__) as span:
        span.add_event(name="get_authors")
        return await db.scalars(select(Author))

async def get_author(author_id: int, db: AsyncSession) -> Author | None:
    return await db.get(Author, author_id)

async def update_author(author_id: int, name: str, db: AsyncSession) -> Author | None:
    author = await db.get(Author, author_id)
    if author:
        author.name = name
        await db.commit()
        await db.refresh(author)
    return author

async def delete_author(author_id: int, db: AsyncSession) -> bool:
    author = await db.get(Author, author_id)
    if author is None:
        return False
    await db.delete(author)
    await db.commit()
    return True

async def test_micro():
    logger.info("REQUEST TO SERVICE BACKEND B")
    func_name = f"{__name__}.get_service_backend_b"
    with tracer.start_as_current_span(__name__) as span:
        span.set_attribute("function.name", func_name)

        url = "http://service-backend-b.sample-app.svc.cluster.local:8082/micro/b"
        headers = {}
        inject(headers)
        response = requests.post(
            url,
            headers=headers
        )
        return response.json()