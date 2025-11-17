/* ============================================================
   File: 03_seed.sql
   Author: <Student Name>
   Course: DBAS 3200 / DBAS 4002
   Description:
     Seed data for Event Management System.
     Populates Category, Event, Participant, and Registration tables.
   ============================================================ */

-- ============================================================
-- Step 1. Reset tables (optional for repeatable runs)
-- ============================================================
TRUNCATE TABLE registration RESTART IDENTITY CASCADE;
TRUNCATE TABLE event RESTART IDENTITY CASCADE;
TRUNCATE TABLE category RESTART IDENTITY CASCADE;
TRUNCATE TABLE participant RESTART IDENTITY CASCADE;

-- ============================================================
-- Step 2. Insert Categories
-- ============================================================
INSERT INTO category (name)
VALUES
('Technology'),
('Health & Wellness'),
('Education'),
('Arts & Culture'),
('Business & Entrepreneurship');

-- ============================================================
-- Step 3. Insert Events
-- ============================================================
INSERT INTO event (name, category_id, start_date, end_date, priority, description, location, organizer)
VALUES
('PostgreSQL for Developers', 1, '2025-03-15 09:00:00', '2025-03-15 16:00:00', 3, 'A practical workshop on PostgreSQL basics and advanced SQL.', 'Halifax Campus', 'Davis Boudreau'),
('AI in Healthcare Symposium', 2, '2025-04-02 10:00:00', '2025-04-02 15:00:00', 2, 'Exploring ethical applications of AI in medical contexts.', 'NSCC Strait Area Campus', 'Dr. Allison Keane'),
('Modern Pedagogy Summit', 3, '2025-04-10 09:00:00', '2025-04-10 17:00:00', 4, 'Innovative strategies for digital and blended learning.', 'Sydney Learning Commons', 'Elaine Rivers'),
('Watercolour Art Retreat', 4, '2025-05-05 09:00:00', '2025-05-07 16:00:00', 1, 'A relaxing 3-day hands-on retreat focused on landscape painting.', 'Cape Breton Studio', 'Cora Healy'),
('Entrepreneurship Bootcamp', 5, '2025-06-01 08:00:00', '2025-06-03 18:00:00', 5, 'Intensive workshop for aspiring local entrepreneurs.', 'Port Hawkesbury Hub', 'Davis Boudreau'),
('Wellness for Developers', 2, '2025-06-10 09:00:00', '2025-06-10 14:00:00', 3, 'Mindfulness and ergonomic practices for IT professionals.', 'NSCC IT Building', 'Dr. Jason Nguyen'),
('Cloud Security Best Practices', 1, '2025-06-20 10:00:00', '2025-06-20 17:00:00', 4, 'Exploring DevSecOps methods for securing cloud environments.', 'Virtual Conference', 'Alyssa Tran');

-- ============================================================
-- Step 4. Insert Participants
-- ============================================================
INSERT INTO participant (first_name, last_name, email, phone)
VALUES
('Alice', 'Morrison', 'alice.morrison@example.com', '902-555-1122'),
('Brandon', 'Lee', 'brandon.lee@example.com', '902-555-1345'),
('Carla', 'Nguyen', 'carla.nguyen@example.com', '902-555-2098'),
('David', 'Stevens', 'david.stevens@example.com', '902-555-3357'),
('Elena', 'Kirk', 'elena.kirk@example.com', '902-555-4466'),
('Frank', 'Peters', 'frank.peters@example.com', '902-555-5544'),
('Grace', 'O\Brien', 'grace.obrien@example.com', '902-555-6767'),
('Henry', 'White', 'henry.white@example.com', '902-555-7878'),
('Isabella', 'Chen', 'isabella.chen@example.com', '902-555-8080'),
('Jake', 'Thompson', 'jake.thompson@example.com', '902-555-9191');

-- ============================================================
-- Step 5. Insert Registrations
-- ============================================================
INSERT INTO registration (event_id, participant_id, payment_status)
VALUES
(1, 1, 'Paid'),
(1, 2, 'Pending'),
(2, 3, 'Paid'),
(2, 4, 'Paid'),
(2, 5, 'Cancelled'),
(3, 6, 'Paid'),
(3, 7, 'Paid'),
(3, 8, 'Pending'),
(4, 9, 'Paid'),
(5, 10, 'Paid'),
(5, 1, 'Paid'),
(5, 3, 'Pending'),
(6, 2, 'Paid'),
(6, 7, 'Pending'),
(7, 8, 'Paid'),
(7, 9, 'Paid');

-- ============================================================
-- Step 6. Verify Data Loads
-- ============================================================
SELECT 'Categories:' AS section_label;
SELECT * FROM category;

SELECT 'Events:' AS section_label;
SELECT event_id, name, category_id, start_date, end_date, location FROM event;

SELECT 'Participants:' AS section_label;
SELECT participant_id, first_name, last_name FROM participant;

SELECT 'Registrations:' AS section_label;
SELECT registration_id, event_id, participant_id, payment_status FROM registration;

-- ============================================================
-- End of File
-- ============================================================