1. Which SQL command defines a new table’s structure?
   a) UPDATE
   *b) CREATE TABLE
   c) INSERT
   d) ALTER TABLE

2. What is the primary key’s main purpose?
   a) Speed query performance
   *b) Ensure each row is uniquely identifiable
   c) Link tables together automatically
   d) Allow NULL values

3. Which constraint prevents duplicate email addresses in a table?
   a) CHECK
   *b) UNIQUE
   c) FOREIGN KEY
   d) DEFAULT

4. In a relational schema, what ensures referential integrity?
   a) PRIMARY KEY
   b) UNIQUE
   *c) FOREIGN KEY
   d) NOT NULL

5. Which SQL clause filters rows after aggregation?
   a) WHERE
   *b) HAVING
   c) ORDER BY
   d) GROUP BY

6. What is the result of a LEFT JOIN?
   a) Only matching rows from both tables
   b) Only rows from the right table
   *c) All rows from the left table plus matches from the right
   d) Rows that exist in both tables only

7. Which statement removes a table and its structure?
   *a) DROP TABLE
   b) DELETE FROM
   c) TRUNCATE
   d) ALTER TABLE DROP COLUMN

8. What does “normalization” primarily aim to reduce?
   a) Queries
   *b) Data redundancy
   c) Indexes
   d) Keys

9. Which SQL function returns the total number of rows?
   *a) COUNT()
   b) AVG()
   c) SUM()
   d) MAX()

10. In PostgreSQL, what does a CHECK constraint do?
    *a) Restricts column values to specific conditions
    b) Ensures values are unique
    c) Defines foreign-key behavior
    d) Sorts data during SELECT

11. Which keyword combines query results and removes duplicates?
    a) UNION ALL
    *b) UNION
    c) INTERSECT
    d) EXCEPT

12. What is the purpose of an alias in SQL?
    a) Rename a table permanently
    *b) Give a temporary name to a column or table
    c) Create a new index
    d) Store data in memory

13. Which command displays query execution details in PostgreSQL?
    a) ANALYZE PLAN
    *b) EXPLAIN ANALYZE
    c) TRACE PLAN
    d) SHOW QUERY

14. Which type of join returns rows that match on both sides only?
    *a) INNER JOIN
    b) LEFT JOIN
    c) RIGHT JOIN
    d) FULL JOIN

15. Which clause orders query results alphabetically by event name?
    a) WHERE event_name
    *b) ORDER BY event_name ASC
    c) SORT BY event_name DESC
    d) GROUP BY event_name

16. What is the difference between a view and a table?
    a) A view stores physical data
    b) A table is temporary
    *c) A view is a saved query that doesn’t store data itself
    d) They are identical

17. Which SQL keyword ensures no NULL values in a column?
    *a) NOT NULL
    b) UNIQUE
    c) CHECK
    d) DEFAULT

18. What command permanently saves all changes in a transaction?
    a) ROLLBACK
    b) SAVEPOINT
    *c) COMMIT
    d) BEGIN

19. In a Dockerized PostgreSQL environment, which tool lets you access SQL directly?
    a) pgAdmin browser only
    *b) psql shell inside the container
    c) Docker Dashboard
    d) YAML configuration

20. What’s the purpose of using a FOREIGN KEY … ON DELETE CASCADE rule?
    a) Prevents deletes
    b) Copies data to another table
    *c) Automatically removes dependent rows when a parent is deleted
    d) Ignores referential checks

21. What does the GROUP BY clause do?
    a) Orders rows
    *b) Groups rows that share common column values
    c) Filters results
    d) Deletes duplicates

22. Which aggregate function returns the highest numeric value?
    a) AVG()
    b) SUM()
    *c) MAX()
    d) MIN()

23. Which SQL keyword combines two result sets and keeps all duplicates?
    a) UNION
    b) INTERSECT
    *c) UNION ALL
    d) JOIN

24. In the Event Management schema, which field in the Event table references the Category table?
    *a) category_id
    b) event_id
    c) organizer
    d) participant_id

25. When analyzing performance, what does an execution plan show?
    a) Only runtime errors
    b) Table row counts
    *c) How the database will access and join data
    d) Only syntax issues

26. What does the keyword `DISTINCT` do in a SELECT statement?
    a) Sorts results alphabetically
    *b) Removes duplicate rows from the output
    c) Groups rows by unique values
    d) Filters rows based on a condition

27. Which SQL clause determines how rows are grouped for aggregate calculations?
    *a) GROUP BY
    b) WHERE
    c) HAVING
    d) ORDER BY

28. In an ER diagram, what does a crow’s-foot symbol typically represent?
    a) Primary key
    *b) One-to-many relationship
    c) Unique constraint
    d) Foreign key reference

29. What does the PostgreSQL command `\dt` display in psql?
    *a) A list of all tables in the current schema
    b) The definition of a single table
    c) The data inside a table
    d) All database users

30. What is the main advantage of using Docker Compose for PostgreSQL labs?
    a) It encrypts all database data automatically
    *b) It standardizes the environment across student machines
    c) It optimizes SQL queries automatically
    d) It provides graphical dashboards only

31. Which keyword limits the number of rows returned in PostgreSQL?
    a) FETCH ALL
    b) OFFSET
    *c) LIMIT
    d) WHERE ROWNUM

32. What keyword is used to combine rows from two queries including duplicates?
    a) INTERSECT
    *b) UNION ALL
    c) UNION
    d) JOIN

33. Which SQL clause is evaluated first in a query’s logical order of execution?
    a) ORDER BY
    *b) FROM
    c) SELECT
    d) GROUP BY

34. What is the function of the DEFAULT constraint?
    *a) Provides an automatic value when none is supplied
    b) Prevents NULL values
    c) Ensures uniqueness
    d) Triggers auto-increment behavior

35. What type of join includes all rows from both tables, matching where possible?
    a) INNER JOIN
    *b) FULL OUTER JOIN
    c) RIGHT JOIN
    d) LEFT JOIN

36. What statement permanently removes all rows from a table but keeps its structure?
    a) DROP TABLE
    *b) TRUNCATE TABLE
    c) DELETE FROM
    d) RESET TABLE

37. What does an aggregate function operate on?
    a) Individual columns only
    b) Schema metadata
    *c) Sets of rows to produce a single result value
    d) Stored procedures

38. Which SQL function returns the average of numeric values?
    a) MAX()
    *b) AVG()
    c) COUNT()
    d) MEDIAN()

39. Which constraint ensures that an event’s end date occurs after its start date?
    a) UNIQUE
    b) DEFAULT
    *c) CHECK
    d) FOREIGN KEY

40. In PostgreSQL, which data type stores long text such as event descriptions?
    a) VARCHAR(50)
    b) CHAR(255)
    *c) TEXT
    d) SMALLTEXT

41. What keyword is used to create a relationship between two tables?
    a) JOINED BY
    b) LINK TABLE
    *c) FOREIGN KEY
    d) RELATE TO

42. Which PostgreSQL function returns the current system date and time?
    a) NOW()
    *b) CURRENT_TIMESTAMP
    c) GETDATE()
    d) SYSDATE()

43. When executing a multi-table query, which operator specifies the linking condition?
    a) USING JOIN
    b) LINK BY
    *c) ON
    d) WITH

44. Which clause restricts rows *before* aggregation takes place?
    *a) WHERE
    b) HAVING
    c) GROUP BY
    d) LIMIT

45. What does `\i /sql/03_seed.sql` do inside psql?
    a) Inserts a single record
    *b) Executes the SQL commands from the seed file
    c) Displays all indexes
    d) Starts the Docker container

46. What is the effect of using `ORDER BY column DESC`?
    a) Randomizes the order of rows
    *b) Sorts results in descending order
    c) Filters out NULL values
    d) Displays only duplicates

47. Which ACID property ensures that once a transaction is committed, it remains saved?
    a) Isolation
    *b) Durability
    c) Atomicity
    d) Consistency

48. What does the keyword `SERIAL` provide when defining a column in PostgreSQL?
    a) Encrypted data type
    b) Random number generator
    *c) Auto-incrementing integer sequence
    d) Primary-key constraint automatically

49. Why might you use a window function instead of GROUP BY?
    *a) To calculate aggregates while retaining individual row details
    b) To combine data from multiple tables
    c) To limit rows returned
    d) To enforce referential integrity

50. Which command in PostgreSQL displays all installed extensions?
    a) SHOW EXTENSIONS;
    b) \el
    *c) \dx
    d) LIST EXTENSIONS
