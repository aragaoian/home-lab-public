FROM python:3.12-slim

WORKDIR /app

RUN pip install --no-cache-dir \
    mlflow \
    "psycopg[binary]" \
    boto3

EXPOSE 5000

CMD ["sh", "-c", "exec mlflow server \
    --host 0.0.0.0 \
    --port 5000 \
    --backend-store-uri \"$MLFLOW_BACKEND_STORE_URI\" \
    --artifacts-destination s3://mlflow-artifacts \
    --serve-artifacts \
    --allowed-hosts 'mlflow,localhost,127.0.0.1,mlflow.example.com'"]
