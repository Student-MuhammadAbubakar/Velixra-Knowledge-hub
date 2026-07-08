# Velixra Knowledge Hub — Backend

This repository contains the backend API for the Velixra Knowledge Hub — a RAG-based document Q&A system built with FastAPI and SQLModel.

**Key features**
- Lightweight REST API using `FastAPI`.
- Async database access with `SQLModel` and `asyncpg`.
- Document ingestion, embeddings, and retrieval (RAG pipeline).
- Authentication, analytics, team and chat endpoints.

**Project layout**
- `app/` — application package and FastAPI entrypoint.
	- `main.py` — FastAPI app and server lifecycle ([app/main.py](app/main.py)).
	- `core/` — config, database and shared utilities ([app/core](app/core)).
	- `router/` — API route modules for auth, documents, chat, analytics, team.
	- `services/`, `repositories/`, `tasks/`, `utils/` — business logic and helpers.
- `uploads/` — uploaded documents (local development).
- `requirements.txt` — Python dependencies.

**Prerequisites**
- Python 3.10+ (3.11 recommended).
- PostgreSQL accessible to the app (for dev you can run locally or via Docker).
- Optional: Redis or other services if you extend caching/queueing.

Installation

1. Create a virtual environment and activate it:

```bash
python -m venv .venv
source .venv/Scripts/activate  # Windows PowerShell: .venv\Scripts\Activate.ps1
```

2. Install dependencies:

```bash
pip install -r requirements.txt
```

Configuration (.env)

The app reads configuration from an `.env` file at the repository root. At minimum, provide the following environment variables (see `app/core/config.py`):

```
POSTGRES_SERVER=localhost
POSTGRES_PORT=5432
POSTGRES_USER=your_db_user
POSTGRES_PASSWORD=your_db_password
POSTGRES_DB=your_db_name
SECRET_KEY=some-secret-string
SMTP_HOST=smtp.example.com
SMTP_PORT=587
SMTP_USERNAME=smtp_user
SMTP_PASSWORD=smtp_password
FROM_EMAIL=no-reply@example.com
GROQ_API_KEY=your_groq_api_key
```

Adjust values for your environment. For local development you can run PostgreSQL in Docker:

```bash
docker run --name velixra-postgres -e POSTGRES_USER=dev -e POSTGRES_PASSWORD=dev -e POSTGRES_DB=velixra -p 5432:5432 -d postgres:15
```

Running the application

Start the app with Uvicorn (development):

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Open interactive docs at `http://localhost:8000/docs`.

Database migrations / schema

On startup the application will create/verify tables automatically using `SQLModel` metadata (see `app/main.py`). For production use consider adding a proper migration workflow (e.g., `alembic`).

Testing

- Add tests under a `tests/` directory and run with `pytest`.

Development notes

- CORS is currently wide open in `app/main.py` (allow_origins=["*"]). Restrict origins before deploying to production.
- Secrets must be kept out of source control; do not commit `.env`.
- File uploads are stored in `uploads/` — for production use an object storage service (S3, GCS).

Useful file references
- FastAPI entry: [app/main.py](app/main.py)
- App config: [app/core/config.py](app/core/config.py)

Contributing

- Fork the repository, create a feature branch, run tests, and open a PR.

License

Specify your license here (e.g., MIT) or remove this section if not applicable.

---

If you want, I can also:
- add a sample `.env.example`,
- create a `Makefile` or `docker-compose.yml` for local dev, or
- add CI/test scaffolding.
