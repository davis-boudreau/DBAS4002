![alt text](image.png)

---


## **1. Assignment Details**

| Field              | Information                                           |
| :----------------- | :---------------------------------------------------- |
| **Course Code**    | DBAS 4002                                             |
| **Course Name**    | Transactional Database Programming                    |
| **Workshop Title** | Workshop 01 – Relational Foundations & Database Setup |
| **Type**           | Guided Workshop (Activity + Reflection)               |
| **Instructor**     | Davis Boudreau                                        |
| **Stack Used**     | DBAS PostgreSQL DevOps Stack (v3.2)                   |
| **Duration**       | 3 hours                                               |

---

## **2. Overview / Purpose / Objectives**

### **Conceptual Framing**

Transactional systems depend on a **solid relational foundation**. Before writing a single transaction or stored procedure, you must understand how **tables, relationships, and constraints** ensure data consistency across concurrent operations.

This workshop builds that foundation through:

* an introduction to **relational design principles**,
* deployment of a **Dockerized PostgreSQL environment**, and
* creation of your **base schema** that future workshops will expand (joins, transactions, triggers, and optimization).

By the end of this activity, you’ll understand **why relational design matters**, and **how Docker ensures reproducibility** in professional database workflows.

---

### **Purpose**

You will:

* Deploy a PostgreSQL + pgAdmin environment using Docker Compose.
* Verify that PostgreSQL services, volumes, and credentials function correctly.
* Create the foundational database schema (Category → Event case study).
* Populate seed data and perform initial verification queries.
* Reflect on data integrity and reproducibility.

---

### **Learning Outcomes Addressed**

**Outcome 1 – Code SQL to meet requirements with business logic**

> Design and build relational schemas with correct data types, keys, and integrity constraints.

---

## **3. Workshop Context**

The **Category–Event** schema simulates a small transactional system, representing how real applications categorize, schedule, and manage business entities.
Each event belongs to a category (a one-to-many relationship). This mirrors how systems manage dependencies (e.g., product categories → products, departments → employees, etc.).

The schema also forms the baseline for future workshops:

* **Week 2:** Filtering and Retrieval
* **Week 3:** Joins and Subqueries
* **Week 4:** Integrity and Business Rules
* **Week 5:** Aggregations and Windows

---

## **4. Background Concepts**

| Concept                | Description                                                                            |
| :--------------------- | :------------------------------------------------------------------------------------- |
| **Relational Model**   | Organizes data into tables (relations) of rows and columns with defined relationships. |
| **Primary Key**        | Ensures each row is unique.                                                            |
| **Foreign Key**        | Maintains referential integrity across tables.                                         |
| **Normalization**      | Reduces redundancy and improves consistency (1NF → 3NF).                               |
| **Schema**             | Logical blueprint of tables, relationships, and constraints.                           |
| **Docker Environment** | Provides consistent runtime environments for PostgreSQL and pgAdmin across platforms.  |

---

## **5. Tools Overview**

| Tool               | Role                                                                |
| :----------------- | :------------------------------------------------------------------ |
| **Docker Compose** | Orchestrates PostgreSQL and pgAdmin containers.                     |
| **Makefile**       | Simplifies commands for `up`, `down`, and `psql` operations.        |
| **psql Shell**     | Executes SQL directly in the PostgreSQL container.                  |
| **pgAdmin**        | Visual interface for browsing tables and querying data.             |
| **.env File**      | Centralizes environment variables (e.g., DB user, password, ports). |

---

## **6. Step-by-Step Workshop Instructions**

---

### 🧭 Step 1 – Initialize the Environment

1. Open your terminal in the project folder.

2. Run:

   ```bash
   make up
   ```

   This command launches both **PostgreSQL** and **pgAdmin** containers using the Docker Compose configuration.

3. Verify:

   ```bash
   docker ps
   ```

   You should see containers named `mp_db` and `mp_pgadmin`.

💡 **Concept:** Docker encapsulates dependencies, versions, and configurations, preventing “works on my machine” inconsistencies.

---

### ⚙️ Step 2 – Connect via psql Shell

1. Open the interactive psql shell:

   ```bash
   make psql
   ```
2. Verify connection:

   ```sql
   \conninfo
   ```

   You’ll see the current database name, user, and port.

💡 **Concept:** Using `psql` inside Docker ensures you’re operating inside the running container, independent of local installations.

---

### 🧱 Step 3 – Create the Base Schema

Inside psql:

```sql
CREATE TABLE category (
  category_id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL
);

CREATE TABLE event (
  event_id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  category_id INT REFERENCES category(category_id),
  start_date TIMESTAMP NOT NULL,
  end_date TIMESTAMP NOT NULL,
  priority INT DEFAULT 1,
  description TEXT,
  location VARCHAR(255),
  organizer VARCHAR(100)
);
```

💡 **Concept:**

* `SERIAL` automatically increments IDs.
* `REFERENCES` enforces referential integrity.
* `DEFAULT` provides base values when none are given.

---

### 🧩 Step 4 – Insert Seed Data

Execute:

```sql
INSERT INTO category (name) VALUES
('Workshop'), ('Seminar'), ('Conference');

INSERT INTO event (name, category_id, start_date, end_date, priority, description, location, organizer)
VALUES
('Database Kickoff', 1, '2025-09-10 09:00', '2025-09-10 12:00', 1, 'Intro to SQL and relational design', 'Room 203', 'D. Boudreau'),
('Docker Deep Dive', 2, '2025-09-12 13:00', '2025-09-12 15:00', 2, 'Exploring PostgreSQL DevOps Stack', 'Lab 2', 'A. Student');
```

💡 **Concept:** The seed script simulates business data; this schema will grow into a fully transactional system in later weeks.

---

### 🔍 Step 5 – Verify and Explore Data

```sql
SELECT * FROM category;
SELECT name, start_date FROM event ORDER BY start_date;
```

In pgAdmin: refresh the schema and browse tables to confirm the data.

💡 **Concept:** A quick visual check in pgAdmin helps validate your database state and relationships before writing queries or transactions.

---

### 💾 Step 6 – Snapshot Your Work

Run:

```bash
docker compose exec mp_db pg_dump -U postgres -d dbas4002 > backup/schema_snapshot.sql
```

This creates a reusable baseline for future workshops.

💡 **Concept:** Frequent backups ensure data recoverability — an essential habit for transactional developers.

---

## **7. Deliverables**

Submit:

```
Lastname_Firstname_WS01_Setup.sql
```

Include:

* Schema creation commands
* Seed data inserts
* Verification queries
* Short reflection answers

---

## **8. Reflection Questions**

1. Why is referential integrity crucial for transactional systems?
2. How does Docker help create a consistent learning environment?
3. What potential issues arise when normalization is ignored?
4. What benefits do seed scripts provide in a team development setting?
5. How does a well-structured schema support error handling in future transactions?

---

## **9. Assessment & Rubric (10 pts)**

| Criteria          | Excellent (3)                                | Satisfactory (2)                   | Needs Improvement (1)           | Pts     |
| :---------------- | :------------------------------------------- | :--------------------------------- | :------------------------------ | :------ |
| Environment Setup | Containers run successfully and verified     | Minor connection issues            | Not functional                  | __/3    |
| Schema Design     | Correct tables, types, and keys              | Minor errors in types or relations | Incomplete schema               | __/3    |
| Seed & Queries    | Proper seed data and valid SELECTs           | Partial data or syntax issues      | Missing data or invalid queries | __/2    |
| Reflection        | Deep insight connecting concepts to practice | Superficial understanding          | Missing or unclear              | __/2    |
| **Total**         |                                              |                                    |                                 | **/10** |

---

## **10. Submission Guidelines**

* Use `make up` to start the stack and `make psql` to access PostgreSQL.
* Execute commands inside the psql session.
* Export and upload your SQL file to Brightspace or GitHub.

---

## **11. Resources / Equipment**

* **DBAS PostgreSQL DevOps Stack (v3.2)**
* Docker Desktop + Docker Compose
* PostgreSQL Documentation (DDL & Constraints)
* pgAdmin or psql CLI

---

## **12. Copyright**

© 2025 Nova Scotia Community College — For educational use only.

