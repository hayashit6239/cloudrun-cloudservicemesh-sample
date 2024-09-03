FROM otel/opentelemetry-collector-contrib:0.90.1

COPY ./containers/service-otel-collector/otel-collector.yaml /etc/otel-collector.yaml

CMD ["--config=/etc/otel-collector.yaml"]