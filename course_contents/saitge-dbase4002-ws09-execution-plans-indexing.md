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
| **Version**        | 1.0 (Fall 2025)                                          |

---

## **2. Overview / Purpose / Objectives**

Modern databases rely on **query optimizers** to decide how data is accessed and joined efficiently.
In this workshop, you’ll learn how to **analyze query execution plans**, understand **indexing strategies**, and measure the impact of performance tuning directly within your Dockerized PostgreSQL environment.

### **Purpose**

This lab introduces practical skills in **query optimization**, showing how small schema or indexing decisions can drastically improve performance and reduce system load.

### **Objectives**

* Use the `EXPLAIN` and `EXPLAIN ANALYZE` commands to interpret query execution plans.
* Differentiate between **clustered**, **non-clustered**, and **covering indexes**.
* Compare query performance before and after index creation.
* Interpret key plan operations (Seq Scan, Index Scan, Index Only Scan, Hash Join, Nested Loop).
* Reflect on indexing trade-offs between read vs write performance.

---

## **3. Learning Outcome Addressed**

**Outcome 3 – Optimize distribution of transactional load in standalone/client-server/N-tier systems**

> Analyze and tune SQL queries using indexing, query plans, and batching techniques to improve performance and scalability.

---

## **4. Workshop Context / Use Case**

You’re continuing with the **Event Management System** database in the **DBAS PostgreSQL DevOps Stack (v3.2)**.
Your schema now contains several interrelated tables such as `Event`, `Category`, `Registration`, and `Participant`.
Management has noticed that **reporting queries** are running slowly — particularly those filtering by event date or aggregating registration counts.

Your task is to:

1. Investigate slow queries using **EXPLAIN plans**.
2. Add appropriate indexes to improve performance.
3. Document and compare results before and after tuning.

---

## **5. Tools Overview**

| Tool                          | Purpose                                                        |
| ----------------------------- | -------------------------------------------------------------- |
| **Docker Compose / Makefile** | Run and manage PostgreSQL containers.                          |
| **psql Shell**                | Execute SQL queries and view execution plans.                  |
| **pgAdmin**                   | Visualize query performance metrics.                           |
| **EXPLAIN / EXPLAIN ANALYZE** | Examine PostgreSQL query optimizer decisions.                  |
| **Indexes**                   | Data structures that speed up read access to specific columns. |

---

## **6. Step-by-Step Instructions**

---

### 🧭 Step 1 – Launch Your Stack

**Tool:** Makefile + Docker Compose

```bash
make up
make psql
```

This opens the `psql` shell inside the PostgreSQL container (`mp_db`), connected to your `event_db`.
Verify your data:

```sql
\dt
SELECT COUNT(*) FROM registration;
```

---

### 📊 Step 2 – Identify a Slow Query

We’ll begin with a query that counts how many participants are registered for each event.

```sql
EXPLAIN ANALYZE
SELECT e.name, COUNT(r.registration_id) AS total_registrations
FROM event e
LEFT JOIN registration r ON e.event_id = r.event_id
GROUP BY e.name
ORDER BY total_registrations DESC;
```

### **Observe the Output:**

Look for:

* `Seq Scan` – a sequential scan over the whole table
* `HashAggregate` – grouping data using in-memory hashing
* `Sort` – final ordering step

If you see **Seq Scan** across large tables, that’s a potential candidate for indexing.

---

### ⚙️ Step 3 – Add Basic Indexes

**Tool:** PostgreSQL DDL for index creation
Let’s optimize the most common filtering and join columns.

```sql
-- Index for event lookups
CREATE INDEX idx_registration_eventid ON registration (event_id);

-- Index for participant lookups
CREATE INDEX idx_registration_participantid ON registration (participant_id);

-- Index for date-based searches
CREATE INDEX idx_event_dates ON event (start_date, end_date);
```

Each index improves lookups by creating a **B-tree** structure for faster access.

---

### 🔍 Step 4 – Compare Query Plans (Before & After)

Re-run the same query:

```sql
EXPLAIN ANALYZE
SELECT e.name, COUNT(r.registration_id) AS total_registrations
FROM event e
LEFT JOIN registration r ON e.event_id = r.event_id
GROUP BY e.name
ORDER BY total_registrations DESC;
```

Look for:

* `Index Scan` or `Index Only Scan` replacing `Seq Scan`.
* Lower **actual time** (milliseconds).
* Reduced **rows removed by filter** or **loops**.

💡 Use `\timing on` in `psql` to measure query execution time directly.

---

### 🧠 Step 5 – Explore Index Types

| Index Type              | Description                                                                          | PostgreSQL Support                                                                         |
| ----------------------- | ------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------ |
| **Clustered Index**     | Physically orders table data based on index key (PostgreSQL supports via `CLUSTER`). | ✅ `CLUSTER event USING idx_event_dates;`                                                   |
| **Non-clustered Index** | Logical structure pointing to row locations (default `CREATE INDEX`).                | ✅ Default behavior                                                                         |
| **Covering Index**      | Includes all columns needed by query, avoiding extra lookups.                        | ✅ `CREATE INDEX idx_reg_cover ON registration (event_id, participant_id, payment_status);` |

Test how each index affects plan efficiency.

---

### 🧪 Step 6 – Analyze a Filtered Query

Try running a selective query with and without indexes:

```sql
EXPLAIN ANALYZE
SELECT * FROM registration
WHERE event_id = 2
AND payment_status = 'Paid';
```

Notice the difference in **cost estimate** and **execution time**.
The optimizer uses the **index statistics** to decide when scanning the entire table is cheaper than using an index.

---

### 📈 Step 7 – Visualize in pgAdmin

**Tool:** pgAdmin Query Tool → Execution Plan tab

1. Open pgAdmin at `http://localhost:5050`
2. Connect to the server (`servers.json` auto-configured)
3. Paste the query into Query Tool → Run → click “Execution Plan” tab

This shows the graphical flow: scans, joins, and estimated row counts.

---

### 🔄 Step 8 – Clean Up & Document

If you’re finished testing, you can safely drop indexes:

```sql
DROP INDEX idx_registration_eventid;
DROP INDEX idx_registration_participantid;
DROP INDEX idx_event_dates;
```

Add comments in your SQL file:

```sql
-- Index added to improve join between Event and Registration
-- Index improved performance by reducing Seq Scan time from 65ms → 12ms
```

Then reflect:

> Which index improved performance the most, and why?

---

## **7. Deliverables**

Submit:

```
Lastname_Firstname_WS09_Query_Tuning.sql
```

including:

* Original and tuned queries
* EXPLAIN ANALYZE outputs (copied as comments)
* Index creation and removal statements
* Reflection notes at the bottom

---

## **8. Reflection Questions**

1. How does PostgreSQL decide when to use an index?
2. What’s the difference between a sequential scan and an index scan?
3. When can an index **hurt** performance?
4. How do clustered and covering indexes differ?
5. What is the trade-off between read speed and write cost?

---

## **9. Assessment & Rubric**

| Criteria                   | Excellent (3)                      | Satisfactory (2)   | Needs Improvement (1)  | Pts     |
| -------------------------- | ---------------------------------- | ------------------ | ---------------------- | ------- |
| Query Analysis             | Correctly interprets EXPLAIN plans | Minor errors       | Incomplete             | __/3    |
| Indexing Strategy          | Appropriate and tested             | Generic or partial | Missing or ineffective | __/3    |
| Performance Testing        | Measured before/after comparison   | Limited testing    | Not compared           | __/2    |
| Documentation & Reflection | Clear and analytical               | Somewhat general   | Minimal                | __/2    |
| **Total**                  |                                    |                    |                        | **/10** |

---

## **10. Submission Guidelines**

* Complete all work inside **DBAS PostgreSQL DevOps Stack (v3.2)**.
* Use `make psql` to access the containerized shell.
* Include both pre- and post-optimization EXPLAIN results as comments.
* Submit via Brightspace or GitHub.

---

## **11. Resources / Equipment**

* Docker Desktop / Compose
* DBAS PostgreSQL DevOps Stack (v3.2)
* PostgreSQL Documentation → [https://www.postgresql.org/docs/current/using-explain.html](https://www.postgresql.org/docs/current/using-explain.html)
* pgAdmin Query Tool Execution Plan tab

---

## **12. Copyright**

© 2025 Nova Scotia Community College – For educational use only.
