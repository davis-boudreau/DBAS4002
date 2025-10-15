![alt text](image.png)

___

## 1) Assignment Details

* **Course:** DBAS 3200 – Data-Driven Application Programming
* **Title:** MP-Docker: PostgreSQL in Containers + Database Bootstrap
* **Type:** Guided Tutorial + Build Scripts (Hands-on)
* **Estimated Time:** 3–6 hours (first setup) + 1–2 hours to rerun/iterate
* **Version:** 1.0 (Fall 2025)

---

## 2) Overview / Purpose / Objectives

You’ll spin up a **local PostgreSQL server** in Docker and use **repeatable scripts** to:

1. create the schema,
2. enforce constraints,
3. seed data, and
4. run the query suites you’ve written in Weeks 2–5 (joins, subqueries, set ops, aggregates, window functions).

**You leave with a clean, rebuildable environment** you can reset in seconds—perfect for iterative testing and marking.

---

## 3) Learning Outcomes Addressed

* Design and implement relational schemas and integrity rules (O1).
* Write correct and efficient SQL (joins, subqueries, set ops, aggregates, windows) (O1).
* Use dev tooling (Docker) to manage a reliable DB environment (O3).
* Produce reproducible scripts for peers/instructors (O4).

---

## 4) Assignment Description / Use Case

We’ll containerize Postgres using **docker-compose**, mount an **init folder** that auto-runs on first start, and keep all SQL in a versioned **/sql** directory. The sample schema mirrors our early course work (generalized case study with `Category` and `Event`).

---

## 5) Tasks / Instructions (Step-by-Step)

### A) Prereqs

* Install **Docker Desktop** (Win/Mac) or Docker Engine (Linux).
* Confirm:

  ```bash
  docker --version
  docker compose version
  ```

### B) Project Scaffold

Create a working folder and file layout:

```
mp-docker-postgres/
├─ .env
├─ docker-compose.yml
├─ Makefile                 # optional quality-of-life
├─ sql/
│  ├─ 00_init/
│  │  ├─ 01_schema.sql
│  │  ├─ 02_constraints.sql
│  │  └─ 03_seed.sql
│  ├─ 10_queries/
│  │  └─ mp1a_queries.sql
│  ├─ 20_aggregates/
│  │  └─ week5_aggregates.sql
│  └─ 99_tests/
│     └─ mp1b_tests.sql
└─ README.md
```

### C) Environment Variables (`.env`)

> Keep secrets out of VCS; `.env` is read by compose.

```env
POSTGRES_USER=app_user
POSTGRES_PASSWORD=app_password
POSTGRES_DB=app_db
PGPORT=5432
PGADMIN_PORT=5050
```

### D) docker-compose.yml

* Maps `sql/00_init` into `docker-entrypoint-initdb.d` so Postgres runs those scripts **only on first startup of a fresh volume**.
* Provides a persistent volume `pgdata`.

```yaml
services:
  db:
    image: postgres:16
    container_name: mp_db
    restart: unless-stopped
    env_file: .env
    environment:
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_DB=${POSTGRES_DB}
    ports:
      - "${PGPORT}:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data
      - ./sql/00_init:/docker-entrypoint-initdb.d:ro

  # Optional pgAdmin (web UI)
  pgadmin:
    image: dpage/pgadmin4:8
    container_name: mp_pgadmin
    restart: unless-stopped
    environment:
      - PGADMIN_DEFAULT_EMAIL=admin@example.com
      - PGADMIN_DEFAULT_PASSWORD=adminpass
    ports:
      - "${PGADMIN_PORT}:80"
    depends_on:
      - db

volumes:
  pgdata:
```

### E) Makefile (optional but handy)

```makefile
DB=mp_db
PSQL=docker exec -it $(DB) psql -U $(POSTGRES_USER) -d $(POSTGRES_DB)

up:
\tdocker compose up -d

down:
\tdocker compose down

reset:
\tdocker compose down -v
\tdocker compose up -d

psql:
\t$(PSQL)

run-queries:
\t$(PSQL) -f /sql/10_queries/mp1a_queries.sql

run-aggregates:
\t$(PSQL) -f /sql/20_aggregates/week5_aggregates.sql

run-tests:
\t$(PSQL) -f /sql/99_tests/mp1b_tests.sql
```

> If you use the Makefile, export the env vars in your shell or rely on `docker compose` reading `.env`.

### F) SQL Scripts

#### `sql/00_init/01_schema.sql`

```sql
-- Base schema (Weeks 1–2 foundation)
CREATE TABLE IF NOT EXISTS Category (
  category_id SERIAL PRIMARY KEY,
  name        VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS Event (
  event_id    SERIAL PRIMARY KEY,
  name        VARCHAR(100) NOT NULL,
  start_date  TIMESTAMP NOT NULL,
  end_date    TIMESTAMP NOT NULL,
  priority    INT DEFAULT 1,
  description TEXT,
  location    VARCHAR(255),
  organizer   VARCHAR(100),
  category_id INT NOT NULL REFERENCES Category(category_id) ON DELETE CASCADE
);
```

#### `sql/00_init/02_constraints.sql`

```sql
-- Integrity & business rules (Week 4)
ALTER TABLE Event
  ADD CONSTRAINT chk_event_dates CHECK (end_date > start_date);

ALTER TABLE Event
  ADD CONSTRAINT chk_priority_range CHECK (priority BETWEEN 1 AND 5);

-- Example: prevent empty organizer strings (treat '' as NULL)
ALTER TABLE Event
  ADD CONSTRAINT chk_organizer_nonempty CHECK (organizer IS NULL OR organizer <> '');
```

#### `sql/00_init/03_seed.sql`

```sql
-- Minimal seed (3 categories, a few events) (Week 4)
INSERT INTO Category (name) VALUES
('Workshop'), ('Conference'), ('Webinar')
ON CONFLICT DO NOTHING;

INSERT INTO Event (name, start_date, end_date, priority, description, location, organizer, category_id)
VALUES
('Intro to SQL',        '2025-09-20 10:00', '2025-09-20 16:00', 1, '',            'Online',  'Jane Doe', (SELECT category_id FROM Category WHERE name='Workshop')),
('AI in Healthcare',    '2025-10-01 09:00', '2025-10-01 17:00', 2, 'Talks',       'Toronto', 'Dr. Smith',(SELECT category_id FROM Category WHERE name='Conference')),
('Data Science 101',    '2025-09-25 18:00', '2025-09-25 20:00', 3, NULL,          'Zoom',    'Tech Org', (SELECT category_id FROM Category WHERE name='Webinar')),
('Cloud Summit',        '2025-11-10 09:00', '2025-11-12 17:00', 2, 'Multi-day',   NULL,      'Cloud Inc',(SELECT category_id FROM Category WHERE name='Conference'))
ON CONFLICT DO NOTHING;
```

#### `sql/10_queries/mp1a_queries.sql`  *(Week 3 – Part A suite)*

```sql
-- 1) INNER JOIN – items with categories
SELECT e.name AS item, c.name AS category, e.start_date, e.end_date
FROM Event e
JOIN Category c ON e.category_id = c.category_id;
-- Expect: all events with their category names

-- 2) LEFT JOIN – categories, even if no items
SELECT c.name AS category, e.name AS item
FROM Category c
LEFT JOIN Event e ON c.category_id = e.category_id
ORDER BY c.name, e.name NULLS LAST;
-- Expect: categories appear even if item is NULL

-- 3) Additional JOIN – INNER + predicate
SELECT e.name, e.location
FROM Event e
JOIN Category c ON e.category_id = c.category_id
WHERE c.name = 'Conference' AND COALESCE(e.location, '') <> '';
-- Expect: only conferences that have a location set

-- 4) WHERE Subquery – items belonging to a sub-selected category
SELECT name, start_date
FROM Event
WHERE category_id = (
  SELECT category_id FROM Category WHERE name = 'Workshop'
);
-- Expect: Workshop events

-- 5) SELECT Subquery (scalar) – count per category
SELECT c.name AS category,
       (SELECT COUNT(*) FROM Event e WHERE e.category_id = c.category_id) AS item_count
FROM Category c
ORDER BY item_count DESC, c.name;
-- Expect: one row per category with count

-- 6) Set Operation (UNION) – combine different domains
SELECT organizer AS name FROM Event WHERE organizer IS NOT NULL
UNION
SELECT name FROM Category;
-- Expect: unique list that contains all organizers + categories
```

#### `sql/20_aggregates/week5_aggregates.sql`  *(Week 5 – Aggregates & Windows)*

```sql
-- Aggregates: totals per category
SELECT c.name AS category, COUNT(e.event_id) AS total
FROM Category c
LEFT JOIN Event e ON e.category_id = c.category_id
GROUP BY c.name
HAVING COUNT(e.event_id) >= 0
ORDER BY total DESC, c.name;

-- Aggregates: avg & max duration (minutes)
SELECT c.name AS category,
       AVG(EXTRACT(EPOCH FROM (e.end_date - e.start_date))/60.0) AS avg_minutes,
       MAX(EXTRACT(EPOCH FROM (e.end_date - e.start_date))/60.0) AS max_minutes
FROM Category c
JOIN Event e ON e.category_id = c.category_id
GROUP BY c.name;

-- Window: rank categories by volume
SELECT category,
       total,
       RANK() OVER (ORDER BY total DESC) AS volume_rank
FROM (
  SELECT c.name AS category, COUNT(e.event_id) AS total
  FROM Category c
  LEFT JOIN Event e ON e.category_id = c.category_id
  GROUP BY c.name
) t;

-- Window: running count by start_date
SELECT e.name,
       e.start_date,
       COUNT(*) OVER (ORDER BY e.start_date) AS running_total
FROM Event e
ORDER BY e.start_date;

-- Window vs Aggregate comparison: value vs group avg (priority)
SELECT e.name,
       e.priority,
       AVG(e.priority) OVER (PARTITION BY e.category_id) AS avg_priority_in_cat
FROM Event e;
```

#### `sql/99_tests/mp1b_tests.sql`  *(Week 4 – Constraint tests)*

```sql
-- Expect failure: end_date before start_date
INSERT INTO Event (name, start_date, end_date, category_id)
VALUES ('Bad Dates', '2025-10-05 10:00', '2025-10-05 09:00',
        (SELECT category_id FROM Category LIMIT 1));

-- Expect failure: priority out of range
INSERT INTO Event (name, start_date, end_date, priority, category_id)
VALUES ('Bad Priority', '2025-10-06 10:00', '2025-10-06 12:00', 9,
        (SELECT category_id FROM Category LIMIT 1));
```

### G) Bring It All Up

From the project root:

```bash
docker compose up -d
# First startup will create DB and run /sql/00_init/*

# psql inside the container:
docker exec -it mp_db psql -U ${POSTGRES_USER} -d ${POSTGRES_DB}

# or use the Makefile:
make psql
```

### H) Run Your Suites (after first init)

```bash
# Week 3 (joins/subqueries)
docker exec -it mp_db psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -f /sql/10_queries/mp1a_queries.sql
# Week 5 (aggregates/windows)
docker exec -it mp_db psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -f /sql/20_aggregates/week5_aggregates.sql
# Week 4 (constraint tests; expect errors)
docker exec -it mp_db psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -f /sql/99_tests/mp1b_tests.sql
```

### I) Reset (to re-run all init scripts)

```bash
docker compose down -v   # removes the volume; data is gone
docker compose up -d     # re-creates DB and re-runs /sql/00_init/*
```

---

## 6) Deliverables

Upload a ZIP named:

```
studentid_course_MP-Docker_Postgres.zip
```

Containing:

* `.env` (use demo creds; OK for marking)
* `docker-compose.yml`
* `Makefile` (optional)
* `sql/00_init/01_schema.sql`
* `sql/00_init/02_constraints.sql`
* `sql/00_init/03_seed.sql`
* `sql/10_queries/mp1a_queries.sql`
* `sql/20_aggregates/week5_aggregates.sql`
* `sql/99_tests/mp1b_tests.sql`
* `README.md` with: how to run, expected outcomes, and brief notes on any deviations.

---

## 7) Reflection Questions (submit in README.md)

1. What advantages did Docker provide over installing PostgreSQL directly?
2. Which integrity rule caught real mistakes in your seed data?
3. For one of your window queries, explain **why a window** (not a plain aggregate) was the right tool.
4. If you had to productionize this, what would you change (backups, users/roles, secrets, CI)?

---

## 8) Assessment & Rubric (10 pts)

| Dimension                | 0–1               | 2                 | 3                              | Pts  |
| ------------------------ | ----------------- | ----------------- | ------------------------------ | ---- |
| **Environment (Docker)** | Fails to run      | Runs but brittle  | Clean, repeatable; reset works | __/3 |
| **Schema & Constraints** | Missing/incorrect | Partially correct | Correct; thoughtful checks     | __/2 |
| **Query Suites**         | Errors / off-spec | Meets minimum     | Clear, correct, well-commented | __/3 |
| **Reflection & README**  | Missing/vague     | Basic             | Insightful, actionable         | __/2 |

---

## 9) Submission Guidelines

* Test on a **fresh reset** before packaging (`docker compose down -v && docker compose up -d`).
* Ensure scripts run **without manual edits**.
* Keep credentials **demo-only** (no personal secrets).

---

## 10) Resources / Equipment

* Docker Desktop / Engine
* (Optional) pgAdmin at `http://localhost:${PGADMIN_PORT}`
* psql CLI inside container via `docker exec -it mp_db psql -U ${POSTGRES_USER} -d ${POSTGRES_DB}`

---

## 11) Academic Policies

Follow institutional policies on collaboration, citation, and originality. Put comments in SQL where you adapt examples.

---

## 12) Copyright Notice

© 2025 Your Institution / Instructor. For educational use.

---

