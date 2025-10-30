![alt text](image.png)

---

## **1 · Assignment Details**

| Field           | Information                                              |
| --------------- | -------------------------------------------------------- |
| **Course Code** | DBAS 3200 / DBAS 4002                                    |
| **Course Name** | Data-Driven / Transactional Database Programming         |
| **Stack Name**  | **DBAS PostgreSQL DevOps Stack (v3.2)**                  |
| **Type**        | Integrated Mini-Project (Environment + Schema + Queries) |
| **Instructor**  | Davis Boudreau                                           |
| **Version**     | 3.2 (Fall 2025)                                          |

---

## **2 · Purpose / Objectives**

**Purpose**
Deploy a fully reproducible **PostgreSQL + pgAdmin** stack using Docker Compose and Makefile automation.
This stack hosts the **Event Management System** schema used across both database courses.

**Objectives**

1. Containerize PostgreSQL and pgAdmin using Docker Compose.
2. Automate initialization (schema → constraints → seed data).
3. Run query suites (joins, subqueries, aggregates, window functions).
4. Apply DevOps best practices (.env, Makefile, volumes, health checks).
5. Document, test, and reflect on environment reproducibility.

---

## **3 · Learning Outcomes Addressed**

* **O1 :** Design and implement relational schemas with integrity rules.
* **O2 :** Write SQL that meets business requirements.
* **O3 :** Use DevOps tools to build consistent database environments.
* **O4 :** Document and deploy containerized SQL systems.

---

## **4 · Stack Description / Use Case**

The system implements an **Event Management Database** for workshops, seminars, and registrations.
Students design, initialize, and query the database within a Dockerized environment.

Use cases include:

* Creating and maintaining event categories and details.
* Registering participants and tracking payments.
* Executing aggregates and window functions for reporting.

---

## **5 · Stack Files and Instructions**

### 🧭 Folder Structure

```
dbas-postgres-devops-stack/
├─ .env
├─ .gitignore
├─ .dockerignore
├─ Dockerfile
├─ docker-compose.yml
├─ Makefile
├─ pgadmin/
│  └─ servers.json
├─ sql/
│  ├─ 00_init/
│  │  ├─ 01_schema.sql
│  │  ├─ 02_constraints.sql
│  │  ├─ 03_seed.sql
│  │  └─ 04_extensions.sql
│  ├─ 10_queries/mp1a_queries.sql
│  ├─ 20_aggregates/week5_aggregates.sql
│  └─ 99_tests/mp1b_tests.sql
└─ README.md
```

---

### ⚙️ `.env`

```bash
POSTGRES_USER="app_user"
POSTGRES_PASSWORD="app_password"
POSTGRES_DB="event_db"
PGPORT=5432
PGADMIN_PORT=5050
PGADMIN_DEFAULT_EMAIL="admin@example.com"
PGADMIN_DEFAULT_PASSWORD="adminpass"
PGDATA=/var/lib/postgresql/data
```

---

### 📦 `Dockerfile`

```dockerfile
FROM postgres:16
LABEL maintainer="student@nscc.ca" \
      description="Dockerized PostgreSQL for Event Management System"

COPY sql/00_init /docker-entrypoint-initdb.d/
EXPOSE 5432

HEALTHCHECK --interval=30s --timeout=10s --start-period=10s \
  CMD pg_isready -U ${POSTGRES_USER:-app_user} -d ${POSTGRES_DB:-event_db} || exit 1
```

---

### 🧱 `docker-compose.yml`

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
      - ./sql:/sql:ro
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      interval: 10s
      timeout: 5s
      retries: 5

  pgadmin:
    image: dpage/pgadmin4:latest
    container_name: mp_pgadmin
    restart: unless-stopped
    environment:
      PGADMIN_DEFAULT_EMAIL: ${PGADMIN_DEFAULT_EMAIL}
      PGADMIN_DEFAULT_PASSWORD: ${PGADMIN_DEFAULT_PASSWORD}
      PGADMIN_SERVER_JSON_FILE: /pgadmin4/servers.json
    ports:
      - "${PGADMIN_PORT}:80"
    depends_on:
      - db
    volumes:
      - ./pgadmin/servers.json:/pgadmin4/servers.json:ro
      - pgadmin-data:/var/lib/pgadmin

volumes:
  pgdata:
  pgadmin-data:
```

---

### 🧰 `Makefile`

```makefile
POSTGRES_USER := $(shell grep POSTGRES_USER .env | cut -d '=' -f2 | tr -d '"')
POSTGRES_DB   := $(shell grep POSTGRES_DB .env | cut -d '=' -f2 | tr -d '"')
DB_CONTAINER  := mp_db

ifeq ($(OS),Windows_NT)
  SHELL := powershell.exe
  .SHELLFLAGS := -NoProfile -Command
endif

up:
	docker compose up -d
	@echo "✅ Containers starting..."

down:
	docker compose down
	@echo "🧹 Containers stopped (volumes preserved)."

reset:
	docker compose down -v
	docker compose up -d --build
	@echo "♻️  Environment reset with clean DB."

psql:
	docker exec -it $(DB_CONTAINER) psql -U $(POSTGRES_USER) -d $(POSTGRES_DB)

run-queries:
	docker exec -it $(DB_CONTAINER) psql -U $(POSTGRES_USER) -d $(POSTGRES_DB) -f /sql/10_queries/mp1a_queries.sql

run-aggregates:
	docker exec -it $(DB_CONTAINER) psql -U $(POSTGRES_USER) -d $(POSTGRES_DB) -f /sql/20_aggregates/week5_aggregates.sql

run-tests:
	docker exec -it $(DB_CONTAINER) psql -U $(POSTGRES_USER) -d $(POSTGRES_DB) -f /sql/99_tests/mp1b_tests.sql

clean:
	docker system prune -f
	@echo "🧽 Docker system cleaned."
```

---

### 🗂 SQL Initialization Scripts

Includes:

* **01_schema.sql** – table creation
* **02_constraints.sql** – check & foreign-key rules
* **03_seed.sql** – initial data
* **04_extensions.sql** – PostgreSQL extensions

All verified for PostgreSQL 16 syntax.

---

### 🧱 Support Files

**.gitignore**

```gitignore
.env
*.env
pgdata/
pgadmin-data/
__pycache__/
*.log
.vscode/
.idea/
.DS_Store
```

**.dockerignore**

```dockerignore
.git
.gitignore
pgdata/
pgadmin-data/
__pycache__/
*.log
.vscode/
.idea/
.DS_Store
README.md
Makefile
pgadmin/
```

**pgadmin/servers.json**

```json
{
  "Servers": {
    "1": {
      "Name": "Local PostgreSQL (EventDB)",
      "Group": "Local",
      "Host": "db",
      "Port": 5432,
      "MaintenanceDB": "event_db",
      "Username": "app_user",
      "SSLMode": "prefer"
    }
  }
}
```

---

### 🧩 Step 9 – Python Environment (Optional for Developers)

Developers can install Python utilities for testing, linting, and Django integration.

**Create a virtual environment**

```bash
python -m venv venv
source venv/bin/activate     # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

**requirements.txt**

```text
# --- Core Database Tools ---
psycopg2-binary==2.9.9
SQLAlchemy==2.0.25
alembic==1.13.2

# --- Developer Utilities ---
pgcli==4.1.0
sqlfluff==3.0.6
pytest==8.3.3
pytest-dotenv==0.5.2

# --- Code Quality ---
black==24.10.0
flake8==7.1.1
```

> 💡 **Purpose:** enables SQL linting, testing, and smooth integration with Python frameworks such as Django and Flask.
> Add `requirements.txt` and `venv/` to `.dockerignore` if not used inside containers.

---

### 🧭 README.md (Excerpt)

Includes full quick-start guide:

```bash
make up
make psql
make run-queries
make reset
```

and notes on environment variables, troubleshooting, and developer workflows.

---

## **6 · Deliverables**

Submit:

```
Lastname_Firstname_DBAS_Postgres_DevOps_Stack.zip
```

including all files, SQL scripts, and README.md.

---

## **7 · Reflection Questions**

1. How does Docker enable reproducibility for databases?
2. Why must constraints load before seeding data?
3. Which query best demonstrated data relationships?
4. How does containerization improve team workflow?
5. What DevOps features could extend this stack (CI/CD, migrations, monitoring)?

---

## **8 · Assessment Rubric (10 pts)**

| Criteria           | Excellent (3)               | Satisfactory (2) | Needs Improvement (1) | Pts     |
| ------------------ | --------------------------- | ---------------- | --------------------- | ------- |
| Environment Build  | Stable & passes healthcheck | Minor issues     | Fails to start        | __/3    |
| Schema & Integrity | Complete & validated        | Partial          | Missing               | __/2    |
| Query Suites       | Accurate & commented        | Partial          | Incomplete            | __/3    |
| Reflection         | Insightful & applied        | Generic          | Missing               | __/2    |
| **Total**          |                             |                  |                       | **/10** |

---

## **9 · Submission Guidelines**

Verify with:

```bash
make reset
make run-tests
```

Keep `.env` private and excluded from Git.
Submit via Brightspace or GitHub.

---

## **10 · Resources / Equipment**

* Docker Desktop / Engine + Compose v2
* pgAdmin (latest) at port 5050
* PostgreSQL Docs → [https://www.postgresql.org/docs/](https://www.postgresql.org/docs/)

---

## **11 · Academic Policies**

Follow NSCC academic integrity guidelines. Comment and cite any adapted code.

---

## **12 · Copyright**

© 2025 Nova Scotia Community College – For educational use only.
