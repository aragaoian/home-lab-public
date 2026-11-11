# MLflow — Experiment Tracking

MLflow provides the tracking server for experiments and model metadata in this home lab.
The service uses PostgreSQL for its backend store and MinIO for S3-compatible artifact
storage.

## Architecture

```text
MLflow client
    -> Cloudflare Tunnel -> mlflow:5000
                              |-> postgres:5432
                              `-> minio:9000 -> mlflow-artifacts bucket
```

All three services and the `minio-init` setup container use the `home-lab-network`
Docker network. PostgreSQL and MinIO data are persisted in the `postgres_data` and
`minio_data` named volumes.

## Compose services

| Service | Purpose | Published host port |
|---|---|---|
| `mlflow` | Tracking API and UI | `127.0.0.1:5000` |
| `postgres` | MLflow metadata database | None |
| `minio` | Artifact storage and console | `127.0.0.1:9002` (MinIO console) |
| `minio-init` | Creates `mlflow-artifacts` on startup | None |
| `cloudflared` | Cloudflare Tunnel ingress | None |

The MLflow image is built from the repository [Dockerfile](../../Dockerfile). It installs
MLflow, PostgreSQL support and boto3, then starts MLflow on port 5000 with artifact serving
enabled.

## Configuration

Create `.env` from [`.env.example`](../../.env.example) and set strong, unique values for:

```dotenv
POSTGRES_USER=
POSTGRES_PASSWORD=
POSTGRES_DB=
MINIO_ROOT_USER=
MINIO_ROOT_PASSWORD=
CLOUDFLARE_TUNNEL_TOKEN=
```

The `.env` file is ignored by Git and must not be committed. The deployment workflow copies
the protected file from `/home/runner/secrets/.env` before running Compose.

## Deploy and verify

From the repository root:

```bash
docker compose config --quiet
docker compose up -d --build
docker compose ps mlflow postgres minio minio-init
curl http://localhost:5000/health
```

The `mlflow` service waits for PostgreSQL health and successful completion of `minio-init`.
External access is provided through the Cloudflare hostname documented in
[`docs/cloudflare/README.md`](../cloudflare/README.md).

## Useful commands

```bash
docker compose logs -f mlflow
docker compose logs -f postgres
docker compose logs -f minio
docker compose exec postgres pg_isready
```

Do not use `docker compose down -v` unless you intend to delete the database and artifact
volumes.