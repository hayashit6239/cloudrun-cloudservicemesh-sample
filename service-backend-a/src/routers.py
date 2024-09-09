from fastapi import APIRouter, Depends, HTTPException, status, Request
from sqlalchemy.ext.asyncio import AsyncSession

from . import gateways
from .database import get_db
from .entities import Author

from opentelemetry import trace, metrics
import logging
import time

router = APIRouter()
tracer = trace.get_tracer_provider().get_tracer("book-servic-a")
logger = logging.getLogger()


@router.get("/micro/a", tags=["/micro/a"])
async def test_micro_service_to_b(request: Request):
    response = await gateways.get_service_backend_to_b()
    return response


@router.post("/authors", tags=["/authors"])
async def add_author(name: str, db: AsyncSession = Depends(get_db)) -> Author:
    author = await gateways.add_author(name, db)
    return Author.model_validate(author)


@router.get("/authors", tags=["/authors"])
async def get_authors(request: Request, db: AsyncSession = Depends(get_db)) -> list[Author]:
    with tracer.start_as_current_span(__name__) as span:
        authors = await gateways.get_authors(db)
        res = list(map(Author.model_validate, authors))
        return res
