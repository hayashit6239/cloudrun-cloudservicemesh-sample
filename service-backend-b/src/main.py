from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import os
import logging

from .routers import router

from .instrumentation import instrument

app = FastAPI()
app.include_router(router)

logger = logging.getLogger()

origins = [
    "http://localhost:3000"
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

logger.info(f"Environtment Value: OTEL_EXPORTER_OTLP_ENDPOINT: {os.getenv("OTEL_EXPORTER_OTLP_ENDPOINT")}")

if os.getenv("OTEL_EXPORTER_OTLP_ENDPOINT") is None:
    logger.warning("Environtment Value: OTEL_EXPORTER_OTLP_ENDPOINT is null")
elif os.getenv("OTEL_EXPORTER_OTLP_ENDPOINT") == "":
    logger.info("Environtment Value: OTEL_EXPORTER_OTLP_ENDPOINT is no string")
else:
    instrument(app)