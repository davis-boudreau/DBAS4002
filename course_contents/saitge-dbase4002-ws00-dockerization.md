![alt text](image.png)

---


## **1. Assignment Details**

* **Course Code:** DBAS 4002
* **Course Name:** Transactional Database Programming
* **Assignment Title:** MP-Docker – PostgreSQL in Containers + Database Bootstrap
* **Assignment Type:** Mini-Project (Weeks 1–5 Integration)
* **Duration:** 1 hours
* **Version:** 2.0 (Fall 2025)
* **Instructor:** Davis Boudreau

---

## **2. Overview / Purpose / Objectives**

**Purpose:**
This mini-project consolidates your learning from **Weeks 1–5**, focusing on how to build, initialize, and manage a **PostgreSQL environment using Docker** while maintaining a professional schema and dataset from the **Event Management System** case study.

**Objectives:**

1. Build a reproducible database container using Docker Compose and a Makefile.
2. Apply DDL, constraints, and seed data scripts in an automated environment.
3. Execute a suite of SQL queries (joins, subqueries, set ops, aggregates, and window functions).
4. Demonstrate containerized SQL workflow suitable for DevOps integration.

---

## **3. Learning Outcomes Addressed**

* **O1:** Design and implement relational schemas and integrity rules.
* **O2:** Write SQL that meets business requirements with correct logic.
* **O3:** Use DevOps tools (Docker) to manage consistent database environments.
* **O4:** Produce reusable, documented scripts for system deployment.

---

## **4. Assignment Description / Use Case**

The **Event Management System** tracks categories, events, participants, and registrations.
This mini-project containerizes the full database and initializes it automatically with tables, constraints, and realistic data.

Your system must:

* Create and seed all tables (`Category`, `Event`, `Participant`, `Registration`).
* Enforce integrity (e.g., valid dates, payment statuses).
* Include and run your **Week 3–5 query suites** inside the container.

---

## **5. Tasks / Instructions**

### 🧭 Step 1 – Project Structure

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

### ⚙️ Step 2 – Environment Configuration

**.env**

```env
POSTGRES_USER=app_user
POSTGRES_PASSWORD=app_password
POSTGRES_DB=event_db
PGPORT=5432
PGADMIN_PORT=5050
PGADMIN_DEFAULT_EMAIL=admin@example.com
PGADMIN_DEFAULT_PASSWORD=adminpass
```

---

### 🧱 Step 3 – Dockerfile

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

### 🧩 Step 4 – docker-compose.yml

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

### 🧰 Step 5 – Cross-Platform Makefile (Linux/macOS/Windows)

```makefile
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

### 🧮 Step 6 – SQL Initialization Scripts

#### **01_schema.sql**

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

#### **02_constraints.sql**

```sql
ALTER TABLE Event
  ADD CONSTRAINT chk_event_dates CHECK (end_date > start_date),
  ADD CONSTRAINT chk_priority_range CHECK (priority BETWEEN 1 AND 5);

ALTER TABLE Registration
  ADD CONSTRAINT chk_payment_status CHECK (payment_status IN ('Pending', 'Paid', 'Cancelled'));
```

#### **03_seed.sql**

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

#### **04_extensions.sql**

```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS tablefunc;
```

---

### 🧪 Step 7 – Query Suites

#### Week 3 (Joins & Subqueries)

`sql/10_queries/mp1a_queries.sql`
(Uses joins between `Event`, `Category`, `Participant`, `Registration`)

#### Week 5 (Aggregates & Windows)

`sql/20_aggregates/week5_aggregates.sql`
(Aggregates event counts, averages, and rankings by category or organizer)

#### Tests

`sql/99_tests/mp1b_tests.sql`
(Constraint violation cases for rollback verification)

---

## **6. Deliverables**

Zip the folder:

```
Lastname_Firstname_MP-Docker_Postgres.zip
```

Include:

* `.env`, `Dockerfile`, `docker-compose.yml`, `Makefile`
* `sql/00_init/*` (all initialization scripts)
* `sql/10_queries/mp1a_queries.sql`
* `sql/20_aggregates/week5_aggregates.sql`
* `sql/99_tests/mp1b_tests.sql`
* `README.md` (with reflection answers)

---

## **7. Reflection Questions**

1. What benefits did Docker provide over installing PostgreSQL locally?
2. How do constraints enforce data quality and integrity in this system?
3. Which join or aggregate query produced the most meaningful insight for the event data?
4. Why is automation (via Makefile or Compose) critical for reproducibility?
5. How does using the Event Management schema prepare you for transaction design in DBAS 4002?

---

## **8. Assessment & Rubric (10 pts)**

| **Criteria**       | **Excellent (3)**                 | **Satisfactory (2)**   | **Needs Work (1)**         | **Pts** |
| ------------------ | --------------------------------- | ---------------------- | -------------------------- | ------- |
| Docker Environment | Runs cleanly, resets reproducibly | Minor issues           | Build fails                | __/3    |
| Schema & Integrity | Correct & well-structured         | Partial implementation | Missing tables/constraints | __/2    |
| Query Suites       | Accurate & commented              | Partial coverage       | Incomplete                 | __/3    |
| Reflection         | Deep insights & clarity           | Generic                | Missing                    | __/2    |
| **Total**          |                                   |                        |                            | **/10** |

---

## **9. Submission Guidelines**

* Test all scripts after `make reset`.
* Include all `.sql` and configuration files.
* Do not hardcode credentials.
* Submit via Brightspace or GitHub.

---

## **10. Resources / Equipment**

* Docker Desktop / Engine
* pgAdmin (optional: `localhost:5050`)
* PostgreSQL docs: [https://www.postgresql.org/docs/](https://www.postgresql.org/docs/)

---

## **11. Academic Policies**

Follow NSCC academic integrity policies.
All scripts must be your own. Cite any adapted examples in SQL comments.

---

## **12. Copyright Notice**

© 2025 Nova Scotia Community College – Educational Use Only
