FROM fnndsc/python-poetry:latest

COPY service-backend-a/ /app/

EXPOSE 8081

WORKDIR /app
RUN poetry install

CMD ["poetry", "run", "uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8081"]