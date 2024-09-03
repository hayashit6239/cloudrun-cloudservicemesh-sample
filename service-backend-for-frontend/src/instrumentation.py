import logging
import os

from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from opentelemetry.instrumentation.sqlalchemy import SQLAlchemyInstrumentor
from opentelemetry.sdk.resources import Resource
from opentelemetry.semconv.resource import ResourceAttributes
# トレース関連
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import (
    BatchSpanProcessor,
    SimpleSpanProcessor,
    ConsoleSpanExporter
)
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.exporter.cloud_trace import CloudTraceSpanExporter
# ログ関連
from opentelemetry import _logs
from opentelemetry.sdk._logs import LoggerProvider, LoggingHandler
from opentelemetry.sdk._logs.export import (
    BatchLogRecordProcessor,
    SimpleLogRecordProcessor
)
from opentelemetry.exporter.otlp.proto.grpc._log_exporter import OTLPLogExporter
# メトリクス関連
from opentelemetry import metrics
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.metrics.export import PeriodicExportingMetricReader
from opentelemetry.exporter.otlp.proto.grpc.metric_exporter import OTLPMetricExporter

def instrument(app):
    # Semantic Convestions を指定
    resource = Resource.create({
        ResourceAttributes.SERVICE_NAME: "service-backend-for-frontend",
        ResourceAttributes.SERVICE_INSTANCE_ID: f"service-backend-for-frontend",
    })

    # トレース関連の設定
    trace.set_tracer_provider(
        TracerProvider(resource=resource)
    )
    trace.get_tracer_provider().add_span_processor(
        SimpleSpanProcessor(OTLPSpanExporter(
            endpoint=os.getenv("OTEL_EXPORTER_OTLP_ENDPOINT")
        ))
        # SimpleSpanProcessor(ConsoleSpanExporter())
        # SimpleSpanProcessor(CloudTraceSpanExporter())
    )

    # ログ関連の設定
    logger_provider = LoggerProvider(resource=resource)
    _logs.set_logger_provider(
        logger_provider.add_log_record_processor(
            SimpleLogRecordProcessor(OTLPLogExporter(insecure=True)
        )
    ))

    handler = LoggingHandler(level=logging.NOTSET, logger_provider=logger_provider)
    logging.getLogger().addHandler(handler)
    logging.getLogger().setLevel("INFO")
    
    # メトリクス関連の設定
    metric_reader = PeriodicExportingMetricReader(OTLPMetricExporter())
    metrics.set_meter_provider(
        MeterProvider(resource=resource, metric_readers=[metric_reader])
    )

    # FastAPI の計装
    FastAPIInstrumentor.instrument_app(app)


# async def trace_function(func):
#     """
#     関数をトレースするデコレータ
#     """
#     async def wrapper(*args, **kwargs):
#         tracer = trace.get_tracer_provider().get_tracer("service-backend-for-frontend")
#         print(func.__name__)
#         with tracer.start_as_current_span(func.__name__) as span:
#             # スパンに属性を追加する
#             span.set_attribute("function.name", func.__name__)
#             span.set_attribute("function.args", args)
#             span.set_attribute("function.kwargs", str(kwargs))
#             # 関数を呼び出す
#             result = await func(*args, **kwargs)
#             return result
#     return await wrapper

def add_trace(func):
    """
    関数をトレースするデコレータ
    """
    tracer = trace.get_tracer_provider().get_tracer("default")
    def wrapper(*args, **kwargs):
        with tracer.start_as_current_span(func.__name__) as span:
            # スパンに属性を追加する
            span.set_attribute("function.name", func.__name__)
            span.set_attribute("function.args", args)
            span.set_attribute("function.kwargs", str(kwargs))
            # 関数を呼び出す
            result = func(*args, **kwargs)
            return result
    return wrapper