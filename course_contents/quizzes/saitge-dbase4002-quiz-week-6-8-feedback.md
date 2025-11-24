Here’s the **Brightspace feedback explanation** for **Questions 1 – 5** of your **DBAS4002 Weeks 6–8 Quiz**, written in the instructor-friendly format you can paste into Brightspace’s feedback fields. Each answer explanation includes **conceptual background**, **rationale**, and **reinforcement** of the correct choice.

---

### **Q1. In PostgreSQL, which statement defines a stored procedure?**

**Correct Answer:** *b) CREATE PROCEDURE proc_name()*

**Feedback / Background:**
Before PostgreSQL 11, procedural logic was implemented only via functions (`CREATE FUNCTION`). PostgreSQL 11 introduced the true `CREATE PROCEDURE` statement, allowing procedures to execute transactional control statements such as `COMMIT` and `ROLLBACK` within their own scope—something functions cannot do.
This distinction is essential in **transactional database programming**, because procedures are meant to perform actions, while functions return values. In practice, you’ll use `CREATE PROCEDURE` for multi-step operations and transaction control logic.

---

### **Q2. What keyword is used to handle exceptions in PL/pgSQL?**

**Correct Answer:** *b) EXCEPTION*

**Feedback / Background:**
Error handling in PL/pgSQL is performed using the `EXCEPTION` block within a `BEGIN … END;` structure. This mechanism is equivalent to `try/catch` in general-purpose languages.
It allows developers to gracefully recover from runtime errors—for example, constraint violations or failed lookups—and either log the issue or roll back only the affected part of a transaction.
Example:

```sql
BEGIN
   -- risky operation
EXCEPTION
   WHEN OTHERS THEN
      RAISE NOTICE 'Handled safely.';
END;
```

Understanding `EXCEPTION` is key to building reliable, idempotent database logic.

---

### **Q3. Which command begins a transaction block?**

**Correct Answer:** *b) BEGIN;*

**Feedback / Background:**
`BEGIN;` starts a new transaction block in PostgreSQL. Everything executed after it is part of that single atomic transaction until a `COMMIT;` or `ROLLBACK;`.
You can also use `START TRANSACTION;`, which is functionally identical, but `BEGIN;` is the most common syntax.
Transactions ensure that a series of SQL statements obey the **ACID** principles—particularly **Atomicity** (all-or-nothing execution) and **Consistency**.
In production systems, explicit `BEGIN;` blocks are used when multiple dependent operations must succeed together, such as inserting an order header and its line items.

---

### **Q4. What does a COMMIT do?**

**Correct Answer:** *b) Permanently saves all changes made in the transaction.*

**Feedback / Background:**
`COMMIT;` ends the current transaction and makes all its changes visible to other sessions. Once committed, changes are written to the **Write-Ahead Log (WAL)** for durability.
It’s the final step confirming that every DML operation (INSERT, UPDATE, DELETE) within the transaction succeeded without errors.
If you forget to commit, PostgreSQL will automatically roll back the transaction when the session closes.
Conceptually, `COMMIT;` is the “save game” moment of database operations.

---

### **Q5. Which of the following automatically undoes uncommitted changes?**

**Correct Answer:** *b) ROLLBACK;*

**Feedback / Background:**
`ROLLBACK;` aborts the current transaction, discarding all changes made since the last `BEGIN;` or `SAVEPOINT;`.
This is crucial when an error or unexpected state occurs, ensuring the database returns to a consistent, pre-transaction state.
Developers often pair `ROLLBACK;` with exception handling logic in stored procedures:

```sql
BEGIN
   -- multiple DML statements
   COMMIT;
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK;
END;
```

Here’s the **Brightspace-ready feedback** for **Questions 6–10** of your **DBAS4002 Weeks 6–8 Quiz**.
Each explanation includes background context, conceptual framing, and a rationale for the correct answer.

---

### **Q6. What is a trigger used for?**

**Correct Answer:** *b) To automatically execute logic when data changes occur*

**Feedback / Background:**
A **trigger** is a special procedure automatically executed in response to specific events on a table or view — for example, an `INSERT`, `UPDATE`, or `DELETE`.
Triggers enforce business rules, maintain audit logs, or synchronize derived data without manual intervention.
They are crucial in transactional programming to ensure that **consistency rules** and **data integrity** persist even when multiple users modify the same dataset concurrently.
Example:

```sql
CREATE TRIGGER audit_event
AFTER INSERT ON event
FOR EACH ROW
EXECUTE FUNCTION log_event_insert();
```

---

### **Q7. A BEFORE INSERT trigger runs —**

**Correct Answer:** *b) Before a new row is inserted into a table*

**Feedback / Background:**
A **BEFORE trigger** fires prior to the DML operation being applied to the target table.
This gives developers a chance to **validate**, **modify**, or **cancel** the operation before the row becomes permanent.
Typical uses include enforcing domain rules or setting default field values.
For example:

```sql
CREATE TRIGGER set_defaults
BEFORE INSERT ON event
FOR EACH ROW
EXECUTE FUNCTION assign_defaults();
```

This ensures all event records meet integrity requirements before being stored.

---

### **Q8. What are AFTER triggers typically used for?**

**Correct Answer:** *b) Logging and auditing*

**Feedback / Background:**
**AFTER triggers** execute only after a change has successfully occurred and been committed to memory, meaning the data is already valid.
Because of that, they are perfect for **non-intrusive side effects** such as writing to audit logs, recording metrics, or notifying other systems.
An AFTER trigger can safely assume the data change succeeded and can use `NEW` and `OLD` values to record who made the change and when.
They are frequently paired with **audit tables** to provide traceability in regulated environments.

---

### **Q9. Which command lists all triggers in psql?**

**Correct Answer:** *b) \dy*

**Feedback / Background:**
In the `psql` command-line client, `\dy` displays a list of **event triggers** defined in the current database.
These include both **DML-level** (table) and **DDL-level** (schema) triggers.
Meta-commands like `\dy`, `\df`, and `\dt` are powerful exploration tools for developers inspecting schemas.
Remember: meta-commands in `psql` start with a backslash (`\`) and **do not require a semicolon**.

---

### **Q10. What is the purpose of an audit log table?**

**Correct Answer:** *b) Record who changed data, what was changed, and when*

**Feedback / Background:**
An **audit log** table provides accountability by storing a historical record of data changes.
It captures key information such as:

* The table affected (`table_name`)
* The type of action (`INSERT`, `UPDATE`, `DELETE`)
* The primary key or record identifier
* Timestamps and the acting user

Audit logging supports **compliance, debugging, and security**.
In transactional databases, audit logs are typically populated by **AFTER INSERT/UPDATE/DELETE** triggers.
Example:

```sql
INSERT INTO audit_log(table_name, action, record_id, change_time)
VALUES ('event', 'INSERT', NEW.event_id, NOW());
```

Here’s the **Brightspace-ready feedback** for **Questions 6–10** of your **DBAS4002 Weeks 6–8 Quiz**.
Each explanation includes background context, conceptual framing, and a rationale for the correct answer.

---

### **Q6. What is a trigger used for?**

**Correct Answer:** *b) To automatically execute logic when data changes occur*

**Feedback / Background:**
A **trigger** is a special procedure automatically executed in response to specific events on a table or view — for example, an `INSERT`, `UPDATE`, or `DELETE`.
Triggers enforce business rules, maintain audit logs, or synchronize derived data without manual intervention.
They are crucial in transactional programming to ensure that **consistency rules** and **data integrity** persist even when multiple users modify the same dataset concurrently.
Example:

```sql
CREATE TRIGGER audit_event
AFTER INSERT ON event
FOR EACH ROW
EXECUTE FUNCTION log_event_insert();
```

---

### **Q7. A BEFORE INSERT trigger runs —**

**Correct Answer:** *b) Before a new row is inserted into a table*

**Feedback / Background:**
A **BEFORE trigger** fires prior to the DML operation being applied to the target table.
This gives developers a chance to **validate**, **modify**, or **cancel** the operation before the row becomes permanent.
Typical uses include enforcing domain rules or setting default field values.
For example:

```sql
CREATE TRIGGER set_defaults
BEFORE INSERT ON event
FOR EACH ROW
EXECUTE FUNCTION assign_defaults();
```

This ensures all event records meet integrity requirements before being stored.

---

### **Q8. What are AFTER triggers typically used for?**

**Correct Answer:** *b) Logging and auditing*

**Feedback / Background:**
**AFTER triggers** execute only after a change has successfully occurred and been committed to memory, meaning the data is already valid.
Because of that, they are perfect for **non-intrusive side effects** such as writing to audit logs, recording metrics, or notifying other systems.
An AFTER trigger can safely assume the data change succeeded and can use `NEW` and `OLD` values to record who made the change and when.
They are frequently paired with **audit tables** to provide traceability in regulated environments.

---

### **Q9. Which command lists all triggers in psql?**

**Correct Answer:** *b) \dy*

**Feedback / Background:**
In the `psql` command-line client, `\dy` displays a list of **event triggers** defined in the current database.
These include both **DML-level** (table) and **DDL-level** (schema) triggers.
Meta-commands like `\dy`, `\df`, and `\dt` are powerful exploration tools for developers inspecting schemas.
Remember: meta-commands in `psql` start with a backslash (`\`) and **do not require a semicolon**.

---

### **Q10. What is the purpose of an audit log table?**

**Correct Answer:** *b) Record who changed data, what was changed, and when*

**Feedback / Background:**
An **audit log** table provides accountability by storing a historical record of data changes.
It captures key information such as:

* The table affected (`table_name`)
* The type of action (`INSERT`, `UPDATE`, `DELETE`)
* The primary key or record identifier
* Timestamps and the acting user

Audit logging supports **compliance, debugging, and security**.
In transactional databases, audit logs are typically populated by **AFTER INSERT/UPDATE/DELETE** triggers.
Example:

```sql
INSERT INTO audit_log(table_name, action, record_id, change_time)
VALUES ('event', 'INSERT', NEW.event_id, NOW());
```

Here’s the **Brightspace-ready feedback** for **Questions 11 – 15** of the **DBAS4002 Weeks 6–8 Quiz**, written in the same explanatory format used earlier.

---

### **Q11. In PostgreSQL, what happens if an error occurs within a transaction block?**

**Correct Answer:** *b) The transaction enters an aborted state until rolled back*

**Feedback / Background:**
When a transaction encounters an error, PostgreSQL marks the entire transaction as **aborted**. No further commands can succeed until a `ROLLBACK;` or `ROLLBACK TO SAVEPOINT;` is issued.
This protects the database from partial or inconsistent updates.
Developers often use exception handling inside procedures to trap errors, issue a rollback, and record the failure safely.
This behavior embodies the **Atomicity** principle of ACID—ensuring that a transaction either completes fully or not at all.

---

### **Q12. What does SAVEPOINT allow you to do?**

**Correct Answer:** *b) Roll back part of a transaction without undoing the entire transaction*

**Feedback / Background:**
A **SAVEPOINT** is a marker inside a transaction that lets you “bookmark” progress.
If an error occurs after a SAVEPOINT, you can roll back only to that point—keeping earlier successful steps.
Example:

```sql
BEGIN;
SAVEPOINT phase1;
-- Do work
ROLLBACK TO phase1;  -- undo from here onward
COMMIT;
```

This allows **fine-grained control** during multi-step operations such as data imports, batch jobs, or long-running migrations.

---

### **Q13. What is the default isolation level in PostgreSQL?**

**Correct Answer:** *b) READ COMMITTED*

**Feedback / Background:**
PostgreSQL defaults to the **READ COMMITTED** isolation level.
Each SQL statement sees only data committed **before** it began executing.
It prevents **dirty reads** but allows **non-repeatable reads** and **phantoms**.
This level strikes a balance between **data integrity** and **concurrency performance**, making it suitable for most OLTP workloads.
Developers can override it with:

```sql
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
```

---

### **Q14. Which of the following phenomena does PostgreSQL prevent even at READ COMMITTED?**

**Correct Answer:** *b) Dirty reads*

**Feedback / Background:**
A **dirty read** occurs when one transaction reads data that another has written but not yet committed.
PostgreSQL’s **MVCC (Multi-Version Concurrency Control)** design guarantees that this never happens, even at the default isolation level.
Each query reads from a consistent snapshot of committed data, protecting against “seeing” uncommitted changes that might later be rolled back.

---

### **Q15. Which command defines a trigger function?**

**Correct Answer:** *b) CREATE FUNCTION … RETURNS TRIGGER*

**Feedback / Background:**
A **trigger function** is created with `CREATE FUNCTION` returning the special type **TRIGGER**.
The function contains the logic the trigger executes—using the pseudo-records `NEW` and `OLD`.
Example:

```sql
CREATE FUNCTION audit_changes() RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO audit_log(table_name, action, record_id, change_time)
  VALUES (TG_TABLE_NAME, TG_OP, NEW.id, NOW());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

Here’s the **Brightspace-ready feedback** for **Questions 16–20** of your **DBAS4002 Weeks 6–8 Quiz**, following the same conceptual, instructional, and contextual depth as before.

---

### **Q16. What does the NEW keyword represent in a trigger?**

**Correct Answer:** *b) The row data being inserted or updated*

**Feedback / Background:**
In PostgreSQL triggers, the `NEW` record holds the **new version of the row** that will be inserted or updated.
It allows access to the values of each column as they exist after modification but before commit.
You can modify fields in `NEW` within a `BEFORE` trigger to enforce business rules or default behaviors.
Example:

```sql
CREATE TRIGGER normalize_title
BEFORE INSERT ON event
FOR EACH ROW
BEGIN
  NEW.name := INITCAP(NEW.name);
  RETURN NEW;
END;
```

Here, `NEW` represents the row about to be inserted. Understanding `NEW` is essential to customizing data integrity at the row level.

---

### **Q17. What does the OLD keyword represent in a trigger?**

**Correct Answer:** *b) The row state before modification*

**Feedback / Background:**
The `OLD` record in a trigger holds the **previous state** of a row before it was changed or deleted.
This is most often used in **UPDATE** and **DELETE** triggers to record what was changed.
Example:

```sql
INSERT INTO audit_log(old_value, new_value)
VALUES (OLD.priority, NEW.priority);
```

This pattern forms the foundation of audit tracking systems, ensuring changes can be traced and, if needed, reversed.
By combining `OLD` and `NEW`, you can measure differences between versions of data for robust auditing and reporting.

---

### **Q18. Why would you include error handling in a stored procedure?**

**Correct Answer:** *b) To maintain transaction control and avoid partial commits*

**Feedback / Background:**
Error handling ensures that when a problem occurs—like a constraint violation or missing data—the transaction can **gracefully roll back** instead of leaving the database in an inconsistent state.
Without error handling, a partially committed transaction could corrupt business data or violate integrity rules.
A well-designed stored procedure includes `BEGIN … EXCEPTION … END;` blocks that protect atomicity and log errors safely.
This principle is foundational to **robust transactional systems** that recover predictably under failure conditions.

---

### **Q19. Which option best describes idempotency in transaction logic?**

**Correct Answer:** *b) Re-running the same operation yields the same end state*

**Feedback / Background:**
**Idempotency** ensures that executing the same transaction multiple times produces the same final result — a vital concept in resilient systems where retries can occur (e.g., message queues or API calls).
For example, running an `UPDATE` that sets a flag to `TRUE` is idempotent, while an `INSERT` that duplicates data is not.
Idempotent design prevents double-charging, duplicate records, or inconsistent states after network or application failures.
In transactional programming, it’s a cornerstone of **fault-tolerant behavior**.

---

### **Q20. What is a potential danger of poorly designed triggers?**

**Correct Answer:** *b) Recursive trigger loops or unintended cascading updates*

**Feedback / Background:**
Triggers that modify the same table or invoke other triggers can cause **infinite recursion** or **uncontrolled side effects**, such as repeated updates or mass deletions.
For example, a trigger that updates a record in the same table on every update could retrigger itself indefinitely.
PostgreSQL mitigates this with configuration options like `session_replication_role` and careful trigger logic, but developers must design with discipline.
Proper design ensures triggers enhance integrity—not create hidden performance or logic hazards.

---

Here’s the **Brightspace-ready feedback** for **Questions 16–20** of your **DBAS4002 Weeks 6–8 Quiz**, following the same conceptual, instructional, and contextual depth as before.

---

### **Q16. What does the NEW keyword represent in a trigger?**

**Correct Answer:** *b) The row data being inserted or updated*

**Feedback / Background:**
In PostgreSQL triggers, the `NEW` record holds the **new version of the row** that will be inserted or updated.
It allows access to the values of each column as they exist after modification but before commit.
You can modify fields in `NEW` within a `BEFORE` trigger to enforce business rules or default behaviors.
Example:

```sql
CREATE TRIGGER normalize_title
BEFORE INSERT ON event
FOR EACH ROW
BEGIN
  NEW.name := INITCAP(NEW.name);
  RETURN NEW;
END;
```

Here, `NEW` represents the row about to be inserted. Understanding `NEW` is essential to customizing data integrity at the row level.

---

### **Q17. What does the OLD keyword represent in a trigger?**

**Correct Answer:** *b) The row state before modification*

**Feedback / Background:**
The `OLD` record in a trigger holds the **previous state** of a row before it was changed or deleted.
This is most often used in **UPDATE** and **DELETE** triggers to record what was changed.
Example:

```sql
INSERT INTO audit_log(old_value, new_value)
VALUES (OLD.priority, NEW.priority);
```

This pattern forms the foundation of audit tracking systems, ensuring changes can be traced and, if needed, reversed.
By combining `OLD` and `NEW`, you can measure differences between versions of data for robust auditing and reporting.

---

### **Q18. Why would you include error handling in a stored procedure?**

**Correct Answer:** *b) To maintain transaction control and avoid partial commits*

**Feedback / Background:**
Error handling ensures that when a problem occurs—like a constraint violation or missing data—the transaction can **gracefully roll back** instead of leaving the database in an inconsistent state.
Without error handling, a partially committed transaction could corrupt business data or violate integrity rules.
A well-designed stored procedure includes `BEGIN … EXCEPTION … END;` blocks that protect atomicity and log errors safely.
This principle is foundational to **robust transactional systems** that recover predictably under failure conditions.

---

### **Q19. Which option best describes idempotency in transaction logic?**

**Correct Answer:** *b) Re-running the same operation yields the same end state*

**Feedback / Background:**
**Idempotency** ensures that executing the same transaction multiple times produces the same final result — a vital concept in resilient systems where retries can occur (e.g., message queues or API calls).
For example, running an `UPDATE` that sets a flag to `TRUE` is idempotent, while an `INSERT` that duplicates data is not.
Idempotent design prevents double-charging, duplicate records, or inconsistent states after network or application failures.
In transactional programming, it’s a cornerstone of **fault-tolerant behavior**.

---

### **Q20. What is a potential danger of poorly designed triggers?**

**Correct Answer:** *b) Recursive trigger loops or unintended cascading updates*

**Feedback / Background:**
Triggers that modify the same table or invoke other triggers can cause **infinite recursion** or **uncontrolled side effects**, such as repeated updates or mass deletions.
For example, a trigger that updates a record in the same table on every update could retrigger itself indefinitely.
PostgreSQL mitigates this with configuration options like `session_replication_role` and careful trigger logic, but developers must design with discipline.
Proper design ensures triggers enhance integrity—not create hidden performance or logic hazards.

---
Here’s the **Brightspace-ready feedback** for **Questions 21–25** of your **DBAS4002 Weeks 6–8 Quiz** — completing the full feedback set for this section of the course.

---

### **Q21. What does PERFORM do in PL/pgSQL?**

**Correct Answer:** *b) Executes a query without returning a result*

**Feedback / Background:**
`PERFORM` is a PL/pgSQL command used when you need to **execute a query purely for its side effects** (like calling a function) and don’t care about its result.
It’s equivalent to running a `SELECT` statement but discarding the output.
Example:

```sql
PERFORM log_action('User created', NEW.user_id);
```

This is especially useful inside triggers or procedures where you want to log an event or update metadata but don’t need to store or return a value.
Using `PERFORM` avoids warnings about unused results and keeps procedural code clean and efficient.

---

### **Q22. What is the purpose of a transaction log (WAL)?**

**Correct Answer:** *b) Ensures durability by recording every change before commit*

**Feedback / Background:**
PostgreSQL’s **Write-Ahead Log (WAL)** is the foundation of data durability.
Before committing a transaction, PostgreSQL writes all intended changes to the WAL so that, in the event of a crash, it can **replay the log** to restore the database to a consistent state.
This design guarantees that once a transaction is committed, it is **never lost**, fulfilling the **Durability** property of ACID.
It also supports features like replication and point-in-time recovery (PITR).

---

### **Q23. What is a row-level trigger?**

**Correct Answer:** *b) Trigger fired for each row affected*

**Feedback / Background:**
A **row-level trigger** executes once per row that a DML statement affects, giving fine-grained control over how data changes are processed.
For example, an `UPDATE` that modifies 10 rows will invoke the trigger 10 times — once per row.
Row-level triggers are commonly used for **auditing** and **validation**, where you need to inspect or log individual record changes using `NEW` and `OLD` pseudo-records.
They contrast with **statement-level triggers**, which fire once per entire statement, regardless of how many rows were affected.

---

### **Q24. Which of the following is NOT a valid trigger timing option?**

**Correct Answer:** *b) DURING*

**Feedback / Background:**
PostgreSQL supports three timing options for triggers:

* `BEFORE` (execute prior to the DML)
* `AFTER` (execute after the DML)
* `INSTEAD OF` (used with views to override default behavior)

There is **no “DURING” timing option** — it doesn’t exist in SQL or PL/pgSQL.
This question reinforces the syntax precision required when defining trigger timing, since incorrect timing keywords result in compile errors.

---

### **Q25. In a trigger, what does returning NULL typically do?**

**Correct Answer:** *b) Skips the operation for that row*

**Feedback / Background:**
When a `BEFORE` trigger function returns `NULL`, it tells PostgreSQL to **cancel the triggering operation for that specific row**.
This mechanism allows developers to selectively block inserts or updates that don’t meet validation criteria.
Example:

```sql
IF NEW.priority < 0 THEN
  RETURN NULL;  -- skip invalid row
END IF;
```

By contrast, returning `NEW` applies the row change as normal.
This approach provides a powerful way to enforce data validation directly at the database level, rather than relying solely on application code.

---
