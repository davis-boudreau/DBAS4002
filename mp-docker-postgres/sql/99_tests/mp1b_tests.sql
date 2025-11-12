/* ============================================================
   File: 99_tests/mp1b_tests.sql
   Course: DBAS 3200 / DBAS 4002
   Title: MP1B Integrity & Constraint Validation Tests
   Description:
     Validates integrity rules, constraints, and relationships
     defined in 02_constraints.sql using controlled test cases.
   ============================================================ */

-- ============================================================
-- Setup
-- ============================================================
\echo '🔧 Running constraint validation tests...'

-- Optional: clean testing space
BEGIN;

-- ============================================================
-- TEST 1 – Foreign key enforcement (registration → event)
-- ============================================================
\echo 'TEST 1: Foreign Key Integrity (Expect ERROR)'
INSERT INTO registration (event_id, participant_id, payment_status)
VALUES (9999, 1, 'Paid');
-- Expected: ERROR - violates fk_registration_event

-- ============================================================
-- TEST 2 – Foreign key enforcement (registration → participant)
-- ============================================================
\echo 'TEST 2: Foreign Key Integrity (Expect ERROR)'
INSERT INTO registration (event_id, participant_id, payment_status)
VALUES (1, 9999, 'Paid');
-- Expected: ERROR - violates fk_registration_participant

-- ============================================================
-- TEST 3 – Unique participant per event
-- ============================================================
\echo 'TEST 3: Unique Registration (Expect ERROR on duplicate)'
INSERT INTO registration (event_id, participant_id, payment_status)
VALUES (1, 1, 'Paid');
-- Expected: ERROR - violates uq_registration_event_participant

-- ============================================================
-- TEST 4 – Event date validation
-- ============================================================
\echo 'TEST 4: Event Date Constraint (Expect ERROR)'
INSERT INTO event (name, category_id, start_date, end_date, priority, description, location, organizer)
VALUES ('Invalid Event', 1, '2025-06-10', '2025-06-05', 3, 'End date before start date', 'Test Hall', 'System');
-- Expected: ERROR - violates chk_event_dates

-- ============================================================
-- TEST 5 – Priority constraint
-- ============================================================
\echo 'TEST 5: Event Priority Range (Expect ERROR)'
INSERT INTO event (name, category_id, start_date, end_date, priority, description, location, organizer)
VALUES ('Out of Range', 1, '2025-06-10', '2025-06-11', 9, 'Invalid priority > 5', 'Lab', 'System');
-- Expected: ERROR - violates chk_event_priority

-- ============================================================
-- TEST 6 – Payment status validation
-- ============================================================
\echo 'TEST 6: Payment Status Check (Expect ERROR)'
INSERT INTO registration (event_id, participant_id, payment_status)
VALUES (2, 3, 'Unknown');
-- Expected: ERROR - violates chk_registration_payment_status

-- ============================================================
-- TEST 7 – Unique email enforcement
-- ============================================================
\echo 'TEST 7: Participant Unique Email (Expect ERROR)'
INSERT INTO participant (first_name, last_name, email, phone)
VALUES ('Test', 'User', 'alice.morrison@example.com', '902-555-1234');
-- Expected: ERROR - violates uq_participant_email

-- ============================================================
-- TEST 8 – Referential integrity on delete
-- ============================================================
\echo 'TEST 8: ON DELETE CASCADE Validation'
-- Before delete
SELECT COUNT(*) AS before_delete_count FROM registration WHERE event_id = 1;

-- Delete event with existing registrations
DELETE FROM event WHERE event_id = 1;

-- After delete (should remove linked registrations automatically)
SELECT COUNT(*) AS after_delete_count FROM registration WHERE event_id = 1;
-- Expected: before_delete_count > 0, after_delete_count = 0

ROLLBACK;
\echo '🧩 Tests completed (transaction rolled back).'
