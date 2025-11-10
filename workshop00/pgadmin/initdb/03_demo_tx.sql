-- Isolation level demos & lock inspection helpers

-- Helpers: show active locks for our schema
CREATE OR REPLACE VIEW banking.locks AS
SELECT
  l.locktype, l.mode, l.granted,
  l.relation::regclass AS relation,
  a.usename, a.pid, a.state, a.query
FROM pg_locks l
JOIN pg_stat_activity a ON l.pid = a.pid
WHERE a.query NOT ILIKE '%pg_locks%'
ORDER BY a.pid;

-- Demo: Read phenomena at READ COMMITTED vs REPEATABLE READ
-- Session A:
--   BEGIN;
--   SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
--   SELECT balance FROM banking.accounts WHERE owner='Alice'; -- A1
-- Session B:
--   BEGIN;
--   UPDATE banking.accounts SET balance = balance + 100 WHERE owner='Alice';
--   COMMIT;
-- Session A:
--   SELECT balance FROM banking.accounts WHERE owner='Alice'; -- A2 (may see new value at READ COMMITTED)
--   ROLLBACK;

-- Deadlock demo (run in two sessions):
-- Session 1:
--   BEGIN;
--   UPDATE banking.accounts SET balance = balance + 10 WHERE owner='Alice'; -- lock row A
--   SELECT * FROM banking.locks;
--   -- then try to lock Bob
--   UPDATE banking.accounts SET balance = balance + 10 WHERE owner='Bob';

-- Session 2:
--   BEGIN;
--   UPDATE banking.accounts SET balance = balance + 10 WHERE owner='Bob';   -- lock row B
--   -- then try to lock Alice
--   UPDATE banking.accounts SET balance = balance + 10 WHERE owner='Alice';
--   -- one session will deadlock and be aborted by PG

-- Serializable anomaly prevention demo:
-- In two sessions under SERIALIZABLE, try interleaved transfers and see serialization failures.