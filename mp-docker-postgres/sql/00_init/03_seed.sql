-- Minimal seed (3 categories, a few events) (Week 4)
INSERT INTO Category (name) VALUES
('Workshop'), ('Conference'), ('Webinar')
ON CONFLICT DO NOTHING;

INSERT INTO Event (name, start_date, end_date, priority, description, location, organizer, category_id)
VALUES
('Intro to SQL',        '2025-09-20 10:00', '2025-09-20 16:00', 1, '',            'Online',  'Jane Doe', (SELECT category_id FROM Category WHERE name='Workshop')),
('AI in Healthcare',    '2025-10-01 09:00', '2025-10-01 17:00', 2, 'Talks',       'Toronto', 'Dr. Smith',(SELECT category_id FROM Category WHERE name='Conference')),
('Data Science 101',    '2025-09-25 18:00', '2025-09-25 20:00', 3, NULL,          'Zoom',    'Tech Org', (SELECT category_id FROM Category WHERE name='Webinar')),
('Cloud Summit',        '2025-11-10 09:00', '2025-11-12 17:00', 2, 'Multi-day',   NULL,      'Cloud Inc',(SELECT category_id FROM Category WHERE name='Conference'))
ON CONFLICT DO NOTHING;
