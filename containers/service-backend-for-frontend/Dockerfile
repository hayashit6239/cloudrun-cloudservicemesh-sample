FROM fnndsc/python-poetry:latest

COPY service-backend-for-frontend/ /app/

EXPOSE 8080

WORKDIR /app
RUN poetry install

CMD ["poetry", "run", "uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8080"]
           