# 🏗️ Week 1 Workshop: Designing the Database – From ER Model to Schema

### 🎯 Learning Objectives

By the end of this workshop, you will be able to:

* Translate real-world requirements into an ER (Entity–Relationship) model.
* Convert the ER model into a relational schema with primary and foreign keys.
* Apply normalization principles (up to 3NF) to reduce redundancy.
* Document the schema in a way that supports later SQL development.

---

## 1. Introduction (10 min)

Before writing any SQL, we must design the database structure. Think of this as **blueprints before building a house**. A good design enforces data integrity and makes future queries easier and faster.

We will use a **case study** throughout this course (e.g., managing categories and events), but the process applies to **any business domain**.

---

## 2. Activity A – Requirements to Entities (15 min)

**Step 1. Read the Requirements**
Suppose the system needs to:

* Organize **categories** (e.g., “Workshops”, “Conferences”).
* Store details of **events** (name, start/end date, description, location, organizer, priority).
* Track relationships (every event belongs to one category).

**Step 2. Identify Entities & Attributes**

* **Category** → name
* **Event** → name, start\_date, end\_date, description, location, organizer, priority

**Exercise A1:**
Write down at least **two more attributes** you think would be useful for either entity (e.g., “cost”, “capacity”).

**Reflection Prompt:**
Why did you choose these attributes? How do they help the system’s usefulness?

---

## 3. Activity B – ER Diagram (20 min)

**Step 1. Draw the Entities**

* Use two rectangles: **Category** and **Event**.

**Step 2. Add Relationships**

* An event *belongs to* one category.
* A category *has many* events.

**Step 3. Add Cardinalities**

* Category : Event → **1 : Many**

**Exercise B1:**
Sketch this ER diagram on paper or a digital tool (e.g., dbdiagram.io, Lucidchart, or draw\.io).

**Exercise B2:**
Add the attributes from Activity A, marking primary keys (e.g., `category_id`, `event_id`).

---

## 4. Activity C – Schema Design (25 min)

**Step 1. Convert to Tables**
Write the relational schema:

```
Category(
    category_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
)

Event(
    event_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    start_date DATETIME NOT NULL,
    end_date DATETIME NOT NULL,
    priority INT DEFAULT 1,
    description TEXT,
    location VARCHAR(255),
    organizer VARCHAR(100),
    category_id INT,
    FOREIGN KEY (category_id) REFERENCES Category(category_id)
)
```

**Step 2. Discuss Keys**

* Every table should have a **primary key**.
* Use **foreign keys** to link related tables.

**Exercise C1:**
Normalize the schema: Check for repeating groups, partial dependencies, and transitive dependencies. Does your design already meet **3NF**?

**Exercise C2:**
Suggest one **business rule** you might enforce with a constraint (e.g., “end\_date must be after start\_date”).

---

## 5. Wrap-Up & Reflection (10 min)

**Deliverable:**

* Submit your ER diagram and relational schema.
* Include a short (150–200 words) reflection:

  * What design choices did you make?
  * How did normalization affect your schema?
  * What constraints did you add and why?

**Looking Ahead:**
In Week 2, we’ll begin **querying the database** with `SELECT`, `WHERE`, and `ORDER BY`. Your schema will be the foundation for these queries.

