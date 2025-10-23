-- Expect failure: end_date before start_date
INSERT INTO Event (name, start_date, end_date, category_id)
VALUES ('Bad Dates', '2025-10-05 10:00', '2025-10-05 09:00',
        (SELECT category_id FROM Category LIMIT 1));

-- Expect failure: priority out of range
INSERT INTO Event (name, start_date, end_date, priority, category_id)
VALUES ('Bad Priority', '2025-10-06 10:00', '2025-10-06 12:00', 9,
        (SELECT category_id FROM Category LIMIT 1));
