![alt text](image.png)

---

## **1. Assignment Details**

| Field              | Information                                        |
| ------------------ | -------------------------------------------------- |
| **Course Code**    | DBAS 4002                                          |
| **Course Name**    | Transactional Database Programming                 |
| **Workshop Title** | Workshop 07 – Transaction Control & Error Handling |
| **Type**           | Guided Workshop (Applied Lab + Reflection)         |
| **Instructor**     | Davis Boudreau                                     |
| **Stack Used**     | DBAS PostgreSQL DevOps Stack (v3.2)                |
| **Duration**       | 3 hours                                            |
| **Version**        | 2.0 (Fall 2025)                                    |

---

## **2. Overview / Purpose / Objectives**

### **Conceptual Framing**

Transactional systems form the **core of enterprise data integrity**. Every financial transfer, booking, or registration depends on reliable, atomic operations that *either complete fully or roll back entirely*.
This workshop moves students from writing SQL statements to managing **multi-statement logic within transaction boundaries**, exploring how **PostgreSQL ensures ACID compliance** through commit control, savepoints, and exception handling.

Students will work entirely inside their **Dockerized PostgreSQL environment**, gaining a realistic understanding of how developers protect data from partial failure and maintain business consistency.

---

### **Purpose**

Students will learn to:

* Manage transactions using `BEGIN`, `COMMIT`, and `ROLLBACK`.
* Use `SAVEPOINT` and `ROLLBACK TO` for nested control.
* Handle errors gracefully with `EXCEPTION` blocks in PL/pgSQL.
* Simulate concurrent or failed operations to observe recovery.
* Apply best practices for **idempotent, rollback-safe procedures**.

---

### **Learning Outcomes Addressed**

**Outcome 2 – Manage transactions with DML + procedural code**

> Apply transactional concepts, ACID control, and error handling to safeguard data integrity.

---

## **3. Workshop Context**

Your Event Management System is now handling hundreds of registrations. Occasionally, two users attempt to register the same participant for the same event simultaneously, or a network issue interrupts a payment update.
This lab simulates such scenarios to help you understand **how PostgreSQL prevents corruption** through its **transaction manager**.

Real-world equivalents include:

* Online registration systems ensuring seats are not oversold.
* Financial transfers preventing double withdrawals.
* Order systems maintaining consistent stock levels during checkout.

---

## **4. Background Concepts**

| Concept              | Explanation                                                                             |
| -------------------- | --------------------------------------------------------------------------------------- |
| **Transaction**      | A logical unit of work that must be executed fully or not at all.                       |
| **ACID**             | Atomicity, Consistency, Isolation, Durability — the foundation of database reliability. |
| **Isolation Levels** | Control how visible uncommitted data is to other sessions.                              |
| **Error Handling**   | Catching and managing run-time exceptions using `EXCEPTION` blocks.                     |
| **Idempotency**      | Guaranteeing that re-running a transaction produces no adverse side-effects.            |

---

## **5. Tools Overview**

| Tool                          | Role                                                           |
| ----------------------------- | -------------------------------------------------------------- |
| **Docker Compose + Makefile** | Starts the PostgreSQL + pgAdmin environment (`make up`).       |
| **psql Shell**                | Executes transactional SQL and procedural blocks.              |
| **pgAdmin**                   | Used to visualize tables and logs post-execution.              |
| **/sql directory**            | Stores re-usable scripts for running and testing transactions. |

---

## **6. Step-by-Step Workshop Instructions**

---

### 🧭 Step 1 – Start Environment and Connect

```bash
make up
make psql
```

Confirm connection:

```sql
\conninfo
```

Turn on timing:

```sql
\timing on
```

You’ll execute every step inside an **active `psql` session** within the container.

---

### ⚙️ Step 2 – Create a Safe Test Table

We’ll isolate this exercise from production data:

```sql
CREATE TABLE IF NOT EXISTS transaction_demo (
  demo_id SERIAL PRIMARY KEY,
  step_name TEXT,
  note TEXT
);
```

Confirm creation:

```sql
\dt transaction_demo
```

---

### 🧱 Step 3 – Basic Transaction Control

A transaction groups several operations into an **atomic** unit:

```sql
BEGIN;

INSERT INTO transaction_demo (step_name, note)
VALUES ('Step 1', 'Start operation');

INSERT INTO transaction_demo (step_name, note)
VALUES ('Step 2', 'Intermediate step');

-- simulate an issue:
-- SELECT 1/0;

COMMIT;
```

💡 If you uncomment the divide-by-zero line, PostgreSQL will automatically roll back the entire transaction — proving **atomicity**.

---

### 🧩 Step 4 – Using SAVEPOINTS

`SAVEPOINT` allows recovery to an intermediate stage:

```sql
BEGIN;

INSERT INTO transaction_demo (step_name, note)
VALUES ('Outer', 'Before savepoint');

SAVEPOINT midway;

INSERT INTO transaction_demo (step_name, note)
VALUES ('Inner', 'Inside savepoint');

-- oops! simulate a failed insert:
INSERT INTO transaction_demo (demo_id, step_name, note)
VALUES (1, 'Duplicate PK', 'Forcing error');

ROLLBACK TO midway;  -- undo only the failed insert
COMMIT;
```

✅ Only rows before the savepoint remain — showing *partial rollback control*.

---

### 🔄 Step 5 – Error Handling with EXCEPTION Blocks

**Conceptual Context:**
Procedural blocks in PostgreSQL can catch runtime exceptions. This enables logging, retry logic, or graceful degradation.

```sql
DO $$
BEGIN
  BEGIN
    INSERT INTO transaction_demo (step_name, note)
    VALUES ('Risky Insert', 'May violate constraint');

  EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'Duplicate key detected – operation skipped safely.';
  END;
END $$;
```

This demonstrates **idempotency**: the same command can re-run without harm.

---

### 🧠 Step 6 – Testing Atomicity in the Event System

Simulate a real registration transaction:

```sql
BEGIN;

-- deduct seat count (hypothetical column)
UPDATE event
SET priority = priority - 1
WHERE event_id = 1;

-- add registration
INSERT INTO registration (event_id, participant_id, payment_status)
VALUES (1, 10, 'Paid');

-- simulate failure
INSERT INTO registration (event_id, participant_id, payment_status)
VALUES (1, 10, 'Paid');  -- duplicate

COMMIT;
```

💡 You’ll see an error and an implicit rollback — no seat count decremented, no partial insert.

---

### 🔍 Step 7 – Validate Consistency and Isolation

In `psql` (Session 1):

```sql
BEGIN;
UPDATE event SET priority = 5 WHERE event_id = 2;
-- leave transaction open
```

In a **second session** (`make psql` again):

```sql
SELECT priority FROM event WHERE event_id = 2;
```

You’ll observe that changes are invisible until the first session **commits** — illustrating **isolation**.

---

### 🧾 Step 8 – Reflect and Document

After tests:

```sql
SELECT * FROM transaction_demo;
```

Then clean up:

```sql
TRUNCATE TABLE transaction_demo RESTART IDENTITY;
```

---

## **7. Deliverables**

Submit:

```
Lastname_Firstname_WS07_Transactions.sql
```

Include:

* All code examples and tests
* Inline comments explaining outcomes
* One paragraph reflection

---

## **8. Reflection Questions**

1. Why is atomicity essential in transactional systems?
2. How do savepoints differ from full rollbacks?
3. In what real-world scenario could idempotent logic prevent data loss?
4. Why is isolation a necessary property for concurrent systems?
5. How can EXCEPTION handling improve reliability in stored procedures?

---

## **9. Assessment & Rubric (10 pts)**

| Criteria                   | Excellent (3)                    | Satisfactory (2)      | Needs Improvement (1)      | Pts     |
| -------------------------- | -------------------------------- | --------------------- | -------------------------- | ------- |
| Transactional Logic        | Correct, atomic, well-structured | Minor errors          | Incomplete or inconsistent | __/3    |
| Savepoint & Rollback Usage | Demonstrated & explained         | Partial understanding | Missing                    | __/3    |
| Error Handling             | Uses EXCEPTION correctly         | Partial logic         | Missing or invalid         | __/2    |
| Reflection                 | Insightful, connects to ACID     | Generic               | Missing                    | __/2    |
| **Total**                  |                                  |                       |                            | **/10** |

---

## **10. Submission Guidelines**

* Use `make psql` inside **DBAS PostgreSQL DevOps Stack (v3.2)**.
* Comment every test’s result directly in SQL.
* Submit `.sql` and `.txt` reflection on Brightspace or GitHub.

---

## **11. Resources / Equipment**

* DBAS PostgreSQL DevOps Stack (v3.2)
* PostgreSQL Docs: [Transactions](https://www.postgresql.org/docs/current/tutorial-transactions.html)
* Docker Desktop / Compose
* pgAdmin Query Tool

---

## **12. Copyright**

© 2025 Nova Scotia Community College — For educational use only.

