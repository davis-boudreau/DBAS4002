# 🔗 Week 3 Workshop: Combining Data with Joins, Subqueries & Set Operations

### 🎯 Learning Objectives

By the end of this workshop, you will be able to:

* Retrieve data across multiple related tables using different types of **JOINs**.
* Use **subqueries** (nested queries) effectively in `WHERE`, `FROM`, and `SELECT` clauses.
* Apply **set operations** (`UNION`, `INTERSECT`, `EXCEPT`) to combine results.
* Decide when to use a **join vs subquery** for clarity and efficiency.

---

## 1. Introduction (10 min)

In real-world systems, data is almost never in a single table. You’ll often need to **combine rows across multiple related tables**. Today we explore:

* **Joins** → bring related data side by side.
* **Subqueries** → filter or calculate with a query inside another.
* **Set operations** → stack results on top of each other.

Think of joins as *horizontal combination* (adding columns), and set ops as *vertical combination* (adding rows).

---

## 2. Activity A – Practice with Joins (25 min)

**Step 1. INNER JOIN**
Retrieve all events and their categories.

```sql
SELECT e.name AS event_name,
       c.name AS category_name,
       e.start_date, e.end_date
FROM Event e
JOIN Category c ON e.category_id = c.category_id;
```

**Exercise A1:**
Modify the query to show only events from a chosen category.

**Step 2. LEFT JOIN**
Show all categories, even those with no events.

```sql
SELECT c.name AS category_name,
       e.name AS event_name
FROM Category c
LEFT JOIN Event e ON c.category_id = e.category_id;
```

**Exercise A2:**
How would the result change if we used an INNER JOIN instead?

**Step 3. RIGHT & FULL JOIN (optional)**
Explore databases that support RIGHT/FULL JOIN. Compare results with LEFT JOIN.

---

## 3. Activity B – Subqueries (25 min)

**Step 1. Subquery in WHERE**
Find events that belong to the category “Workshops”.

```sql
SELECT name, start_date
FROM Event
WHERE category_id = (
    SELECT category_id FROM Category WHERE name = 'Workshops'
);
```

**Exercise B1:**
Write a query to list all categories that **have at least one event**. Use a subquery in the `WHERE EXISTS` form.

**Step 2. Subquery in SELECT**
Show each category with the **count of its events**.

```sql
SELECT c.name,
       (SELECT COUNT(*) 
        FROM Event e 
        WHERE e.category_id = c.category_id) AS event_count
FROM Category c;
```

**Exercise B2:**
Rewrite this query using `JOIN + GROUP BY`. Compare results. Which one do you prefer?

---

## 4. Activity C – Set Operations (20 min)

**Step 1. UNION**
Find all organizers and all categories (two different domains), combine them in one list.

```sql
SELECT organizer AS name FROM Event
UNION
SELECT name FROM Category;
```

**Step 2. INTERSECT (if supported)**
Find all names that appear **both as organizers and as categories**.

**Step 3. EXCEPT / MINUS**
Find all organizers who are **not also a category name**.

**Exercise C1:**
Suggest a realistic use case for UNION in a business database context.

---

## 5. Wrap-Up & Reflection (10 min)

**Deliverable:**

* Submit:

  * 3 join queries (INNER, LEFT, and one of your choice).
  * 2 subquery-based queries.
  * 1 set operation query.
* Write a short reflection (150 words):

  * When would you prefer a subquery over a join?
  * Which set operation felt most useful in practice?

**Looking Ahead:**
In Week 4, we’ll move from querying to **data integrity & business rules** using constraints, keys, and checks.

