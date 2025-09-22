# 🛡️ Week 4 Workshop: Enforcing Integrity & Business Rules with Constraints

### 🎯 Learning Objectives

By the end of this workshop, you will be able to:

* Apply **primary keys, foreign keys, and unique constraints** to enforce entity and referential integrity.
* Use **CHECK constraints** to enforce business rules at the database level.
* Understand when to enforce rules in the database vs in application code.
* Seed the database with initial data while respecting constraints.

---

## 1. Introduction (10 min)

Up to now, you’ve focused on **retrieving data**. But how do we make sure the data itself is **valid, consistent, and trustworthy**?

* **Keys** prevent duplicates.
* **Foreign keys** enforce relationships.
* **Check constraints** enforce rules (e.g., dates must make sense, values must be positive).

These constraints ensure integrity regardless of what the application does.

---

## 2. Activity A – Keys & Entity Integrity (20 min)

**Step 1. Primary Key**
Each row in a table must be uniquely identifiable.

```sql
CREATE TABLE Category (
    category_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);
```

**Step 2. Foreign Key**
An event must belong to a valid category.

```sql
CREATE TABLE Event (
    event_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    start_date DATETIME NOT NULL,
    end_date DATETIME NOT NULL,
    category_id INT NOT NULL,
    FOREIGN KEY (category_id) REFERENCES Category(category_id)
);
```

**Exercise A1:**
What would happen if you tried to insert an event with a category\_id that doesn’t exist? Test it.

**Exercise A2:**
Try deleting a category that still has events. What error do you get?

---

## 3. Activity B – Business Rules with CHECK Constraints (25 min)

**Step 1. Validating Dates**
Make sure events cannot end before they start.

```sql
ALTER TABLE Event
ADD CONSTRAINT chk_dates CHECK (end_date > start_date);
```

**Step 2. Validating Priority**
Restrict event priority to 1–5.

```sql
ALTER TABLE Event
ADD CONSTRAINT chk_priority CHECK (priority BETWEEN 1 AND 5);
```

**Exercise B1:**
Insert a row with `end_date < start_date`. What happens?

**Exercise B2:**
Add another useful check constraint for the schema (e.g., organizer name must not be empty).

---

## 4. Activity C – Seeding Data (20 min)

**Step 1. Insert Categories**

```sql
INSERT INTO Category (category_id, name)
VALUES (1, 'Workshops'),
       (2, 'Conferences'),
       (3, 'Meetups');
```

**Step 2. Insert Events**

```sql
INSERT INTO Event (event_id, name, start_date, end_date, category_id, priority)
VALUES (101, 'Database Bootcamp', '2025-10-01', '2025-10-03', 1, 2),
       (102, 'Tech Summit', '2025-11-15', '2025-11-17', 2, 3);
```

**Exercise C1:**
Insert a duplicate category name. What happens?

**Exercise C2:**
Try inserting an event without a category\_id. Why does it fail?

---

## 5. Wrap-Up & Reflection (10 min)

**Deliverable:**

* Submit:

  * Your updated schema with constraints.
  * Seed data (INSERT statements).
  * Answers to the exercises above (test cases and observed errors).
* Reflection (150–200 words):

  * Why is it better to enforce integrity rules at the database level instead of just the application level?
  * Which constraint did you find most powerful, and why?

**Looking Ahead:**
In Week 5, you’ll extend your query toolkit with **aggregation and window functions** — powerful tools for analytics and reporting.

