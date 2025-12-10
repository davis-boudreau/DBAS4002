1. In PostgreSQL, what is the main purpose of using a transaction block?
a) To improve query speed through indexing
*b) To ensure a group of SQL statements execute atomically
c) To manage data types across multiple tables
d) To automatically generate audit logs

2. Which SQL keyword combination marks the beginning and end of a transaction block?
a) OPEN and CLOSE
*b) BEGIN and COMMIT
c) CREATE and EXECUTE
d) START and END

3. What is the role of a SAVEPOINT in a transaction?
a) It restarts a transaction after failure
b) It commits a partial transaction
*c) It allows rollback to a specific intermediate point
d) It locks the table for concurrent writes

4. Which command explicitly undoes all changes made in the current transaction?
*a) ROLLBACK
b) ABORT
c) UNDO
d) DELETE

5. Why are triggers important in database design?
a) They replace user-defined functions
b) They automatically generate primary keys
*c) They automate rule enforcement or auditing upon data changes
d) They make schema migrations faster

6. What is a common use case for an AFTER INSERT trigger?
a) To validate a field before data is written
b) To prevent duplicate entries before insertion
*c) To record the new row in an audit log after it is saved
d) To enforce default values before insertion

7. Which trigger timing would be used to validate input before a record is committed to the table?
*a) BEFORE trigger
b) AFTER trigger
c) DELAYED trigger
d) DEFERRED trigger

8. In PostgreSQL, what happens if an error occurs during a transaction without an exception handler?
a) The transaction continues but logs an error
*b) The transaction automatically rolls back entirely
c) The current statement is skipped but others run
d) The database enters read-only mode

9. What is the main difference between a function and a procedure in PostgreSQL (since version 11)?
*a) Procedures can use transaction control commands like COMMIT or ROLLBACK
b) Functions are always faster than procedures
c) Procedures can return table data directly
d) Functions cannot be called from SQL

10. In an auditing system, which of the following best describes idempotency in trigger or procedure design?
a) Running a trigger multiple times increases accuracy
*b) Executing the same operation multiple times leaves the database in the same state
c) It prevents all updates and deletes automatically
d) It ensures triggers always fire once per session
