/* ============================================================
   File: 99_tests/mp2_testcases.sql
   Course: DBAS 4002 – Transactional Database Programming
   Title: MP2 – Transactional Logic & Auditing Test Suite
   Description:
     Validates:
       - Stored procedure behavior (create_event)
       - Transaction commit / rollback paths
       - AFTER INSERT trigger logging to audit_log
       - BEFORE DELETE trigger preventing category deletes
   Run via:
     make psql
     \i /sql/99_tests/mp2_testcases.sql
   ============================================================ */

\echo '============================================================'
\echo ' MP2 TEST SUITE – PROCEDURES, TRANSACTIONS & AUDITING'
\echo '============================================================'

\echo 'Step 0: Show current connection context'
\conninfo
SELECT CURRENT_USER AS current_user, CURRENT_DATABASE() AS current_database;

-- Optional: show current table state
\echo 'Step 0a: Current row counts before tests'
SELECT 'category' AS table_name, COUNT(*) AS row_count FROM category
UNION ALL
SELECT 'event', COUNT(*) FROM event
UNION ALL
SELECT 'audit_log', COUNT(*) FROM audit_log;

-- ============================================================
-- TEST 1 – Successful create_event call triggers COMMIT + audit
-- ============================================================
\echo ''
\echo '------------------------------------------------------------'
\echo 'TEST 1: Successful create_event() call with valid dates'
\echo '  Expectation:'
\echo '    - New row appears in event'
\echo '    - AFTER INSERT trigger writes to audit_log'
\echo '------------------------------------------------------------'

BEGIN;

CALL create_event(
  'MP2 Valid Event 01',
  1,                                    -- assumes category_id = 1 exists
  '2025-10-01 09:00:00',
  '2025-10-01 12:00:00',
  2,
  'Valid test event for MP2 Test 1',
  'Room 101',
  'Test User'
);

-- Show the last inserted event (by name pattern)
SELECT event_id, name, start_date, end_date, priority
FROM event
WHERE name = 'MP2 Valid Event 01';

-- Show latest audit_log entries for event table
SELECT audit_id, table_name, action, record_id, change_time
FROM audit_log
WHERE table_name = 'event'
ORDER BY audit_id DESC
LIMIT 5;

COMMIT;

\echo 'TEST 1 COMPLETE: Check that at least one event and one audit_log row were added.'

-- ============================================================
-- TEST 2 – Invalid dates cause EXCEPTION and ROLLBACK
-- ============================================================
\echo ''
\echo '------------------------------------------------------------'
\echo 'TEST 2: create_event() with invalid dates (end <= start)'
\echo '  Expectation:'
\echo '    - Procedure raises EXCEPTION'
\echo '    - No event row is committed'
\echo '    - No audit_log row is written for this attempt'
\echo '------------------------------------------------------------'

-- Capture row counts before the failing call
SELECT COUNT(*) AS event_before FROM event;
SELECT COUNT(*) AS audit_before FROM audit_log;

-- We intentionally allow the error to surface so students see it:
DO $$
BEGIN
  RAISE NOTICE 'Calling create_event() with invalid date range...';
  BEGIN
    CALL create_event(
      'MP2 Invalid Event 02',
      1,
      '2025-10-05 14:00:00',
      '2025-10-05 10:00:00',  -- invalid: end before start
      1,
      'This should fail due to end_date <= start_date',
      'Room 102',
      'Test User'
    );
  EXCEPTION
    WHEN OTHERS THEN
      RAISE NOTICE 'As expected, create_event() failed: %', SQLERRM;
  END;
END $$;

-- Re-check row counts after
SELECT COUNT(*) AS event_after FROM event;
SELECT COUNT(*) AS audit_after FROM audit_log;

\echo 'TEST 2 COMPLETE: event_after should equal event_before,'
\echo '                audit_after should equal audit_before.'

-- ============================================================
-- TEST 3 – AFTER INSERT trigger idempotence & logging behavior
-- ============================================================
\echo ''
\echo '------------------------------------------------------------'
\echo 'TEST 3: Multiple valid inserts – verify each is logged'
\echo '  Expectation:'
\echo '    - Each successful insert creates one audit_log row'
\echo '------------------------------------------------------------'

BEGIN;

-- Count audit_log entries for event before
SELECT COUNT(*) AS audit_event_before
FROM audit_log
WHERE table_name = 'event' AND action = 'INSERT';

CALL create_event(
  'MP2 Valid Event 03',
  1,
  '2025-10-10 09:00:00',
  '2025-10-10 11:00:00',
  3,
  'Trigger logging test 1',
  'Lab 201',
  'Test User'
);

CALL create_event(
  'MP2 Valid Event 04',
  1,
  '2025-10-11 09:00:00',
  '2025-10-11 11:00:00',
  3,
  'Trigger logging test 2',
  'Lab 202',
  'Test User'
);

-- Count audit_log entries for event after
SELECT COUNT(*) AS audit_event_after
FROM audit_log
WHERE table_name = 'event' AND action = 'INSERT';

-- Show the most recent audit_log rows
SELECT audit_id, table_name, action, record_id, change_time
FROM audit_log
WHERE table_name = 'event'
ORDER BY audit_id DESC
LIMIT 10;

COMMIT;

\echo 'TEST 3 COMPLETE: audit_event_after should be'
\echo '                audit_event_before + 2.'

-- ============================================================
-- TEST 4 – BEFORE DELETE trigger prevents category deletion
-- ============================================================
\echo ''
\echo '------------------------------------------------------------'
\echo 'TEST 4: Attempt to delete category with existing events'
\echo '  Expectation:'
\echo '    - BEFORE DELETE trigger raises EXCEPTION'
\echo '    - Category row remains in the table'
\echo '------------------------------------------------------------'

-- Show categories and associated event counts
SELECT c.category_id, c.name, COUNT(e.event_id) AS event_count
FROM category c
LEFT JOIN event e ON e.category_id = c.category_id
GROUP BY c.category_id, c.name
ORDER BY c.category_id;

-- We will try to delete category_id = 1 (assuming it has events)
DO $$
DECLARE
  v_has_events BOOLEAN;
BEGIN
  SELECT EXISTS (
    SELECT 1 FROM event WHERE category_id = 1
  ) INTO v_has_events;

  IF NOT v_has_events THEN
    RAISE NOTICE 'WARNING: category_id = 1 has no events; add one before running this test for full effect.';
  END IF;

  BEGIN
    RAISE NOTICE 'Attempting to delete category_id = 1...';
    DELETE FROM category WHERE category_id = 1;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE NOTICE 'As expected, delete prevented: %', SQLERRM;
  END;
END $$;

-- Confirm category_id = 1 still exists
SELECT category_id, name
FROM category
WHERE category_id = 1;

\echo 'TEST 4 COMPLETE: category_id = 1 should still exist if it had events.'

-- ============================================================
-- TEST 5 – Safe delete of empty category
-- ============================================================
\echo ''
\echo '------------------------------------------------------------'
\echo 'TEST 5: Create a new category with no events and delete it'
\echo '  Expectation:'
\echo '    - BEFORE DELETE trigger allows delete (no referencing events)'
\echo '------------------------------------------------------------'

BEGIN;

-- Create a temporary category
INSERT INTO category (name)
VALUES ('MP2 Temp Category – Safe Delete')
RETURNING category_id;

-- Show the temp category
SELECT * FROM category
WHERE name = 'MP2 Temp Category – Safe Delete';

-- Now delete it
DELETE FROM category
WHERE name = 'MP2 Temp Category – Safe Delete';

-- Confirm deletion
SELECT * FROM category
WHERE name = 'MP2 Temp Category – Safe Delete';

COMMIT;

\echo 'TEST 5 COMPLETE: temp category should be gone with no exceptions raised.'

-- ============================================================
-- TEST 6 – Summary & Final State
-- ============================================================
\echo ''
\echo '------------------------------------------------------------'
\echo 'TEST 6: Final summary of key tables'
\echo '------------------------------------------------------------'

SELECT 'category' AS table_name, COUNT(*) AS row_count FROM category
UNION ALL
SELECT 'event', COUNT(*) FROM event
UNION ALL
SELECT 'audit_log', COUNT(*) FROM audit_log;

\echo 'MP2 TEST SUITE FINISHED.'
\echo 'Review the NOTICE output and SELECT results above to confirm:'
\echo '  - Successful events were inserted and logged.'
\echo '  - Invalid events were rolled back and not logged.'
\echo '  - Categories with events cannot be deleted.'
\echo '  - Empty categories can be safely removed.'