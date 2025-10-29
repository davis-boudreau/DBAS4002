
````markdown
# 🐘 Dockerized PostgreSQL – Event Management Database

This project provides a reproducible **PostgreSQL 16 + pgAdmin 8** environment using **Docker Compose** and a **Makefile**.  
It hosts the **Event Management System** schema used in DBAS 3200 (Data-Driven App Programming) and DBAS 4002 (Transactional Database Programming).

---

## 🚀 Quick Start

```bash
# 1️⃣  Start or rebuild containers
make up

# 2️⃣  Connect to PostgreSQL inside the container
make psql

# 3️⃣  Run the Week 3 JOIN / subquery suite
make run-queries

# 4️⃣  Run the Week 5 aggregate / window suite
make run-aggregates

# 5️⃣  Reset everything (drops volume + rebuilds)
make reset
````

Then open **pgAdmin 4** in your browser:
👉 `http://localhost:5050`
Login with the credentials from the `.env` file.
You’ll see the connection **“Local PostgreSQL (EventDB)”** already registered via `pgadmin/servers.json`.

---

## 🧱 Project Structure

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
│  │  ├─ 01_schema.sql          # Event Management schema
│  │  ├─ 02_constraints.sql     # Integrity rules
│  │  ├─ 03_seed.sql            # Initial data
│  │  └─ 04_extensions.sql      # Optional PostgreSQL extensions
│  ├─ 10_queries/mp1a_queries.sql
│  ├─ 20_aggregates/week5_aggregates.sql
│  └─ 99_tests/mp1b_tests.sql
└─ README.md
```

---

## 🔐 Environment Variables (`.env`)

| Variable                   | Purpose              | Default Value              |
| -------------------------- | -------------------- | -------------------------- |
| `POSTGRES_USER`            | DB username          | `"app_user"`               |
| `POSTGRES_PASSWORD`        | DB password          | `"app_password"`           |
| `POSTGRES_DB`              | Default database     | `"event_db"`               |
| `PGPORT`                   | Exposed DB port      | `5432`                     |
| `PGADMIN_PORT`             | pgAdmin port         | `5050`                     |
| `PGADMIN_DEFAULT_EMAIL`    | pgAdmin login email  | `"admin@example.com"`      |
| `PGADMIN_DEFAULT_PASSWORD` | pgAdmin password     | `"adminpass"`              |
| `PGDATA`                   | Internal data volume | `/var/lib/postgresql/data` |

---

## 🧩 Schema Overview

| Table            | Description                               | Key Columns                                                       |
| ---------------- | ----------------------------------------- | ----------------------------------------------------------------- |
| **Category**     | Event categories                          | `category_id`, `name`                                             |
| **Event**        | Individual events / sessions              | `event_id`, `category_id`, `start_date`, `end_date`, `priority`   |
| **Participant**  | Registered individuals                    | `participant_id`, `email`                                         |
| **Registration** | Event ↔ Participant link + payment status | `registration_id`, `event_id`, `participant_id`, `payment_status` |

---

## 🧠 Developer Workflows

### 🧰 Rebuild Clean Environment

```bash
make reset
```

### 🧪 Run Specific Query Files

```bash
make run-queries      # Week 3 joins / subqueries
make run-aggregates   # Week 5 aggregates / windows
make run-tests        # Validation scripts
```

### 🧹 Stop and Clean Up

```bash
make down     # stop containers, keep data
make clean    # remove unused Docker resources
```

---

## 🧑‍💻 Developer Notes & Best Practices

* **Line Endings (LF)** – Always use LF (`\n`) in SQL and Makefile files for Linux compatibility.
* **.env Separation** – Never commit passwords or credentials in code. `.env` is git-ignored.
* **Volumes vs Images** – `pgdata/` is mapped for persistence; run `make reset` to start fresh.
* **Health Checks** – The `pg_isready` check ensures PostgreSQL is up before pgAdmin connects.
* **Script Ordering** – Files in `sql/00_init/` run alphabetically ⇒ schema → constraints → seed.
* **Testing Integrity** – Use `sql/99_tests/mp1b_tests.sql` for constraint and rollback validation.
* **Version Control Hygiene** – Confirm `.gitignore` and `.dockerignore` exclude logs, data volumes, and .env.
* **Port Conflicts** – If port 5432 or 5050 is in use, update values in `.env` and re-run `make up`.
* **Logging** – Run `docker logs mp_db --tail 50 -f` to watch database startup or error messages.
* **SQL Linting** – Tools like `sqlfluff` or `pgformatter` help maintain consistent style.
* **Schema Migrations** – Later modules (DBAS 4002) will extend this setup with Flyway or Alembic concepts.

---

## 🧭 Troubleshooting Tips

| Issue                                   | Possible Cause                 | Fix                                       |
| --------------------------------------- | ------------------------------ | ----------------------------------------- |
| `FATAL: password authentication failed` | `.env` not sourced or mismatch | `make reset` and verify credentials       |
| `port 5432 already in use`              | Local Postgres installed       | Edit `.env` → change `PGPORT` → `make up` |
| `pgAdmin cannot connect`                | DB container not healthy       | Wait ~15 s or run `docker logs mp_db`     |
| `Permission denied` on Windows          | File-system mount permissions  | Run Docker Desktop as Administrator       |

---

## 🧮 Future Extensions

* Add **stored procedures & triggers** (DBAS 4002 Workshops 6–8).
* Introduce **transactional tests** using `SAVEPOINT` and `ROLLBACK`.
* Integrate **performance profiling** (EXPLAIN / ANALYZE scripts).
* Implement **GitHub Actions CI** to run SQL lint + health tests on push.

---

## 📘 References

* PostgreSQL Documentation → [https://www.postgresql.org/docs/](https://www.postgresql.org/docs/)
* Docker Compose Reference → [https://docs.docker.com/compose/](https://docs.docker.com/compose/)
* pgAdmin User Guide → [https://www.pgadmin.org/docs/pgadmin4/latest/](https://www.pgadmin.org/docs/pgadmin4/latest/)

---

**© 2025 Nova Scotia Community College — For educational use only.**
