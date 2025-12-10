### Q1 — What does `EXPLAIN` do?

**Correct:** `*Displays the query execution plan and cost estimates*`
**Why:** `EXPLAIN` shows *how* PostgreSQL plans to execute your query (node types, cost, row estimates), guiding indexing and rewrite decisions.
**Code:**

```sql
EXPLAIN
SELECT e.event_id
FROM event e
WHERE e.category_id = 3;
```

**Watch for:** Use `EXPLAIN ANALYZE` to see *actual* timings and row counts.

---

### Q2 — Benefit of an index

**Correct:** `*It speeds up data retrieval by reducing scan time*`
**Why:** Indexes provide a fast access path (e.g., btree) so the executor avoids full table scans on selective predicates.
**Code:**

```sql
CREATE INDEX idx_event_category ON event(category_id);
EXPLAIN ANALYZE
SELECT * FROM event WHERE category_id = 3;
```

**Watch for:** Low selectivity (e.g., many rows match) can still favor a Seq Scan.

---

### Q3 — Downside of too many indexes

**Correct:** `*INSERT/UPDATE/DELETE become slower due to index maintenance*`
**Why:** Every write must update each relevant index, increasing CPU, IO, and WAL volume.
**Code:**

```sql
-- Too many overlapping indexes increase write cost:
CREATE INDEX i1 ON registration(event_id);
CREATE INDEX i2 ON registration(user_id);
CREATE INDEX i3 ON registration(event_id, user_id); -- maybe redundant if queries always use composite
```

**Watch for:** Audit indexes periodically; remove unused or redundant ones.

---

### Q4 — Clustered vs non-clustered index

**Correct:** `*A clustered index determines the physical order of rows*`
**Why:** In PostgreSQL, clustering is **advisory** (via `CLUSTER`) and not maintained automatically, but it *orders the table on disk* following an index to improve locality for range scans.
**Code:**

```sql
CREATE INDEX idx_event_start ON event(start_date);
CLUSTER event USING idx_event_start;  -- one-time physical reorder
ANALYZE event;
```

**Watch for:** Re-cluster as data drifts; consider `VACUUM (FULL)`/maintenance windows.

---

### Q5 — Show plan and actual timings

**Correct:** `*EXPLAIN ANALYZE*`
**Why:** Combines the planned path with *actual* runtime metrics and row counts so you can spot misestimates and bottlenecks.
**Code:**

```sql
EXPLAIN ANALYZE
SELECT e.*
FROM event e
JOIN registration r ON r.event_id = e.event_id
WHERE r.user_id = 42;
```

**Watch for:** Large gaps between *estimated* vs *actual* rows → update stats (`ANALYZE`) or rewrite the query/index.

---

### Q6 — Meaning of Sequential Scan

**Correct:** `*The database is scanning every row in the table*`
**Why:** A Seq Scan reads the whole table; it’s fine for small tables or non-selective predicates but can be slow on large tables.
**Code:**

```sql
EXPLAIN ANALYZE
SELECT * FROM event WHERE lower(description) LIKE '%community%';
-- likely Seq Scan unless you add an index (e.g., trigram)
```

**Watch for:** Consider appropriate indexes (btree for equality/range; GIN/trigram for LIKE/search).

---

### Q7 — Covering index

**Correct:** `*An index that contains all columns needed by a query, avoiding a table lookup*`
**Why:** If all referenced columns are in the index, the executor can serve the query from the index alone (“index only scan”) when visibility map allows.
**Code:**

```sql
CREATE INDEX idx_reg_cover ON registration(user_id, event_id, registered_at);
EXPLAIN ANALYZE
SELECT user_id, event_id, registered_at
FROM registration
WHERE user_id = 42;
```

**Watch for:** `Index Only Scan` appears when table heap visits aren’t needed (visibility map must be sufficiently set).

---

### Q8 — Why batching inserts is faster

**Correct:** `*Reduces transaction overhead and network round trips*`
**Why:** Many single-row commits pay per-transaction costs; batching amortizes parsing, planning, WAL, and round-trip overhead.
**Code:**

```sql
-- Row-by-row (slower):
BEGIN;
INSERT INTO event(name, category_id) VALUES ('A',1);
INSERT INTO event(name, category_id) VALUES ('B',1);
COMMIT;

-- Batched (fewer round trips):
INSERT INTO event(name, category_id)
VALUES ('A',1), ('B',1), ('C',1), ('D',1);
```

**Watch for:** Keep batch sizes reasonable (e.g., 500–5,000) to avoid giant statements and lock time.

---

### Q9 — Parameter sniffing

**Correct:** `*Optimizer caches a plan based on first parameter values*`
**Why:** A prepared plan may be optimal for initial parameter distribution but suboptimal for later values (skew).
**Code:**

```sql
PREPARE by_user (int) AS
SELECT * FROM registration WHERE user_id = $1;

EXECUTE by_user(42);  -- plan chosen based on this selectivity
-- Later: EXECUTE by_user(999999);  -- might be very different selectivity
```

**Watch for:** Consider `EXECUTE ...` with `generic_plan` options or avoid overly broad prepared plans when data is highly skewed.

---

### Q10 — Goal of optimization

**Correct:** `*Minimize execution cost and improve performance consistency*`
**Why:** The aim is predictable, low-latency execution under real workloads, not just “fast once” but reliable across parameter sets and growth.
**Code (tuning workflow):**

```sql
-- 1) Inspect plan
EXPLAIN ANALYZE SELECT ...;

-- 2) Add/adjust index
CREATE INDEX ...;

-- 3) Re-check plan/timing
EXPLAIN ANALYZE SELECT ...;

-- 4) Consider rewrite or batching
```

**Watch for:** Optimize the *critical path*: highest frequency × highest cost queries.

---

### Extra tip for students

* After creating or clustering indexes: `ANALYZE` to refresh stats.
* Track wins with before/after timings and plans.
* Use realistic datasets (seed > small toy data) to see true plan behavior.

If you want, I can package these into a **single-page “Optimization Cheatsheet”** PDF for Weeks 9–11.
