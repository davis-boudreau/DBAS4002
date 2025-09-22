# 📑 Mini-Project 1 (MP1): Data Model & SQL Suite

### Weight: **10% of course grade**

### Due: End of **Week 4**

---

## 🎯 Purpose

This mini-project consolidates your learning from **Weeks 1–4**. You will:

1. **Design a relational schema** based on a domain case study.
2. **Implement integrity rules** with constraints.
3. **Seed the database** with sample data.
4. **Develop a query suite** that demonstrates mastery of joins, subqueries, and set operations.

The end product is a **working database schema and SQL script package** that could serve as the foundation for a transactional system.

---

## 📂 Project Components

### Part A: Join & Subquery Suite (from Week 3)

* **3 Join queries** (INNER, LEFT, plus one other meaningful join).
* **2 Subquery-based queries** (WHERE + SELECT/correlated).
* **1 Set operation query** (UNION, INTERSECT, or EXCEPT/MINUS).
* Each query documented with **comments** + **expected result description**.

**Deliverables:**

* `mp1a_queries.sql`
* `mp1a_reflection.docx` (short reflection on join vs subquery choice, challenges, and real-world reporting use).

---

### Part B: Constraints & Seeding (from Week 4)

* **Relational schema** with:

  * Primary keys.
  * Foreign keys.
  * At least **one UNIQUE constraint**.
  * At least **two CHECK constraints** (e.g., date validation, range checks).
* **Seed data**:

  * At least 3 categories (or equivalent in your domain).
  * At least 5–10 records in a related table (e.g., events).
* **Tests** that show what happens when constraints are violated (insert invalid rows).

**Deliverables:**

* `mp1b_schema.sql` (CREATE TABLE statements + constraints).
* `mp1b_seed.sql` (INSERT statements).
* `mp1b_tests.sql` (attempts to violate constraints, with comments noting errors).
* `mp1b_reflection.docx` (short reflection: Why enforce rules in the DB instead of only in app code?).

---

## 📦 Submission Package

Submit a single zipped folder named:

```
Lastname_Firstname_MP1.zip
```

Contents:

* `mp1a_queries.sql`
* `mp1a_reflection.docx`
* `mp1b_schema.sql`
* `mp1b_seed.sql`
* `mp1b_tests.sql`
* `mp1b_reflection.docx`

---

## 📊 Evaluation Rubric (10%)

| Component                             | Marks |
| ------------------------------------- | ----- |
| **Schema correctness & constraints**  | 3     |
| **Seed data completeness & validity** | 1     |
| **Joins (3 queries)**                 | 2     |
| **Subqueries (2 queries)**            | 1.5   |
| **Set operation (1 query)**           | 0.5   |
| **Documentation & reflections**       | 2     |

Total = **10 marks**

---

## 🧭 Notes & Tips

* Use the **case study domain provided in class** (e.g., categories and events) or propose your own small domain (instructor approval required).
* Use **comments generously** in your SQL files so the marker understands your intent.
* Test your scripts on a **fresh database instance** to ensure they run cleanly from start to finish.
* Reflection pieces are short but important — they show you’re reasoning about design decisions, not just coding.

---

✅ With this, MP1 ties together Weeks 1–4 into a complete deliverable, giving students a **schema, constraints, data, and query suite** that will be expanded in MP2 with **procedures, transactions, and error handling**.
