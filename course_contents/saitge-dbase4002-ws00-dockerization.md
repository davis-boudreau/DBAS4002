![alt text](image.png)

---

## **1. Assignment Details**

* **Course Code:** DBAS 3200 / DBAS 4002
* **Course Name:** Data-Driven / Transactional Database Programming
* **Assignment Title:** Mini-Project – Dockerized PostgreSQL: Setup + Schema + Queries
* **Type:** Integrated Mini-Project (Weeks 1–5)
* **Version:** 3.0 (Fall 2025)
* **Instructor:** Davis Boudreau

---

## **2. Overview / Purpose / Objectives**

**Purpose:**
You will build a reproducible, containerized PostgreSQL database environment using **Docker Compose** and a **Makefile**. The database implements the **Event Management System** schema (Categories, Events, Participants, Registrations) used throughout the course.

**Objectives:**

1. Construct a Dockerized PostgreSQL + pgAdmin environment.
2. Automate schema, constraints, and seed data loading.
3. Execute and analyze multi-table SQL queries and window functions.
4. Apply DevOps best practices (Makefile, .env, .gitignore, README).
5. Document and reflect on reproducible database workflows.

---

## **3. Learning Outcomes Addressed**

* **O1:** Design and implement relational schemas with integrity rules.
* **O2:** Write SQL meeting real-world business requirements.
* **O3:** Use DevOps tools to manage consistent database environments.
* **O4:** Document, version, and deploy containerized SQL systems.

---

## **4. Assignment Description / Use Case**

The **Event Management System** tracks event categories, sessions, participants, and registrations.
You will:

* Containerize PostgreSQL 16 + pgAdmin 8.
* Auto-initialize the schema, constraints, and seed data.
* Run your Week 3 (joins/subqueries) and Week 5 (aggregates/windows) queries inside the container.
* Provide a clean developer workflow with **Makefile automation** and professional documentation.

---

## **5. Tasks / Instructions**

### 🧭 Step 1 – Project Structure

```
mp-docker-postgres/
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

### ⚙️ Step 2 – Environment Configuration (`.env`)

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

### 📦 Step 3 – Dockerfile

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

### 🧱 Step 4 – docker-compose.yml

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

### 🧰 Step 5 – Makefile (cross-platform)

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

### 🗂 Step 6 – SQL Initialization Scripts

*(Event Management Schema + Seed Data)*

#### 01_schema.sql

```sql
CREATE TABLE Category (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Event (
    event_id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    category_id INT NOT NULL REFERENCES Category(category_id) ON DELETE CASCADE,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    priority INT DEFAULT 1,
    description TEXT DEFAULT '',
    location VARCHAR(255) DEFAULT '',
    organizer VARCHAR(100) DEFAULT ''
);

CREATE TABLE Participant (
    participant_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    registered_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE Registration (
    registration_id SERIAL PRIMARY KEY,
    event_id INT NOT NULL REFERENCES Event(event_id) ON DELETE CASCADE,
    participant_id INT NOT NULL REFERENCES Participant(participant_id) ON DELETE CASCADE,
    registered_on TIMESTAMP DEFAULT NOW(),
    payment_status VARCHAR(20) DEFAULT 'Pending',
    UNIQUE (event_id, participant_id)
);
```

#### 02_constraints.sql

```sql
ALTER TABLE Event
  ADD CONSTRAINT chk_event_dates CHECK (end_date > start_date),
  ADD CONSTRAINT chk_priority_range CHECK (priority BETWEEN 1 AND 5);

ALTER TABLE Registration
  ADD CONSTRAINT chk_payment_status CHECK (payment_status IN ('Pending', 'Paid', 'Cancelled'));
```

#### 03_seed.sql

```sql
INSERT INTO Category (name)
VALUES ('Workshop'), ('Seminar'), ('Conference');

INSERT INTO Event (name, category_id, start_date, end_date, priority, description, location, organizer)
VALUES
('Database Fundamentals', 1, '2025-09-10 09:00', '2025-09-10 16:00', 2, 'Introductory SQL Workshop', 'Room 201', 'NSCC IT Dept'),
('Cloud Security Summit', 3, '2025-10-05 10:00', '2025-10-07 17:00', 3, 'Multi-day conference', 'Halifax Convention Centre', 'Tech NS'),
('DevOps 101', 1, '2025-10-15 13:00', '2025-10-15 17:00', 1, 'Hands-on Docker workshop', 'Room 305', 'NSCC IT Dept');

INSERT INTO Participant (first_name, last_name, email)
VALUES
('Alice', 'Johnson', 'alice.johnson@example.com'),
('Bob', 'Martens', 'bob.martens@example.com'),
('Carol', 'Nguyen', 'carol.nguyen@example.com');

INSERT INTO Registration (event_id, participant_id, payment_status)
VALUES
(1, 1, 'Paid'),
(1, 2, 'Pending'),
(2, 3, 'Paid');
```

#### 04_extensions.sql

```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS tablefunc;
```

---

### 🧪 Step 7 – Query Suites and Tests

(joins, aggregates, and validation queries already defined in previous version)

---

### 🧱 Step 8 – Support Files

#### `.gitignore`

```gitignore
.env
*.env
pgdata/
pgadmin/
__pycache__/
*.log
*.pid
.vscode/
.idea/
.DS_Store
tmp/
*.tmp
```

#### `.dockerignore`

```dockerignore
.git
.gitignore
pgdata/
pgadmin/
__pycache__/
*.log
.vscode/
.idea/
.DS_Store
README.md
Makefile
```

#### `pgadmin/servers.json`

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

#### `README.md`

*(contains quick-start, structure, and credentials information as in previous section)*

---

## **6. Deliverables**

Submit as:

```
Lastname_Firstname_MP-Docker_Postgres.zip
```

Include all configuration, SQL, and reflection files exactly as structured above.

---

## **7. Reflection Questions**

1. How does Docker improve reproducibility and team collaboration?
2. Why is container health checking important for CI/CD pipelines?
3. Which constraint or query most improved data integrity?
4. How might this setup scale to a multi-service system (e.g., Django backend)?
5. What additional developer practices could strengthen this environment (logging, migrations, versioning)?

---

## **8. Assessment & Rubric (10 pts)**

| **Criteria**       | **Excellent (3)**                | **Satisfactory (2)**  | **Needs Improvement (1)** | **Pts** |
| ------------------ | -------------------------------- | --------------------- | ------------------------- | ------- |
| Docker Environment | Clean build & stable healthcheck | Minor config issues   | Fails to build            | __/3    |
| Schema & Integrity | Fully correct & documented       | Minor constraint gaps | Missing/invalid           | __/2    |
| Query Suites       | Complete & commented             | Partial               | Incomplete                | __/3    |
| Reflection         | Deep technical analysis          | General               | Missing                   | __/2    |
| **Total**          |                                  |                       |                           | **/10** |

---

## **9. Submission Guidelines**

* Verify all scripts with `make reset` and `make run-tests`.
* Ensure all credentials remain in `.env` (not in code).
* Submit via Brightspace or GitHub repository.

---

## **10. Resources / Equipment**

* Docker Desktop or Docker Engine + Compose v2
* pgAdmin (5050 port)
* PostgreSQL Docs – [https://www.postgresql.org/docs/](https://www.postgresql.org/docs/)

---

## **11. Academic Policies**

Adhere to NSCC academic integrity standards.
All SQL must be original; cite sources in comments when applicable.

---

## **12. Copyright Notice**

© 2025 Nova Scotia Community College – For educational use only.
