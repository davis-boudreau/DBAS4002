# 🧠 **Week 5 Workshop – Summarizing Data: Aggregates & Window Functions**

---

## **1. Workshop Overview**

**Focus:** Understanding and applying **aggregate** and **window (analytic)** functions to extract insights from relational data.
**Duration:** 3 hours (guided + independent lab)
**Related Outcomes:**

* Apply SQL functions to analyze and summarize data.
* Evaluate different aggregation strategies for correctness and performance.
* Interpret grouped data to support decision-making and reporting.

---

## **2. Background & Context**

In most real-world systems, raw transactional data alone is not useful — what matters is **summarized information**: totals, averages, trends, rankings, comparisons.
For example:

* How many users registered last month?
* Which products have the highest sales per region?
* Who are the top 3 clients by revenue?

Aggregations and analytic queries enable this **transition from data to insight**.

### Core SQL Concepts

| Category                        | Function                                      | Example                                                 | Purpose                                    |
| ------------------------------- | --------------------------------------------- | ------------------------------------------------------- | ------------------------------------------ |
| **Aggregate Functions**         | `COUNT()`, `SUM()`, `AVG()`, `MIN()`, `MAX()` | `SELECT AVG(salary) FROM employees;`                    | Return one value per group                 |
| **Grouping**                    | `GROUP BY` + `HAVING`                         | `GROUP BY department_id`                                | Define groups and filter aggregates        |
| **Window (Analytic) Functions** | `OVER (PARTITION BY … ORDER BY …)`            | `RANK() OVER (PARTITION BY region ORDER BY sales DESC)` | Compute values **without collapsing rows** |

### Real-World Analytic Examples

* A web platform might use aggregation to find **monthly active users**.
* A retail business may use window functions to **rank products by sales**.
* A non-profit might calculate the **average number of volunteers per event category**.

---

## **3. Workshop Use Case: “Analyzing System Data for Insights”**

You will extend your schema (from MP1) or use the class example dataset.
Imagine your database tracks entities like **Users**, **Registrations**, **Payments**, or **Events**.
Management has asked for **insight queries** that help guide strategy and reporting.

---

## **4. Workshop Tasks**

### 🧩 **Task 1 – Explore Aggregates**

Write queries that:

1. Count total records for each main category (e.g., number of events per category).
2. Find the **average** and **maximum** of a numeric column (e.g., ticket price, duration, or amount).
3. Use `GROUP BY` with **multiple columns** (e.g., category and year).
4. Add a **HAVING clause** to filter out low-frequency groups.

🗣️ **Reflection Prompt:**

> When does it make more sense to use `HAVING` instead of `WHERE`? What happens if you switch them?

---

### ⚙️ **Task 2 – Investigate Window Functions**

Introduce **analytics within groups** without collapsing the dataset. Write queries that:

1. Rank items by value within each group using `RANK()` or `DENSE_RANK()`.
2. Compute a **running total** or **moving average** using `SUM() OVER (ORDER BY …)`.
3. Compare a value to the **group average** using a window function.

🗣️ **Reflection Prompt:**

> How does a window function differ from a standard aggregate? When would you *not* want to use one?

---

### 💡 **Task 3 – Design a “Mini Dashboard Query”**

Synthesize a single, well-formatted SQL query that produces a **report-style view** combining:

* Aggregates
* Grouped data
* One analytic function

For example:

```sql
SELECT 
    category_name,
    COUNT(event_id) AS total_events,
    AVG(duration) AS avg_duration,
    RANK() OVER (ORDER BY COUNT(event_id) DESC) AS category_rank
FROM Events
JOIN Categories USING (category_id)
GROUP BY category_name;
```

🧭 **Challenge:**

> Think like an analyst: what insights would *your client* want from this table?
> Write one paragraph explaining the business question your query answers.

---

### 🧮 **Task 4 – Reflect & Compare**

Pair up or form small groups. Discuss:

* How can grouping and ranking reveal **patterns** in data?
* Which functions were most useful, and why?
* Where could your aggregation logic break or mislead if data changes (e.g., NULLs, missing records, duplicates)?

Each student should post a **short reflection (3–4 sentences)** in the learning journal summarizing:

* What they learned about data summarization
* What they found most challenging or interesting
* One area they want to explore further (e.g., performance, BI reporting)

---

## **5. Deliverables**

By the end of the workshop, you should have:

* `week5_aggregates.sql` – Your set of aggregate and window queries.
* `week5_reflection.docx` – Your written reflections and discussion summary.

---

## **6. Evaluation (Formative)**

| Criteria | Excellent | Satisfactory | Needs Work |
|-----------|------------|---------------|
| **SQL Accuracy** | Queries run without errors and return correct results. | Minor syntax or logic issues. | Queries fail or don’t reflect intended logic. |
| **Application of Concepts** | Effective use of GROUP BY, HAVING, and at least one analytic function. | Partial understanding of grouping or windowing. | Misuse or absence of core SQL features. |
| **Reflection** | Insightful, connects technical to analytical thinking. | Superficial or descriptive only. | Missing or off-topic. |

---

## **7. Extension / Optional Challenge**

If time permits:

* Compare query runtime with and without window functions.
* Add indexes to optimize group-based queries.
* Try exporting your summary results into a CSV and visualize them (e.g., in Excel or Tableau).

---

✅ **Summary Thought:**

> Aggregates turn *data* into *information*.
> Window functions turn *information* into *insight*.
> As a database designer, your goal is to build systems that can answer *questions you haven’t even been asked yet.*

