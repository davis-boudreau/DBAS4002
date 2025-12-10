1. What does the EXPLAIN command in PostgreSQL do?
a) Shows the physical database structure
*b) Displays the query execution plan and cost estimates
c) Analyzes only the number of rows in a table
d) Automatically creates indexes for slow queries

2. What is the main benefit of creating an index on a column?
*a) It speeds up data retrieval operations by reducing scan time
b) It compresses the data for faster loading
c) It prevents duplicate values from being inserted
d) It automatically enforces referential integrity

3. What is the potential downside of having too many indexes on a table?
a) The SELECT queries become slower
*b) INSERT, UPDATE, and DELETE operations become slower due to index maintenance
c) Indexes consume no additional disk space
d) PostgreSQL ignores extra indexes automatically

4. What is the difference between a clustered and non-clustered index?
*a) A clustered index determines the physical order of rows in the table
b) A clustered index only applies to views
c) A non-clustered index can only be used on primary keys
d) There is no difference in PostgreSQL

5. Which of the following commands shows both the execution plan and actual run times of a query?
a) ANALYZE PLAN
b) EXPLAIN COST
c) SHOW PLAN
*d) EXPLAIN ANALYZE

6. What does a “Sequential Scan” in an EXPLAIN plan indicate?
*a) The database is scanning every row in the table
b) The query is using an existing index efficiently
c) The plan is invalid due to missing statistics
d) The optimizer is rewriting the query for parallelism

7. What is a “covering index”?
a) An index that includes foreign key columns only
*b) An index that contains all columns needed by a query, avoiding a table lookup
c) A backup index used for failover systems
d) An index that is clustered automatically by PostgreSQL

8. Why is batching multiple inserts often more efficient than single-row inserts?
a) It uses fewer locks per transaction
b) It improves referential integrity
*c) It reduces transaction overhead and network round trips
d) It disables triggers for better performance

9. What is parameter sniffing in SQL query performance?
*a) When the optimizer caches a plan based on the first parameter values
b) When a query fails due to null parameters
c) When indexes are sniffed for corruption
d) When the database adjusts memory parameters automatically

10. What is the primary goal of query optimization in PostgreSQL?
a) To generate random query plans for testing
b) To increase memory usage for faster execution
*c) To minimize execution cost and improve performance consistency
d) To automatically rewrite all SQL into procedural code
