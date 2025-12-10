1. What is the main purpose of distributing database workloads across multiple tiers?
a) To eliminate the need for indexes
*b) To separate concerns between application logic and database processing
c) To increase the size of transaction logs
d) To disable caching for consistency

2. What is connection pooling used for in an N-tier application?
*a) To reuse database connections efficiently and reduce overhead
b) To replicate schema changes between databases
c) To store transaction logs in memory
d) To enforce unique constraints at the application level

3. Which of the following best describes database replication?
a) Compressing data for faster queries
*b) Maintaining identical copies of data across multiple servers
c) Using JSON instead of relational tables
d) Converting stored procedures into views

4. Why is it important to analyze execution plans again after refactoring queries?
a) Because refactoring can change the logical structure and affect performance
b) Because indexes automatically drop after refactoring
*c) Because query rewrite might alter optimizer choices and execution paths
d) Because refactoring disables autovacuum

5. What is the main goal of refactoring stored procedures?
a) To convert them into triggers
*b) To improve readability, maintainability, and efficiency without changing behavior
c) To rewrite all code in Python
d) To remove exception handling for speed

6. In a distributed database design, what is a potential drawback of splitting data across nodes (sharding)?
*a) Increased complexity of transactions and consistency management
b) Reduced scalability of reads
c) Automatic index creation is disabled
d) Schema constraints are ignored by the optimizer

7. What is the purpose of using a read replica in PostgreSQL?
a) To process bulk deletes automatically
*b) To offload read queries from the primary server
c) To ensure exclusive locks on all read operations
d) To back up only schema definitions

8. During final showcase validation, why should EXPLAIN ANALYZE be re-run on production-like data?
*a) Because query cost and plan selection depend on data volume and distribution
b) Because it automatically adds indexes
c) Because it resets statistics
d) Because it drops slow queries

9. Which of the following best describes code comprehension in the refactoring phase?
a) Adding more procedural nesting to increase security
*b) Understanding existing routines to safely modify or optimize them
c) Translating all SQL code into comments
d) Removing all audit triggers for testing

10. In the context of showcasing a transactional system, what is the most important demonstration outcome?
a) Showing that the GUI runs on Django
*b) Proving that transactions, audits, and performance hold under concurrent load
c) Disabling all foreign keys for faster results
d) Using hardcoded test data to simplify the demo
