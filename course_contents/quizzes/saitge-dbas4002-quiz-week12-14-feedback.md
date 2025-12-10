
### Q1 — Purpose of distributing workloads across tiers

**Correct:** `*To separate concerns between application logic and database processing*`
**Why:** N-tier design isolates responsibilities: the app tier handles orchestration/validation; the DB tier enforces integrity, transactions, and set-based work. This improves scalability, security boundaries, and operability.
**Example:**

```text
Client  →  API (auth, input validation, caching)  →  DB (ACID, constraints, set-based SQL)
```

**Watch for:** Don’t push heavy set logic into the app when the DB can perform it atomically and efficiently.

---

### Q2 — What connection pooling achieves

**Correct:** `*Reuse database connections efficiently and reduce overhead*`
**Why:** Opening/closing connections is expensive. A pool (e.g., PgBouncer) keeps a small, warm set of connections for many short app requests.
**Example (PgBouncer excerpt):**

```ini
[databases]
corah = host=mp_db port=5432 dbname=corah user=appuser

[pgbouncer]
pool_mode = transaction
max_client_conn = 1000
default_pool_size = 50
```

**Watch for:** Choose `transaction` pool mode for web apps; use prepared statements carefully with pooling.

---

### Q3 — What replication is

**Correct:** `*Maintaining identical copies of data across multiple servers*`
**Why:** Streaming replicas offload reads, increase availability, and enable failover/PITR. They are near-real-time copies of the primary.
**Example (read on replica):**

```sql
-- Route analytics/reporting to replica:
SELECT * FROM event_analytics_view;  -- executed on read-replica endpoint
```

**Watch for:** Replicas are read-only; ensure your app routes ONLY reads there.

---

### Q4 — Re-analyze plans after refactor

**Correct:** `*Query rewrite might alter optimizer choices and execution paths*`
**Why:** Even “equivalent” SQL can change cardinality estimates and join orders; verify actual runtime.
**Example:**

```sql
-- Before
EXPLAIN ANALYZE
SELECT * FROM event e JOIN registration r USING(event_id) WHERE r.user_id = 42;

-- After refactor (predicate moved)
EXPLAIN ANALYZE
SELECT e.* FROM event e
JOIN (SELECT event_id FROM registration WHERE user_id = 42) r USING(event_id);
```

**Watch for:** Compare estimates vs actual rows; fix stale stats with `ANALYZE`.

---

### Q5 — Goal of refactoring stored procedures

**Correct:** `*Improve readability, maintainability, and efficiency without changing behavior*`
**Why:** Refactoring aims at clarity and performance while preserving semantics (same inputs → same outputs/effects).
**Example (extract validation):**

```sql
-- BEFORE: long monolith
-- AFTER: small helpers + main proc
CREATE FUNCTION validate_dates(s timestamptz, e timestamptz) RETURNS void AS $$
BEGIN
  IF e <= s THEN RAISE EXCEPTION 'end <= start'; END IF;
END $$ LANGUAGE plpgsql;

CREATE PROCEDURE create_event_safe(...) AS $$
BEGIN
  PERFORM validate_dates(p_start, p_end);
  -- rest of logic...
END $$ LANGUAGE plpgsql;
```

**Watch for:** Add tests before/after to guarantee behavior parity.

---

### Q6 — Drawback of sharding

**Correct:** `*Increased complexity of transactions and consistency management*`
**Why:** Cross-shard operations become distributed transactions (2PC/sagas), complicating consistency, ordering, and failure recovery.
**Example (app-level saga pattern):**

```text
Step1: INSERT reservation on shard A
Step2: INSERT inventory hold on shard B
If Step2 fails → compensate by deleting reservation on shard A
```

**Watch for:** Prefer sharding only when vertical scaling + read replicas no longer suffice.

---

### Q7 — Purpose of a read replica

**Correct:** `*To offload read queries from the primary server*`
**Why:** Move analytics/reporting/search to replicas to free primary for writes/transactions.
**Example (app routing):**

```text
WRITE DSN → primary.pg.local:5432
READ  DSN → replica.pg.local:5432
```

**Watch for:** Replica lag; avoid stale reads for pages that require strict freshness.

---

### Q8 — Why re-run `EXPLAIN ANALYZE` on production-like data

**Correct:** `*Plan selection depends on data volume and distribution*`
**Why:** Small dev datasets mask skew/selectivity. Real cardinalities can flip plan choices (e.g., Hash vs Nested Loop).
**Example:**

```sql
EXPLAIN ANALYZE
SELECT e.*
FROM event e
WHERE e.start_date >= NOW() - INTERVAL '30 days';
```

**Watch for:** Generate realistic seeds and `ANALYZE` before testing.

---

### Q9 — Code comprehension in refactoring

**Correct:** `*Understanding existing routines to safely modify or optimize them*`
**Why:** You can’t safely change what you don’t understand. Document intent, invariants, and side-effects first.
**Example (doc header):**

```sql
-- proc: register_for_event
-- intent: idempotent registration; writes audit row on success
-- invariants: (user_id, event_id) unique
-- side-effects: insert into audit_log
```

**Watch for:** Anti-patterns: duplicated logic, hidden recursion via triggers, unbounded loops.

---

### Q10 — What to prove in the showcase

**Correct:** `*Transactions, audits, and performance hold under concurrent load*`
**Why:** A production-grade system isn’t just “working”—it’s safe, traceable, and performant when many users act at once.
**Example (two psql sessions):**

```sql
-- Session A
BEGIN; UPDATE event SET priority = 9 WHERE event_id = 1001;

-- Session B
EXPLAIN ANALYZE SELECT * FROM event WHERE event_id = 1001; -- observe locks/waits
```

**Watch for:** Demonstrate: (1) ACID under contention, (2) audit entries for writes, (3) tuned plans and stable latencies.

---

**Instructor tip:** Ask students to attach **before/after EXPLAIN plans**, **replica routing evidence**, and a **refactor diff** (with unit tests) in their Week 14 showcase so you can quickly verify all three dimensions: **distribution**, **refactor quality**, and **operational performance**.
