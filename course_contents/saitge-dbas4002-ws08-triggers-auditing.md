![alt text](image.png)

---

## **1. Assignment Details**

| Field              | Information                                         |
| ------------------ | --------------------------------------------------- |
| **Course Code**    | DBAS 4002                                           |
| **Course Name**    | Transactional Database Programming                  |
| **Workshop Title** | Workshop 08 – Automating Rules: Triggers & Auditing |
| **Type**           | Guided Workshop (Hands-on Lab + Reflection)         |
| **Instructor**     | Davis Boudreau                                      |
| **Stack Used**     | DBAS PostgreSQL DevOps Stack (v3.2)                 |
| **Duration**       | 3 hours                                             |
| **Version**        | 3.0 (Fall 2025)                                     |

---

## **2. Overview / Purpose / Objectives**

### **Conceptual Framing**

In modern database systems, **consistency and integrity** are paramount. As data models grow complex, enforcing business rules through application code alone becomes risky and error-prone.
**Database triggers** offer a declarative mechanism to automate these rules *at the database layer*, ensuring reliability across all client applications — whether written in Python, Django, or web APIs.

PostgreSQL’s procedural language (**PL/pgSQL**) provides the tools to build reactive systems that “listen” to table events and act accordingly.
This workshop situates triggers within the broader context of **transactional automation, auditing, and idempotency** — foundational to banking, ERP, and event-driven systems.

---

### **Purpose**

This lab introduces you to the practical design of **BEFORE** and **AFTER** triggers — small, event-driven routines that execute automatically in response to data modifications.
You’ll build, test, and reflect on trigger-based automation using your existing **Event Management System** schema in the Dockerized PostgreSQL DevOps Stack (v3.2).

### **Objectives**

* Understand triggers as *transactional automation tools* in relational databases.
* Implement **BEFORE** triggers for rule enforcement (e.g., preventing duplicates).
* Implement **AFTER** triggers for logging and auditing.
* Demonstrate **idempotent** operations and rollback-safe logic.
* Interpret trigger behaviour through **ACID properties** (atomicity, consistency, isolation, durability).
* Document, test, and reflect on their real-world applications.

---

## **3. Learning Outcome Addressed**

**Outcome 2 – Manage transactions with DML + procedural code**

> Apply transactional concepts, ACID control, and procedural SQL to automate business logic and safeguard data integrity.

---

## **4. Workshop Context / Use Case**

In your **Event Management System**, users register for workshops, seminars, and training sessions.
To support auditability and accountability, you’ve been asked to **automatically log all registration changes** — who made them, when, and what kind of operation occurred.

This mirrors real-world compliance requirements in sectors like:

* **Finance:** Regulatory audits of account changes.
* **Healthcare:** Logging access to patient data (HIPAA compliance).
* **Education:** Tracking grade or registration modifications.

Your task:

1. Enforce *business rules* (no duplicate registrations).
2. *Record* all changes to a new audit table.
3. *Test* rollback safety and idempotency.

---

## **5. Tools Overview**

| Tool               | Purpose                                                                 |
| ------------------ | ----------------------------------------------------------------------- |
| **Docker Compose** | Launch PostgreSQL and pgAdmin in isolated containers.                   |
| **Makefile**       | Simplifies environment commands (`make up`, `make psql`, `make reset`). |
| **psql Shell**     | Direct SQL execution and debugging inside the running container.        |
| **pgAdmin**        | GUI-based inspection and visualization of results.                      |
| **PL/pgSQL**       | PostgreSQL’s procedural language for triggers and stored logic.         |

---

## **6. Step-by-Step Workshop Instructions**

---

### 🧭 Step 1 – Launch Your Environment

**Tool:** Makefile + Docker Compose

```bash
make up
make psql
```

This command:

* Spins up your **PostgreSQL container** (`mp_db`) and **pgAdmin** (`mp_pgadmin`).
* Mounts your SQL scripts (`/sql`) for access within the container.
* Connects you to the `event_db` as `app_user` via `psql`.

💡 *Confirm connection:*

```sql
\conninfo
```

Use `\dt` to list all tables and verify `event`, `registration`, and `participant` exist.

---

### 💡 Conceptual Note: Why Use psql?

The `psql` shell gives you **fine-grained, script-level control** over your database environment — ideal for working with procedural and transactional code.
Unlike GUI tools, `psql` allows you to:

* Run and time scripts (`\timing on`).
* Use transaction blocks (`BEGIN; … COMMIT;`).
* Debug triggers in context using immediate feedback.

---

### 🧱 Step 2 – Create an Audit Log Table

**Conceptual Background:**
Auditing is a cornerstone of **durability** and **traceability** in ACID systems.
An audit table captures “who, what, when” for every DML operation, independent of the user interface.

**SQL Implementation:**

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

Run:

```sql
\dt registration_audit
```

✅ You now have a dedicated logging mechanism to store future trigger-based inserts.

---

### ⚙️ Step 3 – Write the Trigger Function

**Conceptual Background:**
Triggers rely on **trigger functions** — special PL/pgSQL routines that execute whenever the trigger fires.
They can:

* Access “virtual records” via `NEW` (after insert/update) and `OLD` (before delete).
* Decide whether to allow (`RETURN NEW`) or skip (`RETURN NULL`) an operation.
* Cascade side-effects such as logging or validation.

**SQL Implementation:**

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

💡 *`TG_OP`* is a built-in trigger variable that tells you what kind of DML operation occurred.

---

### 🧩 Step 4 – Attach BEFORE and AFTER Triggers

**Conceptual Background:**
Triggers come in two main timing categories:

| Timing     | Purpose                                      | Typical Use                   |
| ---------- | -------------------------------------------- | ----------------------------- |
| **BEFORE** | Validate or modify data *before* insertion   | Enforce constraints, defaults |
| **AFTER**  | Log or cascade actions *after* data is saved | Auditing, notifications       |

**SQL Implementation:**

```sql
-- BEFORE trigger: Prevent duplicate registrations
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

-- AFTER trigger: Log all data changes
CREATE TRIGGER after_registration_audit
AFTER INSERT OR UPDATE OR DELETE ON Registration
FOR EACH ROW EXECUTE FUNCTION log_registration_changes();
```

💡 **Concept Check:**

* The BEFORE trigger enforces *idempotency* (repeated requests don’t create duplicates).
* The AFTER trigger enforces *durability* (every change is logged).

---

### 🧪 Step 5 – Test and Inspect Triggers

**Conceptual Background:**
Testing triggers validates their transactional behaviour — they should fire automatically, without manual intervention.

```sql
BEGIN;

INSERT INTO Registration (event_id, participant_id, payment_status)
VALUES (1, 3, 'Paid');

-- Duplicate insert (should trigger BEFORE logic)
INSERT INTO Registration (event_id, participant_id, payment_status)
VALUES (1, 3, 'Paid');

UPDATE Registration
SET payment_status = 'Cancelled'
WHERE event_id = 1 AND participant_id = 3;

DELETE FROM Registration WHERE registration_id = 2;

COMMIT;
```

Inspect:

```sql
SELECT * FROM registration_audit ORDER BY audit_id;
```

You should see entries for INSERT, UPDATE, and DELETE actions.

---

### 🔎 Inspecting Trigger Metadata

Run:

```sql
\d public.registration
```

to see:

```
Triggers:
    before_registration_insert BEFORE INSERT ON registration FOR EACH ROW EXECUTE FUNCTION prevent_duplicate_registration()
    after_registration_audit AFTER INSERT OR UPDATE OR DELETE ON registration FOR EACH ROW EXECUTE FUNCTION log_registration_changes()
```

🔔 **What Makes Event Triggers Different?**
Unlike regular table triggers (which respond to **DML** like INSERT, UPDATE, DELETE),
**event triggers** respond to **DDL** — changes in database structure.

🧠 **Use Cases for Event Triggers**

* Auditing schema changes (who altered a table or constraint).
* Enforcing policies (prevent unauthorized schema modifications).
* Automated actions (run scripts or checks on `CREATE TABLE` or `ALTER DATABASE`).

---

### 🔁 Step 6 – Test Rollback and Idempotency

```sql
BEGIN;
INSERT INTO Registration (event_id, participant_id, payment_status)
VALUES (1, 1, 'Paid');
ROLLBACK;

SELECT * FROM registration_audit;
```

No audit rows should appear — verifying **atomicity**.
If the transaction rolls back, the trigger’s effects are undone automatically.

---

### 📘 Step 7 – Document & Reflect

Add comments:

```sql
-- BEFORE trigger ensures unique participant registrations per event
-- AFTER trigger logs all modifications for auditing and compliance
-- Triggers tested for rollback safety (no audit data persisted)
```

In your reflection document:

> Discuss how triggers reduce code duplication and increase system reliability in multi-tier applications.

---

## **7. Deliverables**

Submit:

```
Lastname_Firstname_WS08_Triggers_Audit.sql
```

containing:

* Trigger functions
* Trigger definitions
* Test queries and comments
* Reflection section

---

## **8. Reflection Questions**

1. How do triggers enhance data integrity beyond application-level validation?
2. Why is idempotency essential in transactional systems?
3. How do ACID properties manifest in trigger behaviour?
4. What are real-world risks of overusing triggers?
5. How could these techniques apply to financial or audit-critical systems?

---

## **9. Assessment & Rubric (10 pts)**

| Criteria               | Excellent (3)                     | Satisfactory (2) | Needs Improvement (1) | Pts     |
| ---------------------- | --------------------------------- | ---------------- | --------------------- | ------- |
| Trigger Logic          | Accurate, efficient, and reusable | Minor errors     | Incorrect logic       | __/3    |
| Audit Implementation   | Comprehensive logging             | Partial coverage | Missing or failing    | __/3    |
| Idempotency & Rollback | Demonstrated and documented       | Limited tests    | Not shown             | __/2    |
| Reflection             | Clear, insightful application     | Generic comments | Missing               | __/2    |
| **Total**              |                                   |                  |                       | **/10** |

---

## **10. Submission Guidelines**

* Test all SQL in the **DBAS PostgreSQL DevOps Stack (v3.2)**.
* Include `\dt`, `\df`, and test output snippets as comments.
* Submit via Brightspace or GitHub.

---

## **11. Resources / Equipment**

* DBAS PostgreSQL DevOps Stack (v3.2)
* PostgreSQL Trigger Documentation → [https://www.postgresql.org/docs/current/triggers.html](https://www.postgresql.org/docs/current/triggers.html)
* Docker Desktop / Compose
* pgAdmin Query Tool

---

## **12. Copyright**

© 2025 Nova Scotia Community College — For educational use only.
