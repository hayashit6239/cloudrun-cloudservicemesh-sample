from fastapi import APIRouter, Depends, HTTPException, status
import logging

from . import gateways
from .entities import Author, Book

router = APIRouter()
logger = logging.getLogger()


@router.get("/micro", tags=["/micro"])
async def test_micro_service():
    logger.info("START GET MICRO SERVICE")
    result = await gateways.get_authors_service_backend_a()
    result = await gateways.get_books_service_backend_b()
    return True

@router.get("/micro/a/b", tags=["/micro/a/b"])
async def test_micro_service_to_a_to_b():
    logger.info("START GET MICRO SERVICE")
    result = await gateways.get_service_backend_a_to_b()
    return result


@router.get("/micro/authors", tags=["/micro/authors"])
async def get_authors() -> list[Author]:
    result = await gateways.get_authors_service_backend_a()
    return result


@router.get("/micro/books", tags=["/micro/books"])
async def get_books() -> list[Book]:
    logger.info("START GET_BOOKS")
    result = await gateways.get_books_service_backend_b()
    return result


@router.get("/health", tags=["/health"])
async def health_check():
    logger.info("HEALTH CHECK")
    return True