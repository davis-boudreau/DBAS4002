![alt text](image.png)

---

## 1) Assignment Details

* **Course:** DBAS 4002 – Data-Driven Application Programming
* **Title:** MP-Docker – PostgreSQL in Containers + Database Bootstrap
* **Type:** Guided Tutorial + Build Scripts (Hands-On)
* **Estimated Time:** 3–6 hours (first setup) + 1–2 hours reruns
* **Version:** 1.2 (Fall 2025)

---

## 2) Overview / Purpose / Objectives

You will containerize PostgreSQL using Docker and Compose, then automate environment setup through SQL scripts and a Makefile.
By the end, you’ll be able to:

1. Spin up and tear down PostgreSQL instances in seconds.
2. Apply schemas, constraints, and seed data automatically.
3. Run joins, subqueries, aggregations and window functions from Weeks 1–5.
4. Work with a cross-platform Makefile for automation (Linux/macOS/Windows).

---

## 3) Learning Outcomes Addressed

* **O1** – Design and implement relational schemas and integrity rules.
* **O1** – Write correct and efficient SQL queries.
* **O3** – Use DevOps tools (Docker) to manage a reliable database environment.
* **O4** – Develop repeatable, documented scripts for professional deployment.

---

## 4) Assignment Description / Use Case

You’ll containerize a PostgreSQL server with Docker and Compose.
Initialization scripts (`sql/00_init`) will auto-run to create tables, constraints, seed data, and extensions.
The project is the foundation for MP2 (Procedural SQL & Transactions).

---

## 5) Tasks / Instructions (Step-by-Step)

### A) Prerequisites

* Install **Docker Desktop** or **Docker Engine**.
* Confirm versions:

  ```bash
  docker --version
  docker compose version
  ```

---

### B) Project Structure

```
mp-docker-postgres/
├─ .env
├─ Dockerfile
├─ docker-compose.yml
├─ Makefile
├─ sql/
│  ├─ 00_init/
│  │  ├─ 01_schema.sql
│  │  ├─ 02_constraints.sql
│  │  ├─ 03_seed.sql
│  │  └─ 04_extensions.sql
│  ├─ 10_queries/mp1a_queries.sql
│  ├─ 20_aggregates/week5_aggregates.sql
│  └─ 99_tests/mp1b_tests.sql
├─ pgadmin/servers.json
└─ README.md
```

---

### C) Environment Variables (`.env`)

```env
POSTGRES_USER=app_user
POSTGRES_PASSWORD=app_password
POSTGRES_DB=app_db
PGPORT=5432
PGADMIN_PORT=5050
PGADMIN_DEFAULT_EMAIL=admin@example.com
PGADMIN_DEFAULT_PASSWORD=adminpass
```

---

### D) Dockerfile

```dockerfile
FROM postgres:16
LABEL maintainer="student@nscc.ca" \
      description="Custom PostgreSQL image for DBAS3200 MP Docker Project"

COPY sql/00_init /docker-entrypoint-initdb.d/
EXPOSE 5432

HEALTHCHECK --interval=30s --timeout=10s --start-period=10s \
  CMD pg_isready -U ${POSTGRES_USER:-app_user} -d ${POSTGRES_DB:-app_db} || exit 1
```

---

### E) docker-compose.yml

```yaml
services:
  db:
    build: .
    container_name: mp_db
    env_file: .env
    restart: unless-stopped
    ports:
      - "${PGPORT}:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data
      - ./sql:/sql
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      interval: 10s
      timeout: 5s
      retries: 5

  pgadmin:
    image: dpage/pgadmin4:8
    container_name: mp_pgadmin
    restart: unless-stopped
    environment:
      PGADMIN_DEFAULT_EMAIL: ${PGADMIN_DEFAULT_EMAIL}
      PGADMIN_DEFAULT_PASSWORD: ${PGADMIN_DEFAULT_PASSWORD}
    ports:
      - "${PGADMIN_PORT}:80"
    depends_on:
      - db
    volumes:
      - ./pgadmin:/pgadmin4

volumes:
  pgdata:
```

---

### F) Cross-Platform Makefile (Linux/macOS and Windows)

```makefile
# -----------------------------------------------
# DBAS3200 Dockerized PostgreSQL – Cross-Platform Makefile
# -----------------------------------------------

POSTGRES_USER := $(shell grep POSTGRES_USER .env | cut -d '=' -f2)
POSTGRES_DB   := $(shell grep POSTGRES_DB .env | cut -d '=' -f2)
DB_CONTAINER  := mp_db

ifeq ($(OS),Windows_NT)
	SHELL := powershell.exe
	.SHELLFLAGS := -NoProfile -Command
endif

up:
	docker compose up -d
	@echo "✅ Containers are starting..."

down:
	docker compose down
	@echo "🧹 Containers stopped (volumes preserved)."

reset:
	docker compose down -v
	docker compose up -d --build
	@echo "♻️  Environment reset (fresh DB volume)."

logs:
	docker compose logs -f db

ps:
	docker compose ps

psql:
	docker exec -it $(DB_CONTAINER) psql -U $(POSTGRES_USER) -d $(POSTGRES_DB)

run-init:
	docker exec -it $(DB_CONTAINER) psql -U $(POSTGRES_USER) -d $(POSTGRES_DB) -f /sql/00_init/01_schema.sql
	docker exec -it $(DB_CONTAINER) psql -U $(POSTGRES_USER) -d $(POSTGRES_DB) -f /sql/00_init/02_constraints.sql
	docker exec -it $(DB_CONTAINER) psql -U $(POSTGRES_USER) -d $(POSTGRES_DB) -f /sql/00_init/03_seed.sql

run-queries:
	docker exec -it $(DB_CONTAINER) psql -U $(POSTGRES_USER) -d $(POSTGRES_DB) -f /sql/10_queries/mp1a_queries.sql

run-aggregates:
	docker exec -it $(DB_CONTAINER) psql -U $(POSTGRES_USER) -d $(POSTGRES_DB) -f /sql/20_aggregates/week5_aggregates.sql

run-tests:
	docker exec -it $(DB_CONTAINER) psql -U $(POSTGRES_USER) -d $(POSTGRES_DB) -f /sql/99_tests/mp1b_tests.sql

clean:
	docker system prune -f
	@echo "🧽 Docker system pruned (containers/images)."

help:
	@echo ""
	@echo "🧰 DBAS3200 PostgreSQL Docker Commands"
	@echo "-------------------------------------"
	@echo " make up            - Start containers"
	@echo " make down          - Stop containers (keep data)"
	@echo " make reset         - Reset environment (new DB)"
	@echo " make logs          - View logs"
	@echo " make ps            - List containers"
	@echo " make psql          - Open psql shell"
	@echo " make run-init      - Run schema + seed scripts"
	@echo " make run-queries   - Run MP1A suite"
	@echo " make run-aggregates- Run Week5 suite"
	@echo " make run-tests     - Run constraint tests"
	@echo " make clean         - Prune Docker system"
	@echo ""
```

**Linux/macOS:** Run `make up`, `make psql`, `make reset`.
**Windows:** Install `make` (`choco install make`) or use **Git Bash**, then same commands.

**Optional Advanced Targets:**

```makefile
backup:
	docker exec $(DB_CONTAINER) pg_dump -U $(POSTGRES_USER) $(POSTGRES_DB) > backup.sql

restore:
	type backup.sql | docker exec -i $(DB_CONTAINER) psql -U $(POSTGRES_USER) -d $(POSTGRES_DB)
```

---

### G) SQL Scripts

All SQL from previous assignments (schema, constraints, seeds, joins, subqueries, aggregates, windows, tests) remains unchanged.
Include `04_extensions.sql` to enable `uuid-ossp`, `pgcrypto`, and `tablefunc`.

---

### H) Running the Project

```bash
make up            # start environment
make psql          # open SQL shell
make run-queries   # MP1A suite
make run-aggregates# Week5 suite
make run-tests     # constraint tests
make reset         # rebuild everything
```

---

## 6) Deliverables

Zip and submit:

```
studentid_course_MP-Docker_Postgres.zip
```

Contents: `.env`, `Dockerfile`, `docker-compose.yml`, `Makefile`, all `sql` scripts, optional `pgadmin/servers.json`, and `README.md`.

---

## 7) Reflection

Include in `README.md`:

* One benefit Docker provided.
* Which constraint caught real data errors.
* Where a window function was superior to an aggregate.
* How automation via Makefile changed your workflow.

---

## 8) Rubric (10 pts)

| Dimension            | 0–1              | 2                 | 3                     | Pts  |
| -------------------- | ---------------- | ----------------- | --------------------- | ---- |
| Docker Environment   | Fails to run     | Runs but brittle  | Reliable & resettable | __/3 |
| Schema & Constraints | Missing rules    | Partially correct | Correct & meaningful  | __/2 |
| Query Suites         | Errors / missing | Meets minimum     | Correct + commented   | __/3 |
| Reflection & Docs    | Missing          | Basic             | Insightful & applied  | __/2 |

---

## 9) Submission Guidelines

Run `make reset` and re-verify before zipping.
Use demo credentials only; ensure scripts run non-interactively.

---

## 10) Resources & Troubleshooting

* Docker Desktop / Engine
* pgAdmin [http://localhost:${PGADMIN_PORT}](http://localhost:${PGADMIN_PORT})
* `docker compose logs -f db` → view logs
* Reset volume → `docker compose down -v && docker compose up -d`

---
