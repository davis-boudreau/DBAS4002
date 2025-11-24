1. In PostgreSQL, which statement defines a stored procedure?
   a) `CREATE FUNCTION proc_name()`
   *b) `CREATE PROCEDURE proc_name()`
   c) `BEGIN PROCEDURE proc_name()`
   d) `DECLARE PROCEDURE proc_name()`

2. What keyword is used to handle exceptions in PL/pgSQL?
   a) `TRY`
   *b) `EXCEPTION`
   c) `CATCH`
   d) `WHENERROR`

3. Which command begins a transaction block?
   *b) `BEGIN;`
   a) `START TRANSACTION;`
   c) `TRANSACTION ON;`
   d) `SET TRANSACTION;`

4. What does a **COMMIT** do?
   a) Cancels the current transaction
   *b) Permanently saves all changes made in the transaction
   c) Suspends the current transaction
   d) Rolls back only failed statements

5. Which of the following automatically undoes uncommitted changes?
   *b) `ROLLBACK;`
   a) `SAVEPOINT;`
   c) `COMMIT;`
   d) `RETRY;`

6. What is a trigger used for?
   a) To control database access
   *b) To automatically execute logic when data changes occur
   c) To store static configuration data
   d) To manage connection pooling

7. A **BEFORE INSERT** trigger runs —
   *b) Before a new row is inserted into a table
   a) After the insert finishes
   c) Before the transaction starts
   d) Only if a rollback occurs

8. What are **AFTER triggers** typically used for?
   *b) Logging and auditing
   a) Data validation before insert
   c) Permission enforcement
   d) Preventing inserts

9. Which command lists all triggers in psql?
   a) `\dt`
   *b) `\dy`
   c) `\df`
   d) `\dT`

10. What is the purpose of an **audit log** table?
    *b) Record who changed data, what was changed, and when
    a) Optimize query performance
    c) Store backup files
    d) Hold transaction metadata

11. In PostgreSQL, what happens if an error occurs within a transaction block?
    a) The system ignores it
    *b) The transaction enters an aborted state until rolled back
    c) Only that row fails
    d) The error is silently retried

12. What does **SAVEPOINT** allow you to do?
    *b) Roll back part of a transaction without undoing the entire transaction
    a) Lock a table
    c) Force immediate commit
    d) Duplicate schema state

13. What is the default isolation level in PostgreSQL?
    a) SERIALIZABLE
    *b) READ COMMITTED
    c) REPEATABLE READ
    d) READ UNCOMMITTED

14. Which of the following phenomena does PostgreSQL prevent even at READ COMMITTED?
    *b) Dirty reads
    a) Non-repeatable reads
    c) Phantom reads
    d) Write skew

15. Which command defines a trigger function?
    a) `CREATE TRIGGER`
    *b) `CREATE FUNCTION … RETURNS TRIGGER`
    c) `CREATE PROCEDURE`
    d) `CREATE RULE`

16. What does the **NEW** keyword represent in a trigger?
    *b) The row data being inserted or updated
    a) A system catalog entry
    c) The old table schema
    d) The last committed transaction

17. What does the **OLD** keyword represent in a trigger?
    a) The newly inserted row
    *b) The row state before modification
    c) The trigger name
    d) The transaction ID

18. Why would you include error handling in a stored procedure?
    *b) To maintain transaction control and avoid partial commits
    a) To automatically generate triggers
    c) To bypass foreign key constraints
    d) To convert exceptions to warnings

19. Which option best describes **idempotency** in transaction logic?
    a) The ability to execute multiple triggers
    *b) Re-running the same operation yields the same end state
    c) Disabling all locks
    d) Creating redundant indexes

20. What is a potential danger of poorly designed triggers?
    a) Faster commits
    *b) Recursive trigger loops or unintended cascading updates
    c) Ignored constraints
    d) Automatic optimization

21. What does **PERFORM** do in PL/pgSQL?
    *b) Executes a query without returning a result
    a) Creates a trigger
    c) Returns a result set
    d) Begins a transaction

22. What is the purpose of a **transaction log (WAL)**?
    *b) Ensures durability by recording every change before commit
    a) Holds temporary results
    c) Manages user permissions
    d) Stores schema metadata

23. What is a **row-level trigger**?
    a) Trigger fired once per statement
    *b) Trigger fired for each row affected
    c) Trigger fired by DDL
    d) Trigger fired only on commit

24. Which of the following is NOT a valid trigger timing option?
    *b) DURING
    a) BEFORE
    c) AFTER
    d) INSTEAD OF

25. In a trigger, what does returning **NULL** typically do?
    a) Duplicates the row
    *b) Skips the operation for that row
    c) Commits the transaction
    d) Causes the trigger to fail
