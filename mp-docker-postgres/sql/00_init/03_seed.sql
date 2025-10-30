INSERT INTO Category (name)
VALUES ('Workshop'), ('Seminar'), ('Conference');

INSERT INTO Event (name, category_id, start_date, end_date, priority, description, location, organizer)
VALUES
('Database Fundamentals', 1, '2025-09-10 09:00', '2025-09-10 16:00', 2, 'Introductory SQL Workshop', 'Room 201', 'NSCC IT Dept'),
('Cloud Security Summit', 3, '2025-10-05 10:00', '2025-10-07 17:00', 3, 'Multi-day conference', 'Halifax Convention Centre', 'Tech NS'),
('DevOps 101', 1, '2025-10-15 13:00', '2025-10-15 17:00', 1, 'Hands-on Docker workshop', 'Room 305', 'NSCC IT Dept');

INSERT INTO Participant (first_name, last_name, email)
VALUES
('Alice', 'Johnson', 'alice.johnson@example.com'),
('Bob', 'Martens', 'bob.martens@example.com'),
('Carol', 'Nguyen', 'carol.nguyen@example.com');

INSERT INTO Registration (event_id, participant_id, payment_status)
VALUES
(1, 1, 'Paid'),
(1, 2, 'Pending'),
(2, 3, 'Paid');