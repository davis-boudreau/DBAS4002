## **1. Assignment Details**

| Field              | Information                                         |
| ------------------ | --------------------------------------------------- |
| **Course Code**    | DBAS 4002                                           |
| **Course Name**    | Transactional Database Programming                  |
| **Workshop Title** | Workshop 08 – Automating Rules: Triggers & Auditing |
| **Type**           | Guided Workshop (Applied Lab + Reflection)          |
| **Instructor**     | Davis Boudreau                                      |
| **Stack Used**     | DBAS PostgreSQL DevOps Stack (v3.2)                 |
| **Duration**       | 1.5 hours                                             |
| **Version**        | 3.0 (Fall 2025)                                     |
| **Due Date**        | See Brightspace                                     |
---

## **2. Overview / Purpose / Objectives**

In this workshop, you will expand your database with **automated rules** that enforce consistency and log user actions automatically.
You’ll create **triggers** and **audit tables** using **PostgreSQL’s procedural language (PL/pgSQL)** inside your Dockerized environment.

**Purpose:**
This activity shows how modern databases enforce business rules automatically through triggers and transactional code — improving reliability, transparency, and data quality.

**Objectives:**

* Use the PostgreSQL `psql` shell to write and test SQL scripts.
* Create **BEFORE** and **AFTER** triggers for data integrity and auditing.
* Develop **audit tables** to record all user transactions.
* Demonstrate **idempotent operations** and rollback-safe transactions.
* Reflect on how triggers support transactional programming principles (ACID).

---

## **3. Learning Outcome Addressed**

**Outcome 2 – Manage transactions with DML + procedural code**

> Apply transactional principles (ACID) and procedural SQL to automate database operations safely and efficiently.

---

## **4. Workshop Context / Use Case**

You’re continuing to build your **Event Management System** within the **DBAS PostgreSQL DevOps Stack (v3.2)**.
The goal is to automatically:

1. Prevent duplicate event registrations.
2. Record any inserts, updates, or deletes in an **audit log table**.
3. Ensure rollback consistency (if something fails, no half-changes remain).

---

## **5. Tools Overview**

| Tool               | Purpose                                                                             |
| ------------------ | ----------------------------------------------------------------------------------- |
| **Docker Compose** | Runs your PostgreSQL and pgAdmin containers.                                        |
| **Makefile**       | Provides shortcut commands like `make up`, `make psql`, and `make reset`.           |
| **psql Shell**     | Command-line interface for interacting with PostgreSQL inside the Docker container. |
| **pgAdmin**        | Graphical interface to view tables and query results.                               |
| **SQL + PL/pgSQL** | The procedural scripting language used to define triggers and functions.            |

---

## **6. Step-by-Step Instructions**

### 🧭 Step 1 – Launch the Database Environment

**Tool:** Makefile + Docker Compose
Run this command in your project folder:

```bash
make up
```

This command:

* Starts the **PostgreSQL** container (`mp_db`)
* Starts **pgAdmin** (`mp_pgadmin`)
* Mounts your schema, seed data, and SQL scripts automatically

You can now connect using either:

* **pgAdmin** at `http://localhost:5050`, or
* The **psql shell** directly inside the PostgreSQL container.

---

### 🖥 Step 2 – Access the psql Shell

**Tool:** Makefile target → `make psql`

Run:

```bash
make psql
```

This command executes:

```bash
docker exec -it mp_db psql -U app_user -d event_db
```

You’ll enter the interactive PostgreSQL shell (prompt looks like this):

```
event_db=#
```

#### 🔹 Basic psql Commands

| Command            | Description                                         |
| ------------------ | --------------------------------------------------- |
| `\dt`              | List all tables in the current database.            |
| `\d table_name`    | Show table structure (columns, types, constraints). |
| `\q`               | Quit the psql shell.                                |
| `\c database_name` | Connect to another database.                        |
| `\l`               | List available databases.                           |
| `\! clear`         | Clears the screen (Unix-like systems).              |
| `\timing on`       | Enables query timing metrics.                       |

💡 **Tip:** Use the *arrow keys* to navigate command history or re-run commands.

---

### 🧱 Step 3 – Create an Audit Table

Inside the `psql` shell:

```sql
CREATE TABLE registration_audit (
  audit_id SERIAL PRIMARY KEY,
  event_id INT NOT NULL,
  participant_id INT NOT NULL,
  operation VARCHAR(10),
  executed_by TEXT DEFAULT CURRENT_USER,
  executed_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Explanation:**

* This table captures every insert, update, or delete from the `Registration` table.
* The `CURRENT_USER` and `CURRENT_TIMESTAMP` functions automatically log the actor and timestamp.

Use `\dt` to confirm the table exists.

---

### ⚙️ Step 4 – Write the Trigger Function

Still inside `psql`, create a **PL/pgSQL function** that writes to the audit log automatically:

```sql
CREATE OR REPLACE FUNCTION log_registration_changes() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    INSERT INTO registration_audit (event_id, participant_id, operation)
    VALUES (NEW.event_id, NEW.participant_id, 'INSERT');
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO registration_audit (event_id, participant_id, operation)
    VALUES (NEW.event_id, NEW.participant_id, 'UPDATE');
  ELSIF (TG_OP = 'DELETE') THEN
    INSERT INTO registration_audit (event_id, participant_id, operation)
    VALUES (OLD.event_id, OLD.participant_id, 'DELETE');
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

**Tool:** PostgreSQL procedural engine (PL/pgSQL)
**Purpose:** Automates audit record insertion after each DML operation.

You can verify it exists using:

```sql
\df log_registration_changes
```

---

### 🧩 Step 5 – Define BEFORE and AFTER Triggers

#### a) BEFORE Trigger – Prevent Duplicates

```sql
CREATE OR REPLACE FUNCTION prevent_duplicate_registration() RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM Registration 
    WHERE event_id = NEW.event_id AND participant_id = NEW.participant_id
  ) THEN
    RAISE NOTICE 'Duplicate registration ignored.';
    RETURN NULL;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_registration_insert
BEFORE INSERT ON Registration
FOR EACH ROW EXECUTE FUNCTION prevent_duplicate_registration();
```

#### b) AFTER Trigger – Record Changes

```sql
CREATE TRIGGER after_registration_audit
AFTER INSERT OR UPDATE OR DELETE ON Registration
FOR EACH ROW EXECUTE FUNCTION log_registration_changes();
```

**Tool:** PostgreSQL trigger engine
**Purpose:** BEFORE triggers *validate data*; AFTER triggers *log final actions*.

Check your triggers:

```sql
\dy
```

---

### 🧪 Step 6 – Test the Triggers

**Tool:** SQL transaction block inside `psql`

```sql
BEGIN;

INSERT INTO Registration (event_id, participant_id, payment_status)
VALUES (1, 3, 'Paid');

-- Duplicate test (ignored)
INSERT INTO Registration (event_id, participant_id, payment_status)
VALUES (1, 3, 'Paid');

UPDATE Registration SET payment_status = 'Cancelled' WHERE registration_id = 1;

DELETE FROM Registration WHERE registration_id = 2;

COMMIT;

SELECT * FROM registration_audit;
```

**Observation:**
Each successful operation should appear in `registration_audit`. The duplicate insert should trigger a **NOTICE** and skip insertion.

---

### 🔍 Step 7 – Test Rollback and Idempotency

```sql
BEGIN;
INSERT INTO Registration (event_id, participant_id, payment_status)
VALUES (1, 1, 'Paid');
ROLLBACK;

SELECT * FROM registration_audit;
```

The audit table should remain unchanged — demonstrating **atomicity** (A in ACID).
Even though the `INSERT` executed, the rollback canceled both the data and its log.

---

### 🧾 Step 8 – Document Your Work

Add **SQL comments** above each function and trigger:

```sql
-- BEFORE trigger to enforce unique registrations (idempotency)
-- AFTER trigger to record all changes for auditing
```

Then, in your reflection document or README:

> Describe how using the `psql` shell made you more aware of direct database-level control, compared to GUI tools like pgAdmin.

---

## **7. Deliverables**

Submit a single file:

```
Lastname_Firstname_WS08_Triggers_Audit.sql
```

including:

* Audit table
* Trigger functions
* BEFORE / AFTER trigger definitions
* Test queries and comments

---

## **8. Reflection Questions**

1. What are the advantages of running SQL directly in the `psql` shell?
2. How do BEFORE and AFTER triggers differ in execution flow?
3. Why is idempotency important for transactional safety?
4. How can you disable or drop a trigger when debugging?
5. How might auditing support compliance in enterprise systems?

---

## **9. Assessment Rubric (10 pts)**

| Criteria                   | Excellent (3)                    | Satisfactory (2) | Needs Improvement (1) | Pts     |
| -------------------------- | -------------------------------- | ---------------- | --------------------- | ------- |
| Trigger Logic              | Fully functional, correct syntax | Minor issues     | Incomplete            | __/3    |
| Audit Log                  | Comprehensive, accurate          | Partial          | Missing               | __/3    |
| Idempotency & Rollback     | Tested, correct output           | Limited tests    | Not shown             | __/2    |
| Documentation & Reflection | Clear and applied                | General          | Minimal               | __/2    |
| **Total**                  |                                  |                  |                       | **/10** |

---

## **10. Submission Guidelines**

* Complete and test inside **DBAS PostgreSQL DevOps Stack (v3.2)**
* Submit `.sql` file via Brightspace or GitHub
* Include your name, date, and course code in comments

---

## **11. Resources / Equipment**

* Docker Desktop or Linux Docker Engine
* DBAS PostgreSQL DevOps Stack (v3.2)
* PostgreSQL Docs → [https://www.postgresql.org/docs/current/plpgsql-trigger.html](https://www.postgresql.org/docs/current/plpgsql-trigger.html)
* pgAdmin Query Tool or CLI psql

---

## **12. Copyright**

© 2025 Nova Scotia Community College — For educational use only.
