# 🛠️ Week 2 Workshop: Finding the Right Data: SELECT & Filtering

**Focus:** Practice retrieving data with `SELECT`, filtering with `WHERE`, ordering with `ORDER BY`, and handling `NULL` values in the **event management system** database.

**Schema Context:**

```sql
CREATE TABLE Category (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE Event (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category_id INT REFERENCES Category(id) ON DELETE CASCADE,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    priority INT DEFAULT 1,
    description TEXT DEFAULT '',
    location VARCHAR(255) DEFAULT '',
    organizer VARCHAR(100) DEFAULT ''
);
```

---

## 🎯 Learning Outcomes

By the end of this workshop, you will be able to:

1. Retrieve specific fields from `Event` and `Category`.
2. Apply filtering with `WHERE`, including comparisons and logical operators.
3. Sort results using `ORDER BY`.
4. Handle missing or empty values in fields like `description` and `location`.

---

## 📚 Pre-Workshop Setup

1. Confirm your development environment is set up (PostgreSQL + pgAdmin or VS Code SQL extension).
2. Run the `Category` and `Event` table creation scripts above.
3. Insert some sample data:

```sql
INSERT INTO Category (name) VALUES
('Conference'), ('Workshop'), ('Webinar');

INSERT INTO Event (name, category_id, start_date, end_date, priority, description, location, organizer) VALUES
('AI in Healthcare', 1, '2025-10-01 09:00', '2025-10-01 17:00', 2, 'Full-day healthcare AI talks', 'Toronto', 'Dr. Smith'),
('Web Dev Bootcamp', 2, '2025-09-20 10:00', '2025-09-20 16:00', 1, '', 'Online', 'Jane Doe'),
('Data Science Webinar', 3, '2025-09-25 18:00', '2025-09-25 20:00', 3, NULL, 'Zoom', 'Tech Org'),
('Cloud Conference', 1, '2025-11-10 09:00', '2025-11-12 17:00', 2, 'Multi-day cloud event', NULL, 'Cloud Inc');
```

---

## 🧑‍💻 Step-by-Step Activities

### **Step 1: Basic SELECT**

* Retrieve all columns from the `Event` table.
* Retrieve only `name`, `start_date`, and `location` for each event.
* Reflection: *Why might we avoid `SELECT *` in production systems?*

---

### **Step 2: Filtering with WHERE**

* Find all events in category **Workshop**.
* Find all events with `priority > 1`.
* Find all events organized by `'Jane Doe'`.
* Combine filters: all **Conferences** happening in **Toronto**.
* Reflection: *How do filters reduce data transfer and improve performance?*

---

### **Step 3: Ordering Results**

* List all events ordered by `start_date` ascending.
* List events ordered by `priority` (highest first), then by `name`.
* Reflection: *Why might ORDER BY be expensive for large datasets?*

---

### **Step 4: Working with NULL / Empty Fields**

* Retrieve events where `description` IS NULL.
* Retrieve events where `location` IS NULL OR `location = ''`.
* Use `COALESCE` to display `'TBD'` for events missing a location.
* Reflection: *What risks do NULL and empty strings pose for business reporting?*

---

### **Step 5: Combine Everything**

Write a query to:

* Show all **Webinars**
* That have **priority ≥ 2**
* Ordered by start date (soonest first)
* Replace missing descriptions with `'No description available'`.

---

## 📄 Deliverable

Submit a SQL script containing **10 queries** that demonstrate:

* At least 3 filters (`WHERE` with comparison/logical operators).
* At least 2 examples handling NULL/empty values.
* At least 2 ordered result sets.
* At least 1 query combining filtering + ordering + NULL handling.

---

## 🔍 Reflection Questions (short written answers)

1. Why is distinguishing between `NULL` and an empty string important in SQL?
2. In what real-world scenarios would sorting by priority or start date be critical?
3. How might filtering and ordering queries support event organizers in decision-making?
