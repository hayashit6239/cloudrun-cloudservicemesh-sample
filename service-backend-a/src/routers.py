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
meter = metrics.get_meter(__name__)

routers_counter = meter.create_counter(
    "routers.count",
    unit="1"
)

routers_duration_histogram = meter.create_histogram(
    "routers.duration",
    unit="ms"
)

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


@router.get("/authors/{author_id}", tags=["/authors"])
async def get_author(author_id: int, db: AsyncSession = Depends(get_db)) -> Author:
    author = await gateways.get_author(author_id, db)
    if author is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="Unknown author_id")
    return Author.model_validate(author)


@router.put("/authors", tags=["/authors"])
async def update_author(author_id: int, name: str, db: AsyncSession = Depends(get_db)) -> Author:
    author = await gateways.update_author(author_id, name, db)
    if author is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="Unknown author_id")
    return Author.model_validate(author)


@router.delete("/authors", tags=["/authors"])
async def delete_author(author_id: int, db: AsyncSession = Depends(get_db)):
    ok = await gateways.delete_author(author_id, db)
    if not ok:
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="Unknown author_id")


@router.get("/micro/a", tags=["/micro/a"])
async def test_micro(request: Request):
    response = await gateways.test_micro()
    return response
