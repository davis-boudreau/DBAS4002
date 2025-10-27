![alt text](image.png)

---


## 1) Assignment Details

| Field                   | Information                                            |
| ----------------------- | ------------------------------------------------------ |
| **Course Code**         | DBAS 4002                                              |
| **Assignment Title**    | Transactions Stack — PostgreSQL + pgAdmin (Dockerized) |
| **Type**                | Skill Build / Environment Setup (Individual)           |
| **Version**             | 1.0                                                    |
| **Estimated Time**      | 4–6 hours initial setup & labs                         |
| **Weight**              | (suggested) 10%                                        |
| **Pre-Reqs (expanded)** | See below                                              |

---

## 2) Overview / Purpose / Objectives

### Purpose

Stand up a **clean, reproducible** PostgreSQL environment—complete with **pgAdmin**—to **observe and experiment with transactions**. You’ll run SQL labs covering **ACID**, **isolation levels**, **MVCC**, **locks**, **deadlocks**, **savepoints**, and **recovery**.

### Why this matters

Transaction behavior is where theory meets production reality. A controlled Docker stack lets you **reproduce anomalies**, **isolate effects**, **inspect locks**, and **practice safe recovery**—skills you’ll use in real systems.

### Objectives

1. Run PostgreSQL + pgAdmin via Docker Compose with persistent volumes.
2. Use `.env` for safe, configurable credentials & ports.
3. Execute SQL labs for ACID, isolation, locking, deadlocks, and recovery.
4. Use **Makefile** shortcuts for psql access, seeding, backup, restore.
5. Analyze outcomes and explain **why** they occur (reflection).

---

## 3) Learning Outcomes Addressed

* Configure & operate a transactional RDBMS in containers.
* Distinguish isolation levels & anomalies with hands-on experiments.
* Inspect locks/MVCC and resolve deadlocks.
* Perform consistent backup/restore procedures.

---

## 4) Pre-Requisites (expanded)

* **SQL proficiency:** DDL/DML, constraints, indexing.
* **Transactions:** BEGIN/COMMIT/ROLLBACK, SAVEPOINT.
* **CLI basics:** shell commands, file paths, environment variables.
* **Docker & Compose:** images/containers/volumes, `docker compose up`.
* **Security hygiene:** never commit secrets—use `.env`, `.gitignore`.

---

## 5) What You’ll Build

A two-service stack:

* **db**: `postgres:16` with a **persistent volume** and **init scripts** (schemas + seed data + demo labs).
* **pgadmin**: `dpage/pgadmin4` for GUI exploration; auto-registers the DB with a mounted `servers.json`.

You’ll have:

* **psql** one-liners via Makefile
* **Seed scripts** for accounts/transactions
* **Lab scripts** that demonstrate isolation & locking
* **Backup/restore** commands

---

## 6) Files to Create (copy–paste ready)

### 6.1 `.env`  (do **not** commit real secrets)

```env
# PostgreSQL
POSTGRES_DB=txlab
POSTGRES_USER=txadmin
POSTGRES_PASSWORD=txpass123
POSTGRES_PORT=5432
POSTGRES_HOST=db

# pgAdmin
PGADMIN_DEFAULT_EMAIL=admin@example.com
PGADMIN_DEFAULT_PASSWORD=admin123
PGADMIN_PORT=5050

# Backup dir (host)
BACKUP_DIR=backups
```

### 6.2 `.gitignore`

```gitignore
# Python/cache
__pycache__/
*.pyc
*.pyo

# Environment & editor
.env
.vscode/
.idea/
.DS_Store

# DB & dumps
backups/
pgadmin_data/
```

### 6.3 `.dockerignore`

```dockerignore
.env
backups/
pgadmin_data/
.vscode/
.idea/
.DS_Store
```

### 6.4 `docker-compose.yml`

```yaml
services:
  db:
    image: postgres:16
    container_name: tx_db
    env_file: .env
    ports:
      - "${POSTGRES_PORT}:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data
      - ./initdb:/docker-entrypoint-initdb.d:ro
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      interval: 5s
      timeout: 3s
      retries: 10

  pgadmin:
    image: dpage/pgadmin4:8
    container_name: tx_pgadmin
    env_file: .env
    ports:
      - "${PGADMIN_PORT}:80"
    volumes:
      - pgadmin_data:/var/lib/pgadmin
      - ./pgadmin/servers.json:/pgadmin4/servers.json:ro
    depends_on:
      db:
        condition: service_healthy

volumes:
  pgdata:
  pgadmin_data:
```

### 6.5 `Makefile`  (loads `.env`, adds handy targets)

```make
include .env
export $(shell sed 's/=.*//' .env)

.PHONY: up down logs ps psql seed backup restore clean status

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f

ps:
	docker compose ps

status:
	docker compose ps && echo && docker compose logs --tail=20 db

psql:
	docker compose exec db psql -U $(POSTGRES_USER) -d $(POSTGRES_DB)

seed:
	# Re-run lab scripts (idempotent where possible)
	docker compose exec -T db psql -U $(POSTGRES_USER) -d $(POSTGRES_DB) -f /docker-entrypoint-initdb.d/03_demo_tx.sql

backup:
	mkdir -p $(BACKUP_DIR)
	docker compose exec -T db pg_dump -U $(POSTGRES_USER) -d $(POSTGRES_DB) > $(BACKUP_DIR)/txlab_dump.sql
	@echo "Backup written to $(BACKUP_DIR)/txlab_dump.sql"

restore:
	test -f $(BACKUP_DIR)/txlab_dump.sql
	docker compose exec -T db psql -U $(POSTGRES_USER) -d $(POSTGRES_DB) < $(BACKUP_DIR)/txlab_dump.sql

clean:
	docker compose down -v --remove-orphans
```

### 6.6 `pgadmin/servers.json`

(Auto-registers your DB in pgAdmin → Servers > txlab)

```json
{
  "Servers": {
    "1": {
      "Name": "txlab",
      "Group": "DBAS4002",
      "Port": 5432,
      "Username": "txadmin",
      "Host": "db",
      "SSLMode": "prefer",
      "MaintenanceDB": "postgres"
    }
  }
}
```

### 6.7 SQL init & lab scripts

Create a folder **`initdb/`** with three files:

#### `initdb/01_schema.sql`

```sql
-- Accounts & ledger-style transactions to explore ACID and isolation
CREATE SCHEMA IF NOT EXISTS banking;

CREATE TABLE IF NOT EXISTS banking.accounts (
  account_id SERIAL PRIMARY KEY,
  owner TEXT NOT NULL,
  balance NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (balance >= 0)
);

CREATE TABLE IF NOT EXISTS banking.txn (
  txn_id BIGSERIAL PRIMARY KEY,
  from_account INT REFERENCES banking.accounts(account_id),
  to_account   INT REFERENCES banking.accounts(account_id),
  amount NUMERIC(12,2) NOT NULL CHECK (amount > 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  note TEXT
);

-- Transfer function with explicit transaction semantics (demo only)
CREATE OR REPLACE FUNCTION banking.transfer(p_from INT, p_to INT, p_amount NUMERIC)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
  -- withdraw
  UPDATE banking.accounts
  SET balance = balance - p_amount
  WHERE account_id = p_from;

  -- deposit
  UPDATE banking.accounts
  SET balance = balance + p_amount
  WHERE account_id = p_to;

  INSERT INTO banking.txn(from_account, to_account, amount, note)
  VALUES (p_from, p_to, p_amount, 'demo transfer');
END;
$$;
```

#### `initdb/02_seed.sql`

```sql
INSERT INTO banking.accounts(owner, balance) VALUES
  ('Alice', 1000.00),
  ('Bob',    500.00),
  ('Carol',  250.00)
ON CONFLICT DO NOTHING;
```

#### `initdb/03_demo_tx.sql`

```sql
-- Isolation level demos & lock inspection helpers

-- Helpers: show active locks for our schema
CREATE OR REPLACE VIEW banking.locks AS
SELECT
  l.locktype, l.mode, l.granted,
  l.relation::regclass AS relation,
  a.usename, a.pid, a.state, a.query
FROM pg_locks l
JOIN pg_stat_activity a ON l.pid = a.pid
WHERE a.query NOT ILIKE '%pg_locks%'
ORDER BY a.pid;

-- Demo: Read phenomena at READ COMMITTED vs REPEATABLE READ
-- Session A:
--   BEGIN;
--   SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
--   SELECT balance FROM banking.accounts WHERE owner='Alice'; -- A1
-- Session B:
--   BEGIN;
--   UPDATE banking.accounts SET balance = balance + 100 WHERE owner='Alice';
--   COMMIT;
-- Session A:
--   SELECT balance FROM banking.accounts WHERE owner='Alice'; -- A2 (may see new value at READ COMMITTED)
--   ROLLBACK;

-- Deadlock demo (run in two sessions):
-- Session 1:
--   BEGIN;
--   UPDATE banking.accounts SET balance = balance + 10 WHERE owner='Alice'; -- lock row A
--   SELECT * FROM banking.locks;
--   -- then try to lock Bob
--   UPDATE banking.accounts SET balance = balance + 10 WHERE owner='Bob';

-- Session 2:
--   BEGIN;
--   UPDATE banking.accounts SET balance = balance + 10 WHERE owner='Bob';   -- lock row B
--   -- then try to lock Alice
--   UPDATE banking.accounts SET balance = balance + 10 WHERE owner='Alice';
--   -- one session will deadlock and be aborted by PG

-- Serializable anomaly prevention demo:
-- In two sessions under SERIALIZABLE, try interleaved transfers and see serialization failures.
```

---

## 7) How to Run

1. **Start the stack**

```bash
make up
```

* Postgres: `localhost:${POSTGRES_PORT}` (default 5432)
* pgAdmin:  `http://localhost:${PGADMIN_PORT}` (default 5050)

  * Login with `PGADMIN_DEFAULT_EMAIL` / `PGADMIN_DEFAULT_PASSWORD`
  * You’ll see **Servers → DBAS4002 → txlab**

2. **Open a psql shell**

```bash
make psql
```

3. **Re-run lab script anytime**

```bash
make seed
```

4. **Backup & Restore**

```bash
make backup
make restore
```

5. **Stop & clean**

```bash
make down
# or to remove volumes:
make clean
```

---

## 8) Suggested Lab Flow (What / Why / How)

### Lab 1 — ACID basics

* **What:** Practice `BEGIN`, `COMMIT`, `ROLLBACK`, `SAVEPOINT`.
* **Why:** Internalize atomicity & durability.
* **How:** Use `make psql`, manually transfer balances, rollback, inspect results.

### Lab 2 — Isolation levels & read phenomena

* **What:** Compare `READ COMMITTED`, `REPEATABLE READ`, `SERIALIZABLE`.
* **Why:** Predict anomalies (non-repeatable reads, phantom reads) and how PG prevents them.
* **How:** Follow comments in `03_demo_tx.sql` with two psql sessions.

### Lab 3 — Locks & deadlocks

* **What:** Create a circular wait using two sessions.
* **Why:** Recognize how deadlocks happen and how PG resolves them.
* **How:** Run the “Deadlock demo” in `03_demo_tx.sql`; query `banking.locks`.

### Lab 4 — Backups & recovery

* **What:** Use `pg_dump` and restore to last known good state.
* **Why:** Safety and repeatability for production workflows.
* **How:** `make backup` → break data → `make restore`.

---

## 9) Final Folder Structure

```
transactions-stack/
├─ .env
├─ .gitignore
├─ .dockerignore
├─ docker-compose.yml
├─ Makefile
├─ initdb/
│  ├─ 01_schema.sql
│  ├─ 02_seed.sql
│  └─ 03_demo_tx.sql
├─ pgadmin/
│  └─ servers.json
└─ backups/            # created by Makefile (ignored by git)
```

---

## 10) Reflection (short answers, 150–250 words total)

1. **Isolation trade-offs:** When would you choose `REPEATABLE READ` vs `SERIALIZABLE`, and why?
2. **MVCC insight:** How does MVCC allow concurrent readers/writers while minimizing blocking?
3. **Deadlock handling:** What coding or schema strategies reduce deadlock risk?
4. **Durability practices:** Beyond `pg_dump`, what safeguards (WAL, PITR, replicas) matter in prod?
5. **Operational habit:** Which Makefile targets will you rely on most and why?

---

## 11) Assessment & Rubric (10 pts)

| Criterion          | A (Exceeds)                                                           | B (Meets)           | C (Developing) | 0       |
| ------------------ | --------------------------------------------------------------------- | ------------------- | -------------- | ------- |
| Environment (3)    | pg + pgAdmin healthy; volumes & servers.json work; Make targets clean | Mostly works        | Partial        | Missing |
| Labs (3)           | Runs & documents all demos; correct observations                      | Runs most demos     | Limited        | Missing |
| SQL Quality (2)    | Clear, repeatable scripts; safe constraints                           | Mostly correct      | Some issues    | Missing |
| Backup/Restore (1) | Demonstrates both correctly                                           | One direction works | Incomplete     | Missing |
| Reflection (1)     | Insightful, technically sound                                         | Adequate            | Superficial    | Missing |

---

## 12) Tips & Background (quick hits)

* **Autocommit:** psql defaults to autocommit **off** within `BEGIN`. Be explicit.
* **Visibility:** At `READ COMMITTED`, each statement sees the latest committed row versions; at `REPEATABLE READ`, a transaction sees a consistent snapshot; `SERIALIZABLE` may abort to prevent anomalies.
* **Lock scope:** Row-level updates lock only touched rows; **ordering updates consistently** helps avoid deadlocks.
* **Backups:** Text dumps are portable and diff-friendly; for large DBs, also learn **PITR** with base backups + WAL.
