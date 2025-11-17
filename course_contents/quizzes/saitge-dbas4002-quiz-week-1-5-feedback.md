### **Question 1**

**Question:** Which SQL command defines a new table’s structure?
**Correct Answer:** `CREATE TABLE`

**Background:**
SQL (Structured Query Language) includes a family of commands known as **Data Definition Language (DDL)** used to create or modify the structure of database objects. The key DDL commands are `CREATE`, `ALTER`, and `DROP`.

**Feedback Explanation:**
✅ **Correct –** `CREATE TABLE` builds a new table by defining its columns, data types, and constraints.
Other commands such as `INSERT` and `UPDATE` only manipulate existing data; they don’t define structure.

---

### **Question 2**

**Question:** What is the primary key’s main purpose?
**Correct Answer:** Ensure each row is uniquely identifiable

**Background:**
A **primary key** uniquely identifies every record in a table. It prevents duplicate entries and guarantees that each row can be referenced by other tables using a **foreign key** relationship.

**Feedback Explanation:**
✅ **Correct –** Primary keys enforce **entity integrity** by ensuring that each record is unique and non-NULL.
They are essential for relational joins and maintaining consistency across database relationships.

---

### **Question 3**

**Question:** Which constraint prevents duplicate email addresses in a table?
**Correct Answer:** `UNIQUE`

**Background:**
A **UNIQUE constraint** ensures that all values in a column (or combination of columns) are distinct.
It’s commonly applied to fields like `email`, `student_id`, or `license_number`.

**Feedback Explanation:**
✅ **Correct –** The `UNIQUE` constraint disallows duplicates while still permitting a single NULL value.
Use it when you want to ensure uniqueness without necessarily making a column the table’s primary key.

---

### **Question 4**

**Question:** In a relational schema, what ensures referential integrity?
**Correct Answer:** `FOREIGN KEY`

**Background:**
**Referential integrity** means that relationships between tables remain valid: every child record references an existing parent record. A **FOREIGN KEY** enforces this rule automatically.

**Feedback Explanation:**
✅ **Correct –** A `FOREIGN KEY` constraint links two tables and prevents invalid references.
For example, each registration’s `event_id` must exist in the `event` table; otherwise, the database rejects the insert.

---

### **Question 5**

**Question:** Which SQL clause filters rows after aggregation?
**Correct Answer:** `HAVING`

**Background:**
In SQL, **WHERE** filters rows **before** grouping occurs, while **HAVING** filters **after** the `GROUP BY` aggregation is computed.
This distinction matters when working with functions like `COUNT()`, `SUM()`, or `AVG()`.

**Feedback Explanation:**
✅ **Correct –** The `HAVING` clause applies conditions to grouped results, such as

```sql
SELECT category_id, COUNT(*)  
FROM event  
GROUP BY category_id  
HAVING COUNT(*) > 3;
```

Using `WHERE` here would cause an error because `WHERE` cannot reference aggregate results.

---

### **Question 6**

**Question:** What is the result of a LEFT JOIN?
**Correct Answer:** All rows from the left table plus matches from the right

**Background:**
In SQL, **JOINs** combine data from multiple tables.
A **LEFT JOIN** returns every row from the *left* table, even if there are no matching rows in the right table. Non-matching rows from the right side appear as `NULL`.

**Feedback Explanation:**
✅ **Correct –** The LEFT JOIN keeps all data from the left-hand table, inserting NULLs for unmatched rows on the right.
For example, listing all events and showing registrations (if any) ensures that even unregistered events appear in the result.

---

### **Question 7**

**Question:** Which statement removes a table and its structure?
**Correct Answer:** DROP TABLE

**Background:**
SQL provides **Data Definition Language (DDL)** commands for modifying database objects.

* `DELETE` removes data but keeps the table.
* `TRUNCATE` clears all rows but preserves the schema.
* `DROP TABLE` completely deletes the table and its definition.

**Feedback Explanation:**
✅ **Correct –** `DROP TABLE` permanently deletes the table structure, indexes, and constraints.
Use this carefully, as it cannot be rolled back once committed in most production environments.

---

### **Question 8**

**Question:** What does “normalization” primarily aim to reduce?
**Correct Answer:** Data redundancy

**Background:**
**Normalization** is a database design technique that organizes data into related tables to eliminate duplication and ensure logical consistency.
It uses **normal forms (1NF, 2NF, 3NF, etc.)** to achieve a structure where each fact is stored only once.

**Feedback Explanation:**
✅ **Correct –** Normalization minimizes redundancy by separating data into distinct, logically connected tables.
This prevents inconsistencies — for example, ensuring a participant’s email is stored in only one place, even if they register for multiple events.

---

### **Question 9**

**Question:** Which SQL function returns the total number of rows?
**Correct Answer:** COUNT()

**Background:**
SQL’s **aggregate functions** (e.g., `SUM()`, `AVG()`, `COUNT()`, `MIN()`, `MAX()`) perform operations over sets of rows.
`COUNT()` is unique because it returns the number of rows or non-NULL values, depending on usage.

**Feedback Explanation:**
✅ **Correct –** `COUNT()` is used to measure volume — for example, counting total participants or total registrations per category.
Syntax example:

```sql
SELECT COUNT(*) FROM registration;
```

returns the total number of rows in the table.

---

### **Question 10**

**Question:** In PostgreSQL, what does a CHECK constraint do?
**Correct Answer:** Restricts column values to specific conditions

**Background:**
A **CHECK constraint** enforces a rule for acceptable data in a column.
It ensures that inserted or updated values meet logical conditions — for instance, enforcing valid ranges or relationships between columns.

**Feedback Explanation:**
✅ **Correct –** `CHECK` constraints ensure logical correctness, such as confirming that an event’s `end_date` is after its `start_date`.
Example:

```sql
ALTER TABLE event 
ADD CONSTRAINT chk_event_dates CHECK (end_date > start_date);
```

This guards against invalid business logic being inserted into the database.

---

Excellent — here are the **Brightspace-style feedback explanations** for **Questions 11–15**, continuing the consistent structure: *Background → Correct Answer → Feedback Explanation*.

These align with **Weeks 2–3** topics: joins, unions, filters, and query ordering from your DBAS 4002 (Weeks 1–5) module sequence.

---

### **Question 11**

**Question:** Which keyword combines query results and removes duplicates?
**Correct Answer:** `UNION`

**Background:**
When combining results from multiple queries, SQL offers two options — `UNION` and `UNION ALL`.
`UNION` merges the outputs and **automatically removes duplicates**, while `UNION ALL` retains every row, even if identical.

**Feedback Explanation:**
✅ **Correct –** `UNION` returns a distinct combined result set.
Example:

```sql
SELECT email FROM participant
UNION
SELECT email FROM organizer;
```

This query removes any duplicate email addresses appearing in both lists. Use `UNION ALL` when duplicates are intentionally required for performance or reporting.

---

### **Question 12**

**Question:** What is the purpose of an alias in SQL?
**Correct Answer:** Give a temporary name to a column or table

**Background:**
An **alias** lets you rename a table or column *temporarily* within a query for readability, especially when joining multiple tables or formatting output.
Aliases do not change schema names — they only exist during query execution.

**Feedback Explanation:**
✅ **Correct –** An alias improves clarity and helps avoid ambiguity when different tables contain similar column names.
Example:

```sql
SELECT e.name AS event_name, c.name AS category_name
FROM event e
JOIN category c ON e.category_id = c.category_id;
```

Here, `e` and `c` act as short, meaningful aliases for table names.

---

### **Question 13**

**Question:** Which command displays query execution details in PostgreSQL?
**Correct Answer:** `EXPLAIN ANALYZE`

**Background:**
PostgreSQL’s **query planner** estimates the best way to execute a query.
`EXPLAIN` shows this plan, while `EXPLAIN ANALYZE` **executes** the query and provides real timing and cost metrics — essential for optimization and performance tuning.

**Feedback Explanation:**
✅ **Correct –** `EXPLAIN ANALYZE` is a performance diagnostic tool. It shows which operations (e.g., Seq Scan, Index Scan) were used and how long each took.
Example:

```sql
EXPLAIN ANALYZE SELECT * FROM registration WHERE payment_status = 'Paid';
```

Use this to identify queries needing indexes or refactoring.

---

### **Question 14**

**Question:** Which type of join returns rows that match on both sides only?
**Correct Answer:** INNER JOIN

**Background:**
An **INNER JOIN** retrieves only the rows where the join condition is true in both tables.
If no match exists in either table, that row is excluded from the result.

**Feedback Explanation:**
✅ **Correct –** The `INNER JOIN` produces results where the join key values appear in both tables.
Example:

```sql
SELECT p.first_name, e.name
FROM participant p
INNER JOIN registration r ON p.participant_id = r.participant_id
INNER JOIN event e ON e.event_id = r.event_id;
```

This shows only participants registered for events — unmatched participants are excluded.

---

### **Question 15**

**Question:** Which clause orders query results alphabetically by event name?
**Correct Answer:** `ORDER BY event_name ASC`

**Background:**
`ORDER BY` arranges result sets in ascending (`ASC`) or descending (`DESC`) order.
By default, ascending order (`ASC`) sorts alphabetically for text columns or from smallest to largest for numbers.

**Feedback Explanation:**
✅ **Correct –** The `ORDER BY` clause sorts query output for presentation and readability.
Example:

```sql
SELECT name, start_date
FROM event
ORDER BY name ASC;
```

The `ASC` keyword is optional since ascending order is the default.
For reverse order, use `DESC`.

---

Excellent — here’s the **Brightspace-ready feedback** for **Questions 16 – 20**, continuing in the same clear, pedagogically rich format used earlier.
Each question includes the **correct answer**, a concise **background section**, and an **explanation** suitable for automatic feedback.

---

### **Question 16**

**Question:** What is the difference between a view and a table?
**Correct Answer:** A view is a saved query that doesn’t store data itself

**Background:**
A **table** physically stores data on disk. A **view**, by contrast, is a *virtual table* based on a query result. It doesn’t hold its own data; instead, it displays live results drawn from one or more base tables each time it’s queried.

**Feedback Explanation:**
✅ **Correct –** Views act like reusable queries that simplify complex joins or filters. They provide security and consistency by allowing users to query pre-defined logic without altering source data.
Example:

```sql
CREATE VIEW event_summary AS
SELECT category_id, COUNT(*) AS total_events
FROM event
GROUP BY category_id;
```

Each time `SELECT * FROM event_summary;` runs, PostgreSQL re-executes the underlying query.

---

### **Question 17**

**Question:** Which SQL keyword ensures no NULL values in a column?
**Correct Answer:** NOT NULL

**Background:**
The **NOT NULL** constraint enforces **entity integrity** by requiring a value for each record in that column. It’s commonly used for fields that must always have content, such as `event_name` or `category_id`.

**Feedback Explanation:**
✅ **Correct –** `NOT NULL` prevents missing data where values are required for business logic.
Example:

```sql
CREATE TABLE category (
  category_id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL
);
```

This guarantees that every category must have a name before insertion.

---

### **Question 18**

**Question:** What command permanently saves all changes in a transaction?
**Correct Answer:** COMMIT

**Background:**
PostgreSQL executes commands inside transactions by default.
A transaction groups operations into a single unit of work. When you issue `COMMIT`, all pending changes become permanent. If you issue `ROLLBACK`, they are undone.

**Feedback Explanation:**
✅ **Correct –** `COMMIT` finalizes a transaction and ensures durability (the “D” in ACID).
Example:

```sql
BEGIN;
UPDATE registration SET payment_status = 'Paid' WHERE registration_id = 10;
COMMIT;
```

If no errors occur, the payment update is permanently saved.

---

### **Question 19**

**Question:** In a Dockerized PostgreSQL environment, which tool lets you access SQL directly?
**Correct Answer:** psql shell inside the container

**Background:**
The **psql** shell is PostgreSQL’s command-line interface (CLI). Within the Dockerized DevOps stack, you can access it by executing `make psql`, which connects you directly to the running PostgreSQL container.

**Feedback Explanation:**
✅ **Correct –** The `psql` shell provides full SQL access from inside Docker, allowing you to execute scripts, test transactions, and manage schema changes.
Example workflow:

```bash
make up
make psql
```

This launches containers and drops you into an authenticated PostgreSQL session.

---

### **Question 20**

**Question:** What’s the purpose of using a FOREIGN KEY … ON DELETE CASCADE rule?
**Correct Answer:** Automatically removes dependent rows when a parent is deleted

**Background:**
`FOREIGN KEY` constraints maintain **referential integrity** between parent and child tables. The `ON DELETE CASCADE` option extends this by instructing PostgreSQL to automatically remove child records when their parent record is deleted.

**Feedback Explanation:**
✅ **Correct –** `ON DELETE CASCADE` ensures data consistency by preventing orphaned rows.
Example:

```sql
ALTER TABLE registration
ADD CONSTRAINT fk_registration_event
FOREIGN KEY (event_id)
REFERENCES event(event_id)
ON DELETE CASCADE;
```

If an event is removed, all related registrations are deleted automatically, keeping the database consistent.

---

Excellent — here’s the continuation of your **Brightspace quiz feedback explanations** for **Questions 21–25**, formatted consistently with your earlier sets (background → correct answer → feedback).
These cover aggregate logic, performance thinking, and schema relationships introduced by Week 5.

---

### **Question 21**

**Question:** What does the GROUP BY clause do?
**Correct Answer:** Groups rows that share common column values

**Background:**
The `GROUP BY` clause organizes rows that have the same values in one or more columns into groups so that aggregate functions (`COUNT()`, `SUM()`, `AVG()`, etc.) can be applied to each group. It’s essential for generating summary information such as totals per category or averages per event.

**Feedback Explanation:**
✅ **Correct –** `GROUP BY` collapses duplicate keys into one representative row per group, enabling aggregation.
Example:

```sql
SELECT category_id, COUNT(*) AS total_events
FROM event
GROUP BY category_id;
```

Each category_id value becomes its own group, showing total events in that category.

---

### **Question 22**

**Question:** Which aggregate function returns the highest numeric value?
**Correct Answer:** `MAX()`

**Background:**
Aggregate functions perform calculations over a set of rows. `MAX()` finds the largest value in a column, while `MIN()` finds the smallest. They are used for summarizing numeric or date values, such as the latest event date or highest priority.

**Feedback Explanation:**
✅ **Correct –** `MAX()` returns the largest value in the selected column.
Example:

```sql
SELECT MAX(priority) AS highest_priority FROM event;
```

This helps identify top-priority events or the most recent date in a dataset.

---

### **Question 23**

**Question:** Which SQL keyword combines two result sets and keeps all duplicates?
**Correct Answer:** `UNION ALL`

**Background:**
When merging results from multiple queries, `UNION` eliminates duplicates automatically, whereas `UNION ALL` includes every row returned from each query—even identical ones. `UNION ALL` is often faster because it skips duplicate checking.

**Feedback Explanation:**
✅ **Correct –** `UNION ALL` preserves duplicates and can improve performance.
Example:

```sql
SELECT participant_id FROM registration_2024
UNION ALL
SELECT participant_id FROM registration_2025;
```

Both sets are merged exactly as returned, maintaining any overlapping participant IDs.

---

### **Question 24**

**Question:** In the Event Management schema, which field in the Event table references the Category table?
**Correct Answer:** `category_id`

**Background:**
A **foreign-key column** connects one table to another. In this case, each event belongs to a category, and the relationship is established through the `category_id` column in the `event` table that references `category.category_id`.

**Feedback Explanation:**
✅ **Correct –** `category_id` enforces referential integrity between `event` and `category`.
Example:

```sql
ALTER TABLE event
ADD CONSTRAINT fk_event_category
FOREIGN KEY (category_id)
REFERENCES category(category_id);
```

Deleting or modifying a category automatically affects linked events based on the defined cascade rules.

---

### **Question 25**

**Question:** When analyzing performance, what does an execution plan show?
**Correct Answer:** How the database will access and join data

**Background:**
An **execution plan** is PostgreSQL’s internal roadmap for how it intends to retrieve query results—whether by sequential scan, index scan, hash join, or merge join. Understanding it is key to query tuning and performance optimization.

**Feedback Explanation:**
✅ **Correct –** The execution plan reveals which operations the optimizer chooses and their estimated costs.
Example:

```sql
EXPLAIN ANALYZE
SELECT * FROM registration WHERE payment_status = 'Paid';
```

This displays how the query is executed step-by-step and how long each stage takes, helping identify bottlenecks and indexing opportunities.

---

Excellent — here are the **Brightspace-ready feedback explanations** for **Questions 26–30**, continuing from your previous quiz sections.
Each question includes the **correct answer**, **background context**, and **learner feedback explanation** — written in an instructor voice for automated feedback clarity.

---

### **Question 26**

**Question:** What does the keyword `DISTINCT` do in a SELECT statement?
**Correct Answer:** Removes duplicate rows from the output

**Background:**
When querying data, duplicate rows may appear if multiple records share identical column values.
The `DISTINCT` keyword ensures that only **unique combinations** of the selected columns are returned in the result set.

**Feedback Explanation:**
✅ **Correct –** `DISTINCT` filters duplicates from your results.
Example:

```sql
SELECT DISTINCT category_id FROM event;
```

If several events share the same category, each category appears only once. This is useful in reporting and summary queries.

---

### **Question 27**

**Question:** Which SQL clause determines how rows are grouped for aggregate calculations?
**Correct Answer:** `GROUP BY`

**Background:**
The `GROUP BY` clause organizes data into groups based on one or more columns.
It is essential when using aggregate functions such as `COUNT()`, `AVG()`, or `SUM()` to summarize grouped data — for example, counting registrations per event.

**Feedback Explanation:**
✅ **Correct –** `GROUP BY` defines how aggregation results are separated by key.
Example:

```sql
SELECT event_id, COUNT(*) 
FROM registration
GROUP BY event_id;
```

Each event_id becomes its own group, producing a count per event.

---

### **Question 28**

**Question:** In an ER diagram, what does a crow’s-foot symbol typically represent?
**Correct Answer:** One-to-many relationship

**Background:**
Entity-Relationship (ER) diagrams visualize how entities (tables) relate to one another.
The **crow’s-foot notation** represents cardinality: one record in one table is linked to multiple records in another — for example, *one category has many events.*

**Feedback Explanation:**
✅ **Correct –** A crow’s-foot symbolizes a one-to-many relationship.
Example:

```
CATEGORY ───< EVENT
```

This notation means one category (left side) connects to many events (right side). It’s foundational to relational design.

---

### **Question 29**

**Question:** What does the PostgreSQL command `\dt` display in psql?
**Correct Answer:** A list of all tables in the current schema

**Background:**
Inside the **psql shell**, backslash commands (known as *meta-commands*) allow users to explore the database.
`\dt` lists all visible tables in the current schema, helping developers confirm that initialization scripts ran successfully.

**Feedback Explanation:**
✅ **Correct –** `\dt` is a quick way to view table names and ownership.
Example output might include:

```
List of relations
 Schema | Name      | Type  | Owner
--------+-----------+-------+-------
 public | event     | table | app_user
 public | category  | table | app_user
```

Use it after running your `/sql/00_init` scripts to confirm all tables were created.

---

### **Question 30**

**Question:** What is the main advantage of using Docker Compose for PostgreSQL labs?
**Correct Answer:** It standardizes the environment across student machines

**Background:**
**Docker Compose** automates the setup of multi-container environments (e.g., PostgreSQL + pgAdmin).
It ensures every student runs the same software version, configuration, and networking setup — preventing “it works on my machine” issues during labs.

**Feedback Explanation:**
✅ **Correct –** Docker Compose ensures consistent, reproducible environments across Windows, macOS, and Linux.
Using your Makefile and `.env` files, every student launches the same stack with one command:

```bash
make up
```

This eliminates manual setup errors and guarantees uniformity for database teaching and DevOps training.

---

Perfect — here’s the **Brightspace-style feedback** for **Questions 31–35**, continuing the same structured, instructional format used for earlier sets.
These questions draw from the Week 2–4 content: query structure, combining data, logical execution order, and DDL/DML best practices.

---

### **Question 31**

**Question:** Which keyword limits the number of rows returned in PostgreSQL?
**Correct Answer:** `LIMIT`

**Background:**
PostgreSQL allows developers to control result size with `LIMIT`. This is particularly useful for testing queries, previewing data, or paginating results in web applications.

**Feedback Explanation:**
✅ **Correct –** `LIMIT` restricts how many rows are displayed from a query result.
Example:

```sql
SELECT * FROM event LIMIT 5;
```

This returns only the first 5 events, even if the table contains hundreds of rows. It’s a crucial feature for performance when working with large datasets.

---

### **Question 32**

**Question:** What keyword is used to combine rows from two queries including duplicates?
**Correct Answer:** `UNION ALL`

**Background:**
`UNION` and `UNION ALL` both merge result sets, but `UNION ALL` keeps duplicates.
This is ideal when duplicates represent meaningful events—such as repeated participation or recurring bookings—rather than redundant data.

**Feedback Explanation:**
✅ **Correct –** `UNION ALL` combines results without removing identical rows.
Example:

```sql
SELECT participant_id FROM registration_2024
UNION ALL
SELECT participant_id FROM registration_2025;
```

All participant IDs appear, even if they exist in both years.

---

### **Question 33**

**Question:** Which SQL clause is evaluated first in a query’s logical order of execution?
**Correct Answer:** `FROM`

**Background:**
Although SQL queries are *written* starting with `SELECT`, the database actually executes them in a logical order:
`FROM` → `WHERE` → `GROUP BY` → `HAVING` → `SELECT` → `ORDER BY`.
Understanding this helps troubleshoot filtering and aggregation issues.

**Feedback Explanation:**
✅ **Correct –** The `FROM` clause executes first, defining which tables and joins supply data.
For instance:

```sql
SELECT e.name, c.name
FROM event e
JOIN category c ON e.category_id = c.category_id;
```

Here, the system first resolves `FROM` and `JOIN` before evaluating `SELECT`.

---

### **Question 34**

**Question:** What is the function of the DEFAULT constraint?
**Correct Answer:** Provides an automatic value when none is supplied

**Background:**
The **DEFAULT** constraint assigns a predefined value to a column when no explicit value is provided in an `INSERT`.
This improves usability and consistency, ensuring fields such as `priority` or `status` always contain a meaningful default.

**Feedback Explanation:**
✅ **Correct –** DEFAULT automates data entry by filling blank fields with preset values.
Example:

```sql
CREATE TABLE event (
  event_id SERIAL PRIMARY KEY,
  priority INTEGER DEFAULT 1
);
```

If no `priority` is given, PostgreSQL assigns `1` automatically, maintaining consistent data integrity.

---

### **Question 35**

**Question:** What type of join includes all rows from both tables, matching where possible?
**Correct Answer:** `FULL OUTER JOIN`

**Background:**
`FULL OUTER JOIN` returns every row from both tables, filling unmatched columns with `NULL`.
It’s useful for identifying discrepancies—such as items that exist in one table but not the other.

**Feedback Explanation:**
✅ **Correct –** `FULL OUTER JOIN` combines the results of `LEFT` and `RIGHT JOIN`.
Example:

```sql
SELECT c.name, e.name
FROM category c
FULL OUTER JOIN event e
ON c.category_id = e.category_id;
```

This returns all categories and all events, even those that don’t align. It’s valuable for auditing or synchronization analysis.

---

Excellent — here are the **Brightspace-style feedback explanations** for **Questions 36–40**, continuing the same structured approach.
These connect to Week 4–5 workshop concepts on table management, aggregation, constraints, and PostgreSQL data types.

---

### **Question 36**

**Question:** What statement permanently removes all rows from a table but keeps its structure?
**Correct Answer:** `TRUNCATE TABLE`

**Background:**
`TRUNCATE TABLE` is a **Data Definition Language (DDL)** command that deletes every record from a table instantly while preserving the table’s schema, indexes, and constraints. It is faster than `DELETE FROM` because it doesn’t log each row deletion individually.

**Feedback Explanation:**
✅ **Correct –** `TRUNCATE TABLE` clears data but keeps the table for reuse.
Example:

```sql
TRUNCATE TABLE registration RESTART IDENTITY;
```

This resets the auto-increment counter and empties all rows — useful for resetting a lab database between test runs.

---

### **Question 37**

**Question:** What does an aggregate function operate on?
**Correct Answer:** Sets of rows to produce a single result value

**Background:**
Aggregate functions compute a **summary value** (such as totals or averages) across multiple rows. Common aggregates include `COUNT()`, `SUM()`, `AVG()`, `MIN()`, and `MAX()`. They are typically used with `GROUP BY` to summarize grouped data.

**Feedback Explanation:**
✅ **Correct –** Aggregate functions collapse many rows into one meaningful result.
Example:

```sql
SELECT category_id, COUNT(*) AS total_events
FROM event
GROUP BY category_id;
```

Each category produces one row containing its total number of events.

---

### **Question 38**

**Question:** Which SQL function returns the average of numeric values?
**Correct Answer:** `AVG()`

**Background:**
`AVG()` calculates the mean of a column’s numeric values. It ignores `NULL` values, making it ideal for calculating averages such as attendance rates or registration fees.

**Feedback Explanation:**
✅ **Correct –** `AVG()` returns the average of a set of numbers.
Example:

```sql
SELECT AVG(priority) AS avg_priority FROM event;
```

If `priority` represents event importance (1–5), this gives an overall average across all events.

---

### **Question 39**

**Question:** Which constraint ensures that an event’s end date occurs after its start date?
**Correct Answer:** `CHECK`

**Background:**
A **CHECK** constraint enforces business logic by validating column values against a condition. It helps preserve **data integrity** by preventing illogical or invalid values from being stored.

**Feedback Explanation:**
✅ **Correct –** A `CHECK` constraint verifies that data obeys logical rules.
Example:

```sql
ALTER TABLE event
ADD CONSTRAINT chk_event_dates CHECK (end_date > start_date);
```

This prevents any record from being inserted or updated with an invalid date range.

---

### **Question 40**

**Question:** In PostgreSQL, which data type stores long text such as event descriptions?
**Correct Answer:** `TEXT`

**Background:**
PostgreSQL provides several character data types: `CHAR(n)` for fixed-length strings, `VARCHAR(n)` for variable-length strings with a limit, and `TEXT` for unlimited-length text. The `TEXT` type efficiently handles large blocks of narrative or description fields.

**Feedback Explanation:**
✅ **Correct –** Use `TEXT` when you need to store large, flexible content like descriptions or comments.
Example:

```sql
CREATE TABLE event (
  event_id SERIAL PRIMARY KEY,
  description TEXT
);
```

Unlike `VARCHAR`, `TEXT` doesn’t require a maximum length and is ideal for unbounded content.

---

Excellent — here’s the next set of **Brightspace-style feedback explanations** for **Questions 41 – 45**, keeping the same structured, educational format.
These questions align with **Week 4 – 5** learning objectives: relationships, system functions, filtering logic, and hands-on use of the psql environment within the **DBAS PostgreSQL DevOps Stack (v3.2)**.

---

### **Question 41**

**Question:** What keyword is used to create a relationship between two tables?
**Correct Answer:** `FOREIGN KEY`

**Background:**
A **FOREIGN KEY** constraint links data between two tables by referencing a column in the parent table. It ensures that a value in the child table must exist in the parent table, maintaining referential integrity.

**Feedback Explanation:**
✅ **Correct –** `FOREIGN KEY` defines relational links and enforces data consistency.
Example:

```sql
CREATE TABLE event (
  event_id SERIAL PRIMARY KEY,
  category_id INT,
  FOREIGN KEY (category_id)
    REFERENCES category(category_id)
);
```

This guarantees that every event refers to a valid category record. It’s fundamental to relational database design.

---

### **Question 42**

**Question:** Which PostgreSQL function returns the current system date and time?
**Correct Answer:** `CURRENT_TIMESTAMP`

**Background:**
PostgreSQL offers several date/time functions, including `NOW()` and `CURRENT_TIMESTAMP`. Both return the current transaction’s date and time, but `CURRENT_TIMESTAMP` is the SQL-standard form and is preferred for portability.

**Feedback Explanation:**
✅ **Correct –** `CURRENT_TIMESTAMP` returns the exact time a statement begins executing.
Example:

```sql
SELECT CURRENT_TIMESTAMP;
```

This is often used to timestamp records, such as logging when a new event or transaction occurs.

---

### **Question 43**

**Question:** When executing a multi-table query, which operator specifies the linking condition?
**Correct Answer:** `ON`

**Background:**
When performing joins, the `ON` keyword defines the condition that connects two tables—usually matching a primary key in one table to a foreign key in another.

**Feedback Explanation:**
✅ **Correct –** The `ON` clause tells the database how the tables relate.
Example:

```sql
SELECT e.name, c.name
FROM event e
JOIN category c ON e.category_id = c.category_id;
```

Without `ON`, the database would produce a Cartesian product—pairing every row from one table with every row from another.

---

### **Question 44**

**Question:** Which clause restricts rows *before* aggregation takes place?
**Correct Answer:** `WHERE`

**Background:**
In query execution order, `WHERE` filters rows before grouping or aggregation occurs, whereas `HAVING` filters after aggregation. Understanding the difference ensures accurate query logic and results.

**Feedback Explanation:**
✅ **Correct –** `WHERE` filters raw rows prior to grouping.
Example:

```sql
SELECT category_id, COUNT(*)
FROM event
WHERE priority > 2
GROUP BY category_id;
```

Only events with a priority above 2 are included in the count. Using `HAVING` here would cause a logic or execution-order error.

---

### **Question 45**

**Question:** What does `\i /sql/03_seed.sql` do inside psql?
**Correct Answer:** Executes the SQL commands from the seed file

**Background:**
The `\i` (include) meta-command in psql runs a script file directly inside the PostgreSQL shell. It’s commonly used in the **DBAS PostgreSQL DevOps Stack** to seed or populate a database after initialization.

**Feedback Explanation:**
✅ **Correct –** `\i` executes an external SQL script file as if you typed each command manually.
Example:

```
\i /sql/03_seed.sql
```

This runs all insert statements in `03_seed.sql`, loading your initial dataset into the containerized PostgreSQL environment automatically.

---

Excellent — here’s the **final Brightspace-style feedback section** for **Questions 46–50**, completing your comprehensive **50-question quiz feedback set** for Weeks 1–5 of *DBAS 4002 – Transactional Database Programming.*
Each entry provides the correct answer, conceptual background, and concise student-facing explanation.

---

### **Question 46**

**Question:** What is the effect of using `ORDER BY column DESC`?
**Correct Answer:** Sorts results in descending order

**Background:**
The `ORDER BY` clause arranges query results by one or more columns. Adding the `DESC` keyword reverses the order—listing from largest to smallest (numbers) or Z to A (text). By default, PostgreSQL sorts in ascending order.

**Feedback Explanation:**
✅ **Correct –** The `DESC` modifier reverses the default ascending order.
Example:

```sql
SELECT name, start_date 
FROM event 
ORDER BY start_date DESC;
```

This displays the most recent events first. Use `ASC` for the opposite effect.

---

### **Question 47**

**Question:** Which ACID property ensures that once a transaction is committed, it remains saved?
**Correct Answer:** Durability

**Background:**
The **ACID** principles—Atomicity, Consistency, Isolation, and Durability—govern reliable transaction design.
Durability guarantees that once a transaction is committed, its changes persist even if the system crashes immediately afterward. PostgreSQL achieves this through write-ahead logging (WAL).

**Feedback Explanation:**
✅ **Correct –** Durability ensures that committed data survives power loss or failure.
When you issue `COMMIT`, PostgreSQL records the change in the WAL log before confirming success, guaranteeing data safety.

---

### **Question 48**

**Question:** What does the keyword `SERIAL` provide when defining a column in PostgreSQL?
**Correct Answer:** Auto-incrementing integer sequence

**Background:**
`SERIAL` is a PostgreSQL-specific shortcut that creates an integer column backed by an automatically generated **sequence**. It is ideal for primary key columns that need unique IDs without manual entry.

**Feedback Explanation:**
✅ **Correct –** The `SERIAL` type auto-generates consecutive numeric IDs.
Example:

```sql
CREATE TABLE category (
  category_id SERIAL PRIMARY KEY,
  name VARCHAR(100)
);
```

Every new record receives the next sequence number automatically, ensuring unique identifiers.

---

### **Question 49**

**Question:** Why might you use a window function instead of GROUP BY?
**Correct Answer:** To calculate aggregates while retaining individual row details

**Background:**
**Window functions** (like `ROW_NUMBER()`, `RANK()`, `AVG() OVER`) compute aggregate-like calculations across rows **without collapsing them**. They preserve detail while adding contextual metrics such as running totals or ranks.

**Feedback Explanation:**
✅ **Correct –** Window functions return both detail and summary in one query.
Example:

```sql
SELECT event_id, 
       priority, 
       AVG(priority) OVER () AS avg_priority
FROM event;
```

Here, each event row keeps its details but includes the global average priority—something not possible with `GROUP BY` alone.

---

### **Question 50**

**Question:** Which command in PostgreSQL displays all installed extensions?
**Correct Answer:** `\dx`

**Background:**
Extensions add advanced capabilities (e.g., `uuid-ossp`, `pgcrypto`, `postgis`) to PostgreSQL. Inside the psql shell, the meta-command `\dx` lists all installed extensions and their versions.

**Feedback Explanation:**
✅ **Correct –** `\dx` shows every active extension in the database.
Example output:

```
List of installed extensions
  Name     | Version | Schema | Description
-----------+----------+--------+---------------------------
 plpgsql   | 1.0      | pg_catalog | PL/pgSQL procedural language
 uuid-ossp | 1.1      | public     | Generate UUIDs
```

Use this command to verify that your DBAS PostgreSQL DevOps Stack includes all required developer tools.

---

✅ **End of Brightspace Feedback Set (Questions 1–50)**

This full set provides automated feedback for all foundational SQL concepts—DDL/DML, joins, subqueries, aggregation, normalization, constraints, transactions, and PostgreSQL tooling—aligned with your Week 1–5 learning outcomes.

Would you like me to bundle all **50 questions + feedback explanations** into a single **Brightspace import format (e.g., CSV or XML for D2L quiz upload)** next?
