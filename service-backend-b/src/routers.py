from fastapi import APIRouter, Depends, HTTPException, status, Request
from sqlalchemy.ext.asyncio import AsyncSession

from . import gateways
from .database import get_db
from .entities import Book, BookDetails
from .instrumentation import parse_trace

from opentelemetry import trace, metrics
import logging
import time
from opentelemetry.propagate import extract

router = APIRouter()
tracer = trace.get_tracer_provider().get_tracer("book-service-b")
logger = logging.getLogger()


@router.post("/micro/b", tags=["/micro/b"])
async def test_micro_service(request: Request, db: AsyncSession = Depends(get_db)):
    with tracer.start_as_current_span(__name__) as span:
        logger.info("START SERVIRCE BACKEND B")
        books = await gateways.get_books(db)
        res = list(map(Book.model_validate, books))
        return res


@router.post("/books", tags=["/books"])
async def add_book(name: str, author_id: int, db: AsyncSession = Depends(get_db)) -> Book:
    book = await gateways.add_book(name, author_id, db)
    if book is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="Unknown author_id")
    return Book.model_validate(book)

@router.get("/books", tags=["/books"])
async def get_books(request: Request, db: AsyncSession = Depends(get_db)) -> list[Book]:
    books = await gateways.get_books(db)
    res = list(map(Book.model_validate, books))
    return res
