![alt text](image.png)


---

### 1. Assignment Details

| Field             | Information                                        |
| ----------------- | -------------------------------------------------- |
| **Workshop**      | 10 – Concurrency & Isolation                       |
| **Course**        | DBAS4002 – Transactional Database Programming      |
| **Mode**          | Hands-on lab + reflection                          |
| **Duration**      | ~2–3 hours                                         |
| **Tools**         | Docker, PostgreSQL, psql, Makefile                 |
| **Prerequisites** | MP1 schema + MP2 transactional logic stack running |

---

### 2. Overview / Purpose / Objectives

#### Conceptual Framing

Up to now, you’ve mostly worked as if you were the **only user in the system**. Real databases rarely have that luxury.

In production:

* Multiple users edit the same data.
* Background jobs run heavy updates.
* Reports read data while writes are in progress.

This workshop brings in **concurrency and isolation**: how PostgreSQL uses **locks** and **MVCC (Multi-Version Concurrency Control)** to keep transactions safe, even when they overlap.

You will **see and feel**:

* One transaction blocking another
* Deadlocks and how PostgreSQL resolves them
* How different **isolation levels** change what each transaction can “see”

---

#### Purpose

You will:

* Use **two psql sessions** to simulate concurrent activity.
* Explore **row-level locks** and blocking.
* Produce and analyze a **deadlock** scenario.
* Compare behavior under **READ COMMITTED** vs **REPEATABLE READ** vs **SERIALIZABLE**.
* Use a companion script `mp10_concurrency_tests.sql` as a guided test harness.

---

#### Learning Outcomes Addressed

* **O2 – Manage transactions with DML + procedural code**
  Understand how transactions behave under concurrent access.

* **O3 – Optimize distribution of transactional load**
  Reason about concurrency, isolation levels, and when to trade strictness for performance.

---

### 3. Workshop Context

We continue using the **Event Management** schema:

* `category(category_id, name, …)`
* `event(event_id, name, category_id, start_date, end_date, priority, …)`

The business context:

* Multiple staff manage events.
* Admins might edit event info simultaneously.
* Some processes might try to delete categories while events exist.

Your job today is to observe **how PostgreSQL protects integrity** while still allowing concurrency.

---

### 4. Tools Overview

| Tool                                  | Purpose                                                         |
| ------------------------------------- | --------------------------------------------------------------- |
| **Docker / docker-compose**           | Run PostgreSQL and pgAdmin in containers.                       |
| **Makefile** (`make up`, `make psql`) | Simplify environment startup & connection.                      |
| **psql**                              | Interactive SQL shell; supports meta-commands like `\conninfo`. |
| **`mp10_concurrency_tests.sql`**      | Guided script with all commands grouped by scenario.            |

---

### 5. Setup & Using the Companion Script

#### 5.1. Environment Setup

From your project root:

```bash
make up      # start containers
make psql    # open Session A
```

Open a **second terminal**:

```bash
make psql    # open Session B
```

In both sessions, verify where you are:

```sql
\conninfo
SELECT CURRENT_USER, CURRENT_DATABASE();
```

> **Reminder:**
>
> * `\conninfo` is a psql meta-command → **no semicolon**
> * `SELECT` is SQL → **requires semicolon**

---

#### 5.2. Placing the Companion Script

Create this path in your repo:

```text
sql/
  99_tests/
    mp10_concurrency_tests.sql
```

Save the SQL file (provided in full below) as:

```text
sql/99_tests/mp10_concurrency_tests.sql
```

Ensure your `docker-compose.yml` mounts `./sql:/sql` in the `db` service:

```yaml
    volumes:
      - pgdata:/var/lib/postgresql/data
      - ./sql:/sql
```

Recreate containers if you change volumes:

```bash
make down
make up
```

---

#### 5.3. How to Use `mp10_concurrency_tests.sql`

> **Important**: This script is a **guided lab script**, not a single “fire and forget” test. It:
>
> * Runs some helper queries
> * Prints instructions with `\echo`
> * Contains **blocks you copy/paste** into Session A and Session B

You will:

1. In **Session A**, run:

   ```sql
   \i /sql/99_tests/mp10_concurrency_tests.sql
   ```

   to read the intro and see all sections.

2. For each scenario, follow the comments:

   * **Copy the “Session A” block** into Session A.
   * **Copy the “Session B” block** into Session B.

3. Observe blocking, errors, and outputs.

4. Optionally, instructors can **print the script** or show it on-screen.

---

### 6. Workshop Tasks (Linked to Script Sections)

Below are the core learning tasks; each is matched to a section in `mp10_concurrency_tests.sql`.

---

#### 🧭 Task 1 – Observe Row-Level Locking (Section 1)

**Goal:** See how one transaction can block another on the same row.

In `mp10_concurrency_tests.sql`:

* **Find Section 1 – ROW-LEVEL LOCK DEMO**
* Follow the instructions:

**Session A:**

```sql
BEGIN;
SELECT * FROM event WHERE event_id = 1 FOR UPDATE;
```

**Session B:**

```sql
BEGIN;
UPDATE event SET priority = priority + 1 WHERE event_id = 1;
```

You’ll see Session B **hang** until Session A commits/rolls back.

Then in **Session A**:

```sql
COMMIT;
```

**Conceptual takeaway:**

* PostgreSQL acquired a **row-level exclusive lock** in Session A.
* Session B’s update had to **wait**.
* This prevents **lost updates** and unsafe writes.

---

#### 🧭 Task 2 – Create and Analyze a Deadlock (Section 2)

**Goal:** Produce a deadlock and see PostgreSQL resolve it.

In the script, Section 2 shows commands roughly like:

**Session A:**

```sql
BEGIN;
UPDATE event SET priority = 100 WHERE event_id = 1;
```

**Session B:**

```sql
BEGIN;
UPDATE event SET priority = 200 WHERE event_id = 2;
```

Then both sessions try to update the other row:

* Session A:

  ```sql
  UPDATE event SET priority = 100 WHERE event_id = 2;
  ```

* Session B:

  ```sql
  UPDATE event SET priority = 200 WHERE event_id = 1;
  ```

You should see an error in one session:

```text
ERROR:  deadlock detected
DETAIL: Process XXXX waits for ...
```

**Conceptual takeaway:**

* Each session held a lock the other needed.
* Neither could progress → **deadlock**.
* PostgreSQL automatically cancels one transaction to break the cycle.

---

#### 🧭 Task 3 – Compare READ COMMITTED vs REPEATABLE READ (Section 3)

**Goal:** See how isolation levels affect visibility of changes.

In the script, you’ll see two sub-scenarios:

1. **READ COMMITTED (default)** – each statement sees latest committed data.
2. **REPEATABLE READ** – your transaction sees a stable snapshot.

**READ COMMITTED:**

**Session A:**

```sql
BEGIN;
SELECT priority FROM event WHERE event_id = 1;
-- note the value
```

**Session B:**

```sql
UPDATE event SET priority = 777 WHERE event_id = 1;
COMMIT;
```

Back to **Session A**:

```sql
SELECT priority FROM event WHERE event_id = 1;
COMMIT;
```

You see the **updated value** because each statement reads the latest committed snapshot.

**REPEATABLE READ:**

**Session A:**

```sql
BEGIN ISOLATION LEVEL REPEATABLE READ;
SELECT priority FROM event WHERE event_id = 1;
-- note the value
```

**Session B:**

```sql
UPDATE event SET priority = 555 WHERE event_id = 1;
COMMIT;
```

Back to **Session A**:

```sql
SELECT priority FROM event WHERE event_id = 1;
COMMIT;
```

You’ll still see the **original value**, because your transaction is pinned to a snapshot.

---

#### 🧭 Task 4 – SERIALIZABLE and Serialization Failures (Section 4)

**Goal:** See how SERIALIZABLE guarantees full consistency, even across complex concurrent operations.

**Session A:**

```sql
BEGIN ISOLATION LEVEL SERIALIZABLE;
SELECT COUNT(*) FROM event WHERE priority > 1;
-- hold this open
```

**Session B:**

```sql
INSERT INTO event (name, category_id, start_date, end_date, priority, description, location, organizer)
VALUES ('Serializable Test', 1, NOW(), NOW() + INTERVAL '1 hour', 10, 'serial test', 'lab', 'system');
COMMIT;
```

Back in **Session A**:

```sql
SELECT COUNT(*) FROM event WHERE priority > 1;
COMMIT;
```

You may see a **serialization failure** such as:

```text
ERROR:  could not serialize access due to concurrent update
```

**Conceptual takeaway:**

* SERIALIZABLE enforces a guarantee:
  “It should look like all transactions ran one-by-one in some order.”
* When that can’t be guaranteed, PostgreSQL asks you to **retry** the transaction.

---

### 7. Companion Script: `mp10_concurrency_tests.sql`

Here is the full script you can save as:

`sql/99_tests/mp10_concurrency_tests.sql`

```sql
/* ============================================================
   File: 99_tests/mp10_concurrency_tests.sql
   Course: DBAS 4002 – Transactional Database Programming
   Workshop: 10 – Concurrency & Isolation
   Title: Guided Concurrency Tests (mp10_concurrency_tests.sql)

   IMPORTANT:
   - This script is a GUIDED LAB SCRIPT.
   - You will NOT just "\i" once and forget.
   - Use it as:
       1) A reference of commands
       2) A step-by-step guide for Session A and Session B
   - Open TWO terminals:
       Session A: make psql
       Session B: make psql
   ============================================================ */

\echo '============================================================'
\echo ' MP10 – CONCURRENCY & ISOLATION – GUIDED SCRIPT'
\echo ' Open TWO psql sessions: Session A and Session B.'
\echo ' Use the labeled blocks below for each session.'
\echo '============================================================'

\echo ''
\echo 'Step 0: Basic context (run in any session)'
\conninfo
SELECT CURRENT_USER AS current_user, CURRENT_DATABASE() AS current_database;

/* ============================================================
   SECTION 1 – ROW-LEVEL LOCK DEMO
   Goal:
     - Show that one transaction can block another trying to write.
   Instructions:
     - COPY Session A block into psql Session A
     - COPY Session B block into psql Session B
   ============================================================ */

\echo ''
\echo '------------------------------------------------------------'
\echo 'SECTION 1 – ROW-LEVEL LOCK DEMO'
\echo 'Session A:'
\echo '  BEGIN;'
\echo '  SELECT * FROM event WHERE event_id = 1 FOR UPDATE;'
\echo ''
\echo 'Session B:'
\echo '  BEGIN;'
\echo '  UPDATE event SET priority = priority + 1 WHERE event_id = 1;'
\echo ''
\echo 'Observe: Session B will block until Session A COMMITs or ROLLBACKs.'
\echo 'Then in Session A: COMMIT;'
\echo '------------------------------------------------------------'

/* ============================================================
   SECTION 2 – DEADLOCK DEMO
   Goal:
     - Create a circular wait and observe "deadlock detected".
   ============================================================ */

\echo ''
\echo '------------------------------------------------------------'
\echo 'SECTION 2 – DEADLOCK DEMO'
\echo 'Pre-step: Identify two event_ids to use (e.g., 1 and 2)'
\echo '  SELECT event_id, name FROM event LIMIT 2;'
\echo ''
\echo 'Session A:'
\echo '  BEGIN;'
\echo '  UPDATE event SET priority = 100 WHERE event_id = 1;'
\echo ''
\echo 'Session B:'
\echo '  BEGIN;'
\echo '  UPDATE event SET priority = 200 WHERE event_id = 2;'
\echo ''
\echo 'Now reverse the lock order:'
\echo '  Session A: UPDATE event SET priority = 100 WHERE event_id = 2;'
\echo '  Session B: UPDATE event SET priority = 200 WHERE event_id = 1;'
\echo ''
\echo 'One session should show: ERROR: deadlock detected'
\echo '------------------------------------------------------------'

/* ============================================================
   SECTION 3 – ISOLATION LEVEL: READ COMMITTED vs REPEATABLE READ
   Goal:
     - Show that READ COMMITTED sees latest committed changes per statement
     - Show that REPEATABLE READ sees a stable snapshot
   ============================================================ */

\echo ''
\echo '------------------------------------------------------------'
\echo 'SECTION 3 – READ COMMITTED vs REPEATABLE READ'
\echo 'READ COMMITTED (default):'
\echo ''
\echo 'Session A:'
\echo '  BEGIN;'
\echo '  SELECT priority FROM event WHERE event_id = 1;  -- note value'
\echo ''
\echo 'Session B:'
\echo '  UPDATE event SET priority = 777 WHERE event_id = 1;'
\echo '  COMMIT;'
\echo ''
\echo 'Session A:'
\echo '  SELECT priority FROM event WHERE event_id = 1;  -- now see 777'
\echo '  COMMIT;'
\echo ''
\echo 'REPEATABLE READ:'
\echo ''
\echo 'Session A:'
\echo '  BEGIN ISOLATION LEVEL REPEATABLE READ;'
\echo '  SELECT priority FROM event WHERE event_id = 1;  -- note value'
\echo ''
\echo 'Session B:'
\echo '  UPDATE event SET priority = 555 WHERE event_id = 1;'
\echo '  COMMIT;'
\echo ''
\echo 'Session A:'
\echo '  SELECT priority FROM event WHERE event_id = 1;'
\echo '  -- still sees original value, not 555'
\echo '  COMMIT;'
\echo '------------------------------------------------------------'

/* ============================================================
   SECTION 4 – SERIALIZABLE & SERIALIZATION FAILURES
   Goal:
     - See how SERIALIZABLE may force a transaction to retry.
   ============================================================ */

\echo ''
\echo '------------------------------------------------------------'
\echo 'SECTION 4 – SERIALIZABLE DEMO'
\echo ''
\echo 'Session A:'
\echo '  BEGIN ISOLATION LEVEL SERIALIZABLE;'
\echo '  SELECT COUNT(*) FROM event WHERE priority > 1;  -- snapshot'
\echo ''
\echo 'Session B:'
\echo '  INSERT INTO event (name, category_id, start_date, end_date, priority, description, location, organizer)'
\echo '  VALUES ('
\echo '    ''Serializable Test'','
\echo '    1,'
\echo '    NOW(),'
\echo '    NOW() + INTERVAL ''1 hour'','
\echo '    10,'
\echo '    ''serial test'','
\echo '    ''lab'','
\echo '    ''system'''
\echo '  );'
\echo '  COMMIT;'
\echo ''
\echo 'Session A:'
\echo '  SELECT COUNT(*) FROM event WHERE priority > 1;'
\echo '  -- may succeed or may raise: could not serialize access due to concurrent update'
\echo '  COMMIT;'
\echo '------------------------------------------------------------'

/* ============================================================
   SECTION 5 – SUMMARY CHECKS (single session)
   ============================================================ */

\echo ''
\echo '------------------------------------------------------------'
\echo 'SECTION 5 – FINAL SUMMARY (run in any one session)'
\echo '  SELECT COUNT(*) FROM event;'
\echo '  SELECT COUNT(*) FROM event WHERE priority > 1;'
\echo 'Review what changed during your tests.'
\echo '------------------------------------------------------------'

\echo ''
\echo 'END OF mp10_concurrency_tests.sql – use this as a guided reference.'
```

---

### 8. Deliverables

Students submit:

1. **A brief report** (Markdown/PDF) with:

   * Notes + screenshots from **at least three scenarios**:

     * Row-level lock
     * Deadlock
     * Isolation level comparison
   * Explanations of what they observed and why it happened.

2. **Short answers** to reflection questions (can be in same report).

---

### 9. Reflection Questions

You can paste these into Brightspace:

1. In your own words, what is a **row-level lock**, and why did Session B block in Section 1?
2. Describe the sequence of steps that led to a **deadlock**. How did PostgreSQL resolve it?
3. Compare **READ COMMITTED** and **REPEATABLE READ** based on your experiments. When might each be appropriate?
4. What does **SERIALIZABLE** add on top of the other isolation levels? Why might it cause an error instead of returning a result?
5. How could these concepts (locks, deadlocks, isolation) affect an application that uses this database (e.g., a Django app using this schema)?

