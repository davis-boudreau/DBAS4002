### Q1 — Purpose of a transaction block

**Correct answer:** `BEGIN … COMMIT` ensures a group of statements executes **atomically**.
**Why:** If any statement fails, the whole unit can be rolled back → no partial changes. This enforces **A**tomicity and **C**onsistency.
**Code:**

```sql
BEGIN;
  INSERT INTO registration(user_id, event_id) VALUES (42, 1001);
  UPDATE event SET remaining = remaining - 1 WHERE event_id = 1001;
COMMIT;  -- Either both succeed or neither does
```

**Watch for:** Running related DML outside a transaction risks orphaned or inconsistent state.

---

### Q2 — Begin/End of a transaction

**Correct answer:** `BEGIN` and `COMMIT`.
**Why:** These delimit the transaction’s boundary (you can also use `START TRANSACTION;`).
**Code:**

```sql
BEGIN;
  -- work
COMMIT;
-- or
ROLLBACK;  -- on error
```

**Watch for:** Forgetting to commit leaves the session in a transaction; closing the session rolls it back.

---

### Q3 — Role of SAVEPOINT

**Correct answer:** **Rollback to an intermediate point**.
**Why:** Complex units benefit from partial error recovery without discarding earlier successful work.
**Code:**

```sql
BEGIN;
  -- phase 1
  SAVEPOINT phase2;
  -- phase 2 risky
  -- if something goes wrong:
  ROLLBACK TO SAVEPOINT phase2;
COMMIT;
```

**Watch for:** Use meaningful savepoint names when you have multiple phases.

---

### Q4 — Undo all changes in current transaction

**Correct answer:** `ROLLBACK`.
**Why:** Aborts the entire transaction, restoring the pre-transaction state.
**Code:**

```sql
BEGIN;
  INSERT INTO event(name) VALUES ('Bad Data');
  -- detected problem
ROLLBACK;  -- 'Bad Data' never persists
```

**Watch for:** After an unhandled error, the transaction is “aborted” until you `ROLLBACK`.

---

### Q5 — Why triggers matter

**Correct answer:** **Automate rule enforcement/auditing** on data changes.
**Why:** Triggers centralize integrity and logging at the DB layer—cannot be bypassed by application bugs.
**Code (audit AFTER INSERT):**

```sql
CREATE FUNCTION audit_event_ins() RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO audit_log(table_name, operation, record_id, new_data)
  VALUES ('event', 'INSERT', NEW.event_id, to_jsonb(NEW));
  RETURN NEW;
END; $$ LANGUAGE plpgsql;

CREATE TRIGGER trg_event_audit_ins
AFTER INSERT ON event
FOR EACH ROW EXECUTE FUNCTION audit_event_ins();
```

**Watch for:** Keep trigger work lightweight; heavy logic can impact write performance.

---

### Q6 — AFTER INSERT trigger use

**Correct answer:** **Record the new row in an audit log after it is saved**.
**Why:** AFTER timing guarantees the row exists and keys are finalized.
**Code:**

```sql
CREATE TRIGGER trg_reg_audit_ins
AFTER INSERT ON registration
FOR EACH ROW EXECUTE FUNCTION audit_registration_ins();
```

**Watch for:** Use `AFTER` for logging/notifications; use `BEFORE` for validation/defaulting.

---

### Q7 — Validate before commit

**Correct answer:** **BEFORE trigger**.
**Why:** BEFORE triggers can **modify or reject** the row before it’s written.
**Code (reject invalid priority):**

```sql
CREATE FUNCTION validate_event_priority() RETURNS TRIGGER AS $$
BEGIN
  IF NEW.priority < 0 OR NEW.priority > 10 THEN
    RETURN NULL; -- skip write for this row
  END IF;
  RETURN NEW;
END; $$ LANGUAGE plpgsql;

CREATE TRIGGER trg_event_validate
BEFORE INSERT OR UPDATE ON event
FOR EACH ROW EXECUTE FUNCTION validate_event_priority();
```

**Watch for:** Returning `NULL` from a BEFORE trigger **skips** the DML for that row.

---

### Q8 — Error during a transaction (no handler)

**Correct answer:** Transaction enters an **aborted** state; it must be **rolled back**.
**Why:** PostgreSQL protects ACID—no further commands succeed until `ROLLBACK`.
**Code (with handler in a proc):**

```sql
CREATE OR REPLACE PROCEDURE safe_action() LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO something VALUES (1);
  INSERT INTO something VALUES (1); -- unique_violation
  COMMIT; -- won't be reached
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;  -- restore consistent state
  RAISE NOTICE 'Operation failed: %', SQLERRM;
END $$;
```

**Watch for:** In plain SQL sessions, after an error you must `ROLLBACK` before continuing.

---

### Q9 — Function vs Procedure (PostgreSQL ≥ 11)

**Correct answer:** **Procedures can use transaction control (COMMIT/ROLLBACK)**.
**Why:** Functions cannot issue transaction control; procedures can (via `CALL`).
**Code:**

```sql
CREATE PROCEDURE do_work() LANGUAGE plpgsql AS $$
BEGIN
  -- do some DML
  COMMIT;   -- allowed in procedure
  -- start new unit of work
  BEGIN;
  -- more DML
  COMMIT;
END $$;

CALL do_work();
```

**Watch for:** Use functions for computations/returns; procedures for orchestration and transaction control.

---

### Q10 — Idempotency in auditing/transactions

**Correct answer:** **Repeat execution leaves the database in the same state**.
**Why:** Retries (e.g., network glitches) shouldn’t double-charge or duplicate rows.
**Patterns:**

* **Upsert (INSERT … ON CONFLICT DO NOTHING/UPDATE)**
* **Existence checks** before writes
* **Unique constraints** to prevent duplicates
  **Code (registration idempotent):**

```sql
-- Schema guard
CREATE UNIQUE INDEX uq_registration ON registration(user_id, event_id);

-- Procedure guard
CREATE OR REPLACE FUNCTION register_for_event(p_user int, p_event int)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO registration(user_id, event_id)
  VALUES (p_user, p_event)
  ON CONFLICT (user_id, event_id) DO NOTHING; -- idempotent
END $$;
```

**Watch for:** Idempotency often combines **unique keys** + **conflict handling** + **defensive logic**.

