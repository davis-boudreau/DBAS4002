![alt text](image.png)

---

**Course:** DBAS 4002 – Transactional Database Programming
**Type:** Major Applied Project
**Instructor:** Davis Boudreau
**Stack Used:** DBAS PostgreSQL DevOps Stack (v3.2)
**Duration:** ~2 weeks (Weeks 6–8)
**Version:** 2.1 (Fall 2025, with test suite)

---

## 1. Assignment Details

| Field                | Information                                               |
| :------------------- | :-------------------------------------------------------- |
| **Assignment Title** | MP2 – Transactional Logic, Procedures & Auditing          |
| **Course Code**      | DBAS 4002                                                 |
| **Weight**           | 15%                                                       |
| **Due Date**         | End of Week 8                                             |
| **Estimated Effort** | 6–8 hours                                                 |
| **Environment**      | Dockerized PostgreSQL (DBAS PostgreSQL DevOps Stack v3.2) |

---

## 2. Overview / Purpose / Objectives

### Conceptual Framing

In MP1, you focused on **schema design, constraints, and querying**.
In **MP2**, you move into the **behavioral layer** of a transactional database:

* How do we ensure business rules are respected at runtime?
* How do we guarantee that failed operations don’t corrupt data?
* How do we audit *who did what and when*?

You will design and implement **procedural SQL (PL/pgSQL)**, **transactions**, and **triggers** that:

* validate business rules,
* protect integrity,
* and automatically log changes into an **audit trail**.

You’ll also use a **companion test suite** (`mp2_testcases.sql`) to validate your work in a repeatable, DevOps-friendly way.

---

### Purpose

You will:

* Implement a **stored procedure** to create events safely.
* Use **transaction control** and **EXCEPTION handling** to manage failures.
* Implement **BEFORE** and **AFTER** triggers to enforce rules and create an audit trail.
* Use a shared **test script** to verify commit/rollback behavior and trigger execution.
* Reflect on how procedural logic and auditing support reliable transactional systems.

---

### Learning Outcomes Addressed

* **Outcome 2 – Manage transactions with DML + procedural code**
  Apply transactions, error handling, and procedural SQL to enforce business rules.

* **Outcome 4 – Interpret complex procedural code to support modifications**
  Read, execute, and reason about stored procedures, triggers, and test harnesses.

---

## 3. Assignment Description / Use Case

You are extending the **Event Management** schema (from MP1):

* `category` — categories of events (e.g., Workshop, Seminar).
* `event` — scheduled events linked to a category.

**Business requirements for MP2:**

1. **Events must be valid**: `end_date` must be after `start_date`.
2. **Categories must be protected**: a category with events **cannot be deleted**.
3. **Auditing must be automatic**: whenever events are inserted, a record is written to an `audit_log` table.
4. **Transactions must be safe**: you must use `BEGIN` / `COMMIT` / `ROLLBACK` and EXCEPTION handling to prevent partial updates.

You’ll also use a standardized test harness (`mp2_testcases.sql`) to validate:

* successful commits,
* failed operations and rollbacks,
* trigger behavior (audit logs and protected deletes).

---

## 4. Tasks / Instructions

### 🧭 Step 1 – Start Environment & Connect

From your project directory:

```bash
make up      # start PostgreSQL + pgAdmin stack
make psql    # connect to PostgreSQL using psql inside the container
```

Inside `psql`, confirm:

```sql
\conninfo
SELECT CURRENT_USER, CURRENT_DATABASE();
```

---

### ⚙️ Step 2 – Create the Audit Table

In `psql`:

```sql
CREATE TABLE IF NOT EXISTS audit_log (
  audit_id    SERIAL PRIMARY KEY,
  table_name  TEXT NOT NULL,
  action      TEXT NOT NULL,
  record_id   INT,
  change_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  user_name   TEXT DEFAULT CURRENT_USER
);
```

**Concept:**
This records *who did what to which row and when*. It’s your core audit mechanism.

---

### 🧱 Step 3 – Implement the `create_event` Stored Procedure

Create a procedure to safely create events with validation and transaction control.

**Example template (you may refine/improve it):**

```sql
CREATE OR REPLACE PROCEDURE create_event(
  p_name        TEXT,
  p_category_id INT,
  p_start       TIMESTAMP,
  p_end         TIMESTAMP,
  p_priority    INT,
  p_description TEXT,
  p_location    TEXT,
  p_organizer   TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
  -- Business rule: end date must be after start date
  IF p_end <= p_start THEN
    RAISE EXCEPTION 'End date (%) must be after start date (%).', p_end, p_start;
  END IF;

  INSERT INTO event (name, category_id, start_date, end_date, priority, description, location, organizer)
  VALUES (p_name, p_category_id, p_start, p_end, p_priority, p_description, p_location, p_organizer);

  -- In many designs, COMMIT/ROLLBACK are driven at session level.
  -- If you explicitly manage transactions here, be consistent.
EXCEPTION
  WHEN OTHERS THEN
    -- Ensure the transaction is cleaned up and error is visible
    RAISE NOTICE 'create_event() failed: %', SQLERRM;
    RAISE;  -- bubble up the exception to caller
END;
$$;
```

You can manage `BEGIN` / `COMMIT` outside the procedure (in test scripts) or inside, but be consistent and explain your choice in comments.

---

### 🧩 Step 4 – AFTER INSERT Trigger for Event Auditing

Create an auditing trigger that logs successful inserts:

```sql
CREATE OR REPLACE FUNCTION log_event_insert()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO audit_log (table_name, action, record_id)
  VALUES ('event', 'INSERT', NEW.event_id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_log_event_insert
AFTER INSERT ON event
FOR EACH ROW
EXECUTE FUNCTION log_event_insert();
```

**Concept:**
This ensures that **every event inserted**, no matter how, is automatically recorded in the audit table.

---

### 🔒 Step 5 – BEFORE DELETE Trigger to Protect Categories

Prevent deletion of categories that still have events:

```sql
CREATE OR REPLACE FUNCTION prevent_category_delete()
RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM event WHERE category_id = OLD.category_id) THEN
    RAISE EXCEPTION 'Cannot delete category %: events still exist.', OLD.category_id;
  END IF;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_category_delete
BEFORE DELETE ON category
FOR EACH ROW
EXECUTE FUNCTION prevent_category_delete();
```

**Concept:**
This enforces a **business rule** that the database itself will not allow category deletion while linked events exist.

---

### 🧪 Step 6 – Add the Companion Test Suite (`mp2_testcases.sql`)

Create this file in your repo (recommended path):

`/sql/99_tests/mp2_testcases.sql`

Paste in the full test harness (you can adapt names if needed):

```sql
/* ============================================================
   File: 99_tests/mp2_testcases.sql
   Course: DBAS 4002 – Transactional Database Programming
   Title: MP2 – Transactional Logic & Auditing Test Suite
   Description:
     Validates:
       - Stored procedure behavior (create_event)
       - Transaction commit / rollback paths
       - AFTER INSERT trigger logging to audit_log
       - BEFORE DELETE trigger preventing category deletes
   Run via:
     make psql
     \i /sql/99_tests/mp2_testcases.sql
   ============================================================ */

\echo '============================================================'
\echo ' MP2 TEST SUITE – PROCEDURES, TRANSACTIONS & AUDITING'
\echo '============================================================'

\echo 'Step 0: Show current connection context'
\conninfo
SELECT CURRENT_USER AS current_user, CURRENT_DATABASE() AS current_database;

-- Optional: show current table state
\echo 'Step 0a: Current row counts before tests'
SELECT 'category' AS table_name, COUNT(*) AS row_count FROM category
UNION ALL
SELECT 'event', COUNT(*) FROM event
UNION ALL
SELECT 'audit_log', COUNT(*) FROM audit_log;

-- ============================================================
-- TEST 1 – Successful create_event call triggers COMMIT + audit
-- ============================================================
\echo ''
\echo '------------------------------------------------------------'
\echo 'TEST 1: Successful create_event() call with valid dates'
\echo '  Expectation:'
\echo '    - New row appears in event'
\echo '    - AFTER INSERT trigger writes to audit_log'
\echo '------------------------------------------------------------'

BEGIN;

CALL create_event(
  'MP2 Valid Event 01',
  1,                                    -- assumes category_id = 1 exists
  '2025-10-01 09:00:00',
  '2025-10-01 12:00:00',
  2,
  'Valid test event for MP2 Test 1',
  'Room 101',
  'Test User'
);

-- Show the last inserted event (by name pattern)
SELECT event_id, name, start_date, end_date, priority
FROM event
WHERE name = 'MP2 Valid Event 01';

-- Show latest audit_log entries for event table
SELECT audit_id, table_name, action, record_id, change_time
FROM audit_log
WHERE table_name = 'event'
ORDER BY audit_id DESC
LIMIT 5;

COMMIT;

\echo 'TEST 1 COMPLETE: Check that at least one event and one audit_log row were added.'

-- ============================================================
-- TEST 2 – Invalid dates cause EXCEPTION and ROLLBACK
-- ============================================================
\echo ''
\echo '------------------------------------------------------------'
\echo 'TEST 2: create_event() with invalid dates (end <= start)'
\echo '  Expectation:'
\echo '    - Procedure raises EXCEPTION'
\echo '    - No event row is committed'
\echo '    - No audit_log row is written for this attempt'
\echo '------------------------------------------------------------'

-- Capture row counts before the failing call
SELECT COUNT(*) AS event_before FROM event;
SELECT COUNT(*) AS audit_before FROM audit_log;

-- We intentionally allow the error to surface so students see it:
DO $$
BEGIN
  RAISE NOTICE 'Calling create_event() with invalid date range...';
  BEGIN
    CALL create_event(
      'MP2 Invalid Event 02',
      1,
      '2025-10-05 14:00:00',
      '2025-10-05 10:00:00',  -- invalid: end before start
      1,
      'This should fail due to end_date <= start_date',
      'Room 102',
      'Test User'
    );
  EXCEPTION
    WHEN OTHERS THEN
      RAISE NOTICE 'As expected, create_event() failed: %', SQLERRM;
  END;
END $$;

-- Re-check row counts after
SELECT COUNT(*) AS event_after FROM event;
SELECT COUNT(*) AS audit_after FROM audit_log;

\echo 'TEST 2 COMPLETE: event_after should equal event_before,'
\echo '                audit_after should equal audit_before.'

-- ============================================================
-- TEST 3 – AFTER INSERT trigger idempotence & logging behavior
-- ============================================================
\echo ''
\echo '------------------------------------------------------------'
\echo 'TEST 3: Multiple valid inserts – verify each is logged'
\echo '  Expectation:'
\echo '    - Each successful insert creates one audit_log row'
\echo '------------------------------------------------------------'

BEGIN;

-- Count audit_log entries for event before
SELECT COUNT(*) AS audit_event_before
FROM audit_log
WHERE table_name = 'event' AND action = 'INSERT';

CALL create_event(
  'MP2 Valid Event 03',
  1,
  '2025-10-10 09:00:00',
  '2025-10-10 11:00:00',
  3,
  'Trigger logging test 1',
  'Lab 201',
  'Test User'
);

CALL create_event(
  'MP2 Valid Event 04',
  1,
  '2025-10-11 09:00:00',
  '2025-10-11 11:00:00',
  3,
  'Trigger logging test 2',
  'Lab 202',
  'Test User'
);

-- Count audit_log entries for event after
SELECT COUNT(*) AS audit_event_after
FROM audit_log
WHERE table_name = 'event' AND action = 'INSERT';

-- Show the most recent audit_log rows
SELECT audit_id, table_name, action, record_id, change_time
FROM audit_log
WHERE table_name = 'event'
ORDER BY audit_id DESC
LIMIT 10;

COMMIT;

\echo 'TEST 3 COMPLETE: audit_event_after should be'
\echo '                audit_event_before + 2.'

-- ============================================================
-- TEST 4 – BEFORE DELETE trigger prevents category deletion
-- ============================================================
\echo ''
\echo '------------------------------------------------------------'
\echo 'TEST 4: Attempt to delete category with existing events'
\echo '  Expectation:'
\echo '    - BEFORE DELETE trigger raises EXCEPTION'
\echo '    - Category row remains in the table'
\echo '------------------------------------------------------------'

-- Show categories and associated event counts
SELECT c.category_id, c.name, COUNT(e.event_id) AS event_count
FROM category c
LEFT JOIN event e ON e.category_id = c.category_id
GROUP BY c.category_id, c.name
ORDER BY c.category_id;

-- We will try to delete category_id = 1 (assuming it has events)
DO $$
DECLARE
  v_has_events BOOLEAN;
BEGIN
  SELECT EXISTS (
    SELECT 1 FROM event WHERE category_id = 1
  ) INTO v_has_events;

  IF NOT v_has_events THEN
    RAISE NOTICE 'WARNING: category_id = 1 has no events; add one before running this test for full effect.';
  END IF;

  BEGIN
    RAISE NOTICE 'Attempting to delete category_id = 1...';
    DELETE FROM category WHERE category_id = 1;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE NOTICE 'As expected, delete prevented: %', SQLERRM;
  END;
END $$;

-- Confirm category_id = 1 still exists
SELECT category_id, name
FROM category
WHERE category_id = 1;

\echo 'TEST 4 COMPLETE: category_id = 1 should still exist if it had events.'

-- ============================================================
-- TEST 5 – Safe delete of empty category
-- ============================================================
\echo ''
\echo '------------------------------------------------------------'
\echo 'TEST 5: Create a new category with no events and delete it'
\echo '  Expectation:'
\echo '    - BEFORE DELETE trigger allows delete (no referencing events)'
\echo '------------------------------------------------------------'

BEGIN;

-- Create a temporary category
INSERT INTO category (name)
VALUES ('MP2 Temp Category – Safe Delete')
RETURNING category_id;

-- Show the temp category
SELECT * FROM category
WHERE name = 'MP2 Temp Category – Safe Delete';

-- Now delete it
DELETE FROM category
WHERE name = 'MP2 Temp Category – Safe Delete';

-- Confirm deletion
SELECT * FROM category
WHERE name = 'MP2 Temp Category – Safe Delete';

COMMIT;

\echo 'TEST 5 COMPLETE: temp category should be gone with no exceptions raised.'

-- ============================================================
-- TEST 6 – Summary & Final State
-- ============================================================
\echo ''
\echo '------------------------------------------------------------'
\echo 'TEST 6: Final summary of key tables'
\echo '------------------------------------------------------------'

SELECT 'category' AS table_name, COUNT(*) AS row_count FROM category
UNION ALL
SELECT 'event', COUNT(*) FROM event
UNION ALL
SELECT 'audit_log', COUNT(*) FROM audit_log;

\echo 'MP2 TEST SUITE FINISHED.'
\echo 'Review the NOTICE output and SELECT results above to confirm:'
\echo '  - Successful events were inserted and logged.'
\echo '  - Invalid events were rolled back and not logged.'
\echo '  - Categories with events cannot be deleted.'
\echo '  - Empty categories can be safely removed.'

```

---

### 🧪 How Students Run the Test Suite

In your assignment instructions (and README), tell students:

1. Start stack and open psql:

   ```bash
   make up
   make psql
   ```

2. Run the MP2 test suite:

   ```sql
   \i /sql/99_tests/mp2_testcases.sql
   ```

3. Observe:

   * `NOTICE` messages (`As expected, create_event() failed…`, etc.).
   * `SELECT` outputs showing row counts before/after.
   * Evidence of:

     * Successful event inserts + audit rows
     * Prevented invalid events (no rows added)
     * Protected category deletes
     * Safe deletion of a category with no events

Students should **capture output** (screenshot or copy/paste) and summarize results in their reflection.

---

## 5. Deliverables

Submit:

1. **SQL code file(s):**

   * `Lastname_Firstname_MP2_Procedures.sql`

     * `audit_log` table (if not in MP1)
     * `create_event` procedure
     * `log_event_insert` function + trigger
     * `prevent_category_delete` function + trigger
   * `Lastname_Firstname_MP2_Tests.sql`

     * Optionally, a trimmed or custom version of `mp2_testcases.sql`
     * Any additional tests you add yourself

2. **Reflection document:**

   * `Lastname_Firstname_MP2_Reflection.txt` or `.md`

   Include:

   * Brief description of each procedure/trigger.
   * What happened in each test (success, rollback, prevented delete).
   * What you learned about transactions and auditing.

---

## 6. Reflection Questions

You may answer in paragraph or Q&A format:

1. How does `create_event` improve safety compared to raw `INSERT` statements?
2. Why is it powerful to enforce business rules (like “don’t delete categories with events”) *in the database*, not just in the application?
3. Describe one scenario from the test suite where a **failure** showed that your transactional control is working correctly.
4. How do audit logs support debugging, accountability, and security?
5. If you had to expose this database to a web app, how would these procedures and triggers simplify the API design?

---

## 7. Assessment & Rubric (15 pts)

| Criteria                              | Excellent (3)                                        | Satisfactory (2)                   | Needs Improvement (1)           | Pts     |
| :------------------------------------ | :--------------------------------------------------- | :--------------------------------- | :------------------------------ | :------ |
| **Procedural Logic (`create_event`)** | Correct validation, clear logic, good comments       | Minor issues or missing comments   | Fails, or logic incomplete      | __/3    |
| **Transaction & Error Handling**      | Correct commit/rollback behavior, handled exceptions | Partial handling                   | No clear transaction control    | __/3    |
| **Triggers & Audit Design**           | Triggers work; audit data is useful and correct      | Partially working; limited logging | Triggers missing or incorrect   | __/3    |
| **Test Suite Usage**                  | Ran `mp2_testcases.sql`, interpreted results clearly | Ran tests but weak interpretation  | Did not run or understand tests | __/3    |
| **Reflection & Professionalism**      | Deep, thoughtful, well-structured                    | Adequate, somewhat surface-level   | Minimal or missing              | __/3    |
| **Total**                             |                                                      |                                    |                                 | **/15** |

---

## 8. Submission Guidelines

* Ensure your code runs inside the **DBAS PostgreSQL DevOps Stack (v3.2)**.

* Test everything using:

  ```bash
  make up
  make psql
  \i /sql/99_tests/mp2_testcases.sql
  ```

* Submit via Brightspace or GitHub (as specified by your instructor).

* Include your name, course, and assignment name in file headers.

---

## 9. Resources / Equipment

* DBAS PostgreSQL DevOps Stack (v3.2)
* PostgreSQL Docs – PL/pgSQL, triggers, transactions
* Docker Desktop + Docker Compose
* pgAdmin or psql shell

---

## 10. Academic Policies

* Follow NSCC academic integrity policies.
* You may discuss ideas, but all SQL and reflection writing must be your own.

---

## 11. Copyright

© 2025 Nova Scotia Community College — For educational use only.

