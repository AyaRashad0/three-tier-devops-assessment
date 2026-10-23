# Three-tier DevOps assessment — Hello World version

Local Docker Compose demo. The frontend (Nginx) fetches a static Hello World API response from FastAPI. PostgreSQL runs as an independent third service; the API **does not connect to or use PostgreSQL**.

## Run

```bash
cp .env.example .env
# Change DB_PASSWORD in .env
sudo docker compose config --quiet
sudo docker compose up --build -d
sudo docker compose ps
curl http://localhost:8080/api/message
```

Visit <http://localhost:8080>.

Expected API response: `{"message":"Hello World from FastAPI!"}`.

## Architecture

Browser -> Nginx frontend :8080 -> FastAPI backend :8000

PostgreSQL :5432 runs separately on an internal Docker network with a persistent volume. No API dependency on it.

## Stop

```bash
sudo docker compose down
```

`sudo docker compose down -v` also deletes the local database volume. Do not commit `.env`.

## Cloud assessment note

This proves provisioning of three services but not database integration. For AWS, the database can be provisioned as RDS while the API remains a static Hello World endpoint. Clearly document that the database is provisioned but intentionally unused.

## Health checks

This local sample intentionally contains no `/health` API endpoint, Nginx health route, or Compose `healthcheck`. For AWS ECS/ALB deployment, configure a suitable target health check path (such as `/api/message`) or implement a dedicated health endpoint if needed.
