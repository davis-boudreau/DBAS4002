![alt text](image.png)

---


## **1. Assignment Details**

* **Course Code:** DBAS 4002
* **Course Name:** Transactional Database Programming
* **Workshop Title:** Workshop 06 – Building Modular SQL Logic (Procedures & Functions)
* **Type:** Guided Workshop / Hands-On Lab
* **Duration:** 2 hourse
* **Version:** 1.0 (Fall 2025)
* **Instructor:** Davis Boudreau

---

## **2. Overview / Purpose / Objectives**

**Purpose:**
Students will learn to move from declarative SQL to **procedural logic** inside the database. Using **PostgreSQL stored procedures and functions**, they’ll design reusable code blocks that encapsulate business logic such as inserting, updating, and validating records.

**Objectives:**

1. Understand when and why to use stored procedures and functions.
2. Declare variables, parameters, and control flow (IF/CASE/LOOP).
3. Implement parameterized procedures for common operations (Insert / Update / Validation).
4. Test procedural code for correctness and error handling.
5. Reflect on code reusability and security in transactional design.

---

## **3. Learning Outcomes Addressed**

* **O2:** Manage transactions and business logic with procedural SQL and error handling.
* **O4:** Interpret and modify complex SQL routines to support system maintenance.

---

## **4. Assignment Description / Use Case**

Building on your earlier schema (e.g., Category and Event tables), you’ll now create **stored routines** to automate data manipulation and validation.
Instead of writing ad-hoc INSERT/UPDATE queries, you’ll encapsulate that logic in a controlled and reusable function.

### 💼 Example Use Case

The database should automatically:

* Insert a new event only if the category exists.
* Validate that `end_date > start_date`.
* Provide a function to adjust event priority and log the change.

---

## **5. Tasks / Instructions**

### 🧭 Step 1 – Set Up Environment

Ensure your Dockerized PostgreSQL environment is running:

```bash
make up
make psql
```

Use your existing schema from `sql/00_init/` or rebuild it with:

```bash
make reset
```

---

### ⚙️ Step 2 – Create a Function: Add New Record

Create `sql/30_procedures/workshop6_functions.sql`.

Example:

```sql
CREATE OR REPLACE FUNCTION add_event(
    p_name VARCHAR,
    p_category_id INT,
    p_start TIMESTAMP,
    p_end TIMESTAMP,
    p_priority INT DEFAULT 1,
    p_organizer VARCHAR DEFAULT NULL
)
RETURNS VOID AS $$
BEGIN
    IF p_end <= p_start THEN
        RAISE EXCEPTION 'End date must be after start date';
    END IF;

    INSERT INTO Event (name, category_id, start_date, end_date, priority, organizer)
    VALUES (p_name, p_category_id, p_start, p_end, p_priority, p_organizer);
END;
$$ LANGUAGE plpgsql;
```

Test:

```sql
SELECT add_event('Database Bootcamp', 1, '2025-10-21 10:00', '2025-10-21 16:00', 3, 'Davis B.');
```

---

### 🧩 Step 3 – Add an Update Routine

Create a stored procedure to update priority:

```sql
CREATE OR REPLACE PROCEDURE update_event_priority(p_event_id INT, p_new_priority INT)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_new_priority < 1 OR p_new_priority > 5 THEN
        RAISE NOTICE 'Priority must be between 1 and 5';
        RETURN;
    END IF;

    UPDATE Event
    SET priority = p_new_priority
    WHERE event_id = p_event_id;

    RAISE NOTICE 'Priority updated for event ID %', p_event_id;
END;
$$;
```

Execute:

```sql
CALL update_event_priority(1, 2);
```

---

### 🧮 Step 4 – Add Validation Function

Create a function to check if a category exists before insert:

```sql
CREATE OR REPLACE FUNCTION validate_category(p_category_id INT)
RETURNS BOOLEAN AS $$
DECLARE
    v_exists BOOLEAN;
BEGIN
    SELECT EXISTS(SELECT 1 FROM Category WHERE category_id = p_category_id)
    INTO v_exists;
    RETURN v_exists;
END;
$$ LANGUAGE plpgsql;
```

Test:

```sql
SELECT validate_category(2);
```

---

### 🧠 Step 5 – Challenge: Combine Validation and Insert

Modify `add_event` to first check that the category exists using `validate_category`.
If it does not exist, raise an error instead of inserting.

---

### 🧪 Step 6 – Reflection & Testing

Test your routines by:

```bash
make psql
-- inside psql
SELECT * FROM Event;
```

Try failing cases (e.g., invalid category ID, end < start).

---

## **6. Deliverables**

Submit a zip file named:

```
studentid_course_workshop6_functions.zip
```

Containing:

* `sql/30_procedures/workshop6_functions.sql`
* `sql/30_procedures/workshop6_procedures.sql`
* `workshop6_reflection.docx` (answers below)

---

## **7. Reflection Questions**

1. Why would a team choose stored procedures over application-level logic?
2. What is the difference between `FUNCTION` and `PROCEDURE` in PostgreSQL?
3. How do you handle errors in procedural code gracefully?
4. What are the security implications of executing procedures in production databases?

---

## **8. Assessment & Rubric (10 pts)**

| **Criteria**                     | **Excellent (3)**                                    | **Satisfactory (2)**              | **Needs Improvement (1)** | **Pts** |
| -------------------------------- | ---------------------------------------------------- | --------------------------------- | ------------------------- | ------- |
| Function Accuracy                | Fully functional with validation and correct results | Minor syntax or logic issues      | Fails to run              | __/3    |
| Procedure Logic & Error Handling | Robust, handles invalid inputs cleanly               | Partial checking or missing RAISE | No error handling         | __/3    |
| Code Readability / Comments      | Clear and commented                                  | Minimal comments                  | Confusing / undocumented  | __/2    |
| Reflection Quality               | Thoughtful analysis and examples                     | Generic responses                 | Missing or off-topic      | __/2    |

**Total: /10**

---

## **9. Submission Guidelines**

* Run `make psql` to verify your functions compile and execute without errors.
* Comment each routine clearly with a description and example usage.
* Submit via Brightspace or GitHub class repository.

---

## **10. Resources / Equipment**

* Dockerized PostgreSQL environment (from MP-Docker).
* `make` commands for automation.
* PostgreSQL documentation: [https://www.postgresql.org/docs/current/plpgsql.html](https://www.postgresql.org/docs/current/plpgsql.html)

---

## **11. Academic Policies**

All work must be original. Cite any borrowed examples with comments in your SQL files.

---

## **12. Copyright Notice**

© 2025 Nova Scotia Community College – For educational use only.
