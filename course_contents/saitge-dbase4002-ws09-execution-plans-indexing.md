![alt text](image.png)

---

## **1. Assignment Details**

| Field              | Information                                              |
| ------------------ | -------------------------------------------------------- |
| **Course Code**    | DBAS 4002                                                |
| **Course Name**    | Transactional Database Programming                       |
| **Workshop Title** | Workshop 09 – Tuning Queries: Execution Plans & Indexing |
| **Type**           | Guided Workshop (Applied Lab + Reflection)               |
| **Instructor**     | Davis Boudreau                                           |
| **Stack Used**     | DBAS PostgreSQL DevOps Stack (v3.2)                      |
| **Duration**       | 3 hours                                                  |
| **Version**        | 2.0 (Fall 2025)                                          |

---

## **2. Overview / Purpose / Objectives**

### **Context**

As transactional databases grow, query performance becomes a defining factor for scalability and user experience. In a production setting, even a single poorly optimized query can slow down an entire system.
This workshop moves beyond basic SQL logic to explore *how PostgreSQL executes queries*, *how the optimizer makes decisions*, and *how to fine-tune indexes* to achieve predictable, performant behaviour.

### **Purpose**

You will use PostgreSQL’s built-in diagnostic tools — `EXPLAIN`, `EXPLAIN ANALYZE`, and `pg_stat_activity` — to **analyze query execution plans**, understand **how indexes influence access paths**, and apply **real-world tuning techniques** inside your Dockerized PostgreSQL stack.

### **Objectives**

By the end of this lab, you will:

1. Use `EXPLAIN` and `EXPLAIN ANALYZE` to interpret query execution plans.
2. Understand sequential scans, index scans, and join strategies.
3. Create clustered, non-clustered, and covering indexes for performance improvement.
4. Compare execution times and planner decisions before and after optimization.
5. Reflect on indexing trade-offs and long-term tuning strategies.

---

## **3. Learning Outcome Addressed**

**Outcome 3 – Optimize distribution of transactional load in standalone/client-server/N-tier systems**

> Apply query optimization, indexing, and plan analysis to distribute workload efficiently and improve system performance.

---

## **4. Workshop Context / Use Case**

Continuing from your **Event Management System**, the database now supports hundreds of events and registrations. Reports and dashboards that summarize participation data are becoming slower — particularly those that aggregate by category or date.

The operations team has asked you, as a database developer, to:

* Identify *why* these queries are slow.
* Create indexes that can reduce query time without hurting insert/update performance.
* Compare “before” and “after” performance using measurable metrics.

You’ll perform all optimization directly in your **DBAS PostgreSQL DevOps Stack (v3.2)** environment, ensuring consistent results across student machines and production-like conditions.

---

## **5. Background: Query Optimization in PostgreSQL**

PostgreSQL uses a **cost-based optimizer**, which estimates the “cost” of different execution strategies and automatically selects the cheapest plan.

The optimizer’s decisions depend on:

* **Statistics** about table size and data distribution (from `ANALYZE`).
* **Available indexes** and whether they cover the needed columns.
* **Query filters, joins, and aggregations.**

When you run:

```sql
EXPLAIN ANALYZE SELECT ...;
```

PostgreSQL actually executes the query, showing:

* The chosen access path (Seq Scan, Index Scan, Nested Loop, etc.).
* Estimated vs. actual row counts.
* Execution time per step.

This visibility allows you to fine-tune performance *empirically*, instead of guessing.

---

## **6. Tools Overview**

| Tool                  | Description                                  | Usage in Workshop                             |
| --------------------- | -------------------------------------------- | --------------------------------------------- |
| **Docker Compose**    | Orchestrates PostgreSQL + pgAdmin containers | Starts the environment (`make up`)            |
| **Makefile**          | Automates common database commands           | `make psql`, `make run-queries`, `make reset` |
| **psql Shell**        | Command-line SQL client                      | Execute EXPLAIN and CREATE INDEX              |
| **pgAdmin**           | Graphical management and visualization       | Inspect plans visually                        |
| **EXPLAIN / ANALYZE** | PostgreSQL’s query plan visualization tools  | Measure and interpret optimizer behaviour     |

---

## **7. Step-by-Step Workshop Instructions**

---

### 🧭 Step 1 – Launch and Connect

**Tool:** Docker + Makefile
Start your stack and connect to PostgreSQL via the CLI.

```bash
make up
make psql
```

Confirm you’re in the correct database:

```sql
\conninfo
```

It should show:

```
You are connected to database "event_db" as user "app_user" on host "localhost"
```

Enable query timing:

```sql
\timing on
```

This will display actual query durations in milliseconds — an essential metric for performance tuning.

---

### 🧩 Step 2 – Identify a Slow Query

Let’s begin with a reporting-style query that counts the number of registrations per event.

```sql
EXPLAIN ANALYZE
SELECT e.name, COUNT(r.registration_id) AS total_registrations
FROM event e
LEFT JOIN registration r ON e.event_id = r.event_id
GROUP BY e.name
ORDER BY total_registrations DESC;
```

**Observe the plan output:**

* Do you see `Seq Scan` (Sequential Scan)?
* Are there costly `Hash Join` or `Sort` steps?
* Note the “actual time” and “rows removed by filter”.

This baseline will help you measure improvement later.

---

### ⚙️ Step 3 – Analyze the Execution Plan

**Understanding Key Plan Terms:**

| Keyword                                  | Meaning                                                            |
| ---------------------------------------- | ------------------------------------------------------------------ |
| **Seq Scan**                             | Table scanned row-by-row; slow for large data.                     |
| **Index Scan**                           | Uses an index to jump directly to matching rows.                   |
| **Index Only Scan**                      | Uses index without reading the table (if all columns are covered). |
| **Nested Loop / Hash Join / Merge Join** | Types of join algorithms; optimizer picks based on cost.           |
| **Cost Estimate**                        | Planner’s predicted cost before execution.                         |
| **Actual Time**                          | Real time measured during execution (from `ANALYZE`).              |

**Goal:** Learn to “read” the plan — it’s the database’s reasoning process.

---

### 🧱 Step 4 – Create Indexes for Key Access Paths

Indexes help PostgreSQL locate data faster but come with a trade-off: they speed up **reads** while slightly slowing **writes** (INSERT/UPDATE/DELETE).

We’ll create several types of indexes.

```sql
-- Basic B-tree indexes (default)
CREATE INDEX idx_event_dates ON event (start_date, end_date);
CREATE INDEX idx_registration_eventid ON registration (event_id);
CREATE INDEX idx_registration_participantid ON registration (participant_id);

-- Covering index: all columns used by a common query
CREATE INDEX idx_reg_cover ON registration (event_id, participant_id, payment_status);
```

**Key Concepts:**

* **Clustered Index:** Physically orders table rows on disk by index key.
* **Non-clustered Index:** Stores separate index structure referencing table rows.
* **Covering Index:** Contains all columns needed for a query, avoiding table reads.

---

### 🔍 Step 5 – Compare Query Plans Before & After

Re-run the same query:

```sql
EXPLAIN ANALYZE
SELECT e.name, COUNT(r.registration_id) AS total_registrations
FROM event e
LEFT JOIN registration r ON e.event_id = r.event_id
GROUP BY e.name
ORDER BY total_registrations DESC;
```

Now look for:

* **Index Scan** or **Index Only Scan** (instead of `Seq Scan`)
* Lower **execution cost** and **actual time**
* Fewer rows processed or removed

💡 *You can also run `ANALYZE;` before re-testing to refresh table statistics.*

---

### 🧮 Step 6 – Measure Filtered Queries

Let’s test performance with filtering — a realistic case from an admin dashboard.

```sql
EXPLAIN ANALYZE
SELECT *
FROM registration
WHERE event_id = 2
AND payment_status = 'Paid';
```

Notice how the optimizer switches between **Index Scan** and **Seq Scan** based on selectivity (the percentage of matching rows).
If too many rows match, the optimizer might *choose* a full table scan.

---

### 📈 Step 7 – Visualize with pgAdmin

**Tool:** pgAdmin → Query Tool → Execution Plan Tab

1. Go to [http://localhost:5050](http://localhost:5050)
2. Connect using your stored `servers.json` profile.
3. Open the Query Tool, paste your EXPLAIN ANALYZE query.
4. Switch to the *Execution Plan* tab to view the graphical layout — nodes, costs, joins, and I/O operations.

This visualization helps link textual plans to data flow diagrams, a skill you’ll reuse in database administration roles.

---

### 🧾 Step 8 – Cleanup, Comment, and Reflect

Once finished, clean up unused indexes:

```sql
DROP INDEX idx_registration_eventid;
DROP INDEX idx_registration_participantid;
DROP INDEX idx_event_dates;
DROP INDEX idx_reg_cover;
```

Add inline SQL comments summarizing your findings:

```sql
-- Query before index: Seq Scan  ~65ms
-- Query after index: Index Scan ~12ms
-- Improvement: 80% reduction in execution time
```

---

## **8. Deliverables**

Submit:

```
Lastname_Firstname_WS09_Query_Tuning.sql
```

Include:

* All queries tested
* EXPLAIN and EXPLAIN ANALYZE outputs as comments
* Index creation and removal commands
* Summary notes and reflections

---

## **9. Reflection Questions**

1. Why might PostgreSQL still choose a sequential scan even when an index exists?
2. How do statistics influence the query planner’s decisions?
3. What trade-offs exist between adding many indexes and maintaining write performance?
4. What scenarios benefit most from clustered or covering indexes?
5. How can indexing decisions evolve as data volume grows?

---

## **10. Assessment & Rubric (10 pts)**

| Criteria                   | Excellent (3)                    | Satisfactory (2)      | Needs Improvement (1) | Pts     |
| -------------------------- | -------------------------------- | --------------------- | --------------------- | ------- |
| Query Plan Interpretation  | Accurately reads EXPLAIN outputs | Partial understanding | Minimal explanation   | __/3    |
| Indexing Strategy          | Effective and justified          | Generic               | Misapplied            | __/3    |
| Performance Measurement    | Valid before/after comparison    | Limited evidence      | Missing data          | __/2    |
| Reflection & Documentation | Detailed and applied             | General               | Minimal               | __/2    |
| **Total**                  |                                  |                       |                       | **/10** |

---

## **11. Submission Guidelines**

* Work must be completed in the **DBAS PostgreSQL DevOps Stack (v3.2)**.
* Use the `psql` shell for queries and `pgAdmin` for visualization.
* Include `EXPLAIN ANALYZE` outputs directly in your submission as SQL comments.
* Submit via Brightspace or GitHub.

---

## **12. Resources / Equipment**

* DBAS PostgreSQL DevOps Stack (v3.2)
* PostgreSQL Docs → [Using EXPLAIN](https://www.postgresql.org/docs/current/using-explain.html)
* Docker Desktop / Compose
* pgAdmin Query Tool

---

## **13. Copyright**

© 2025 Nova Scotia Community College — For educational use only.

