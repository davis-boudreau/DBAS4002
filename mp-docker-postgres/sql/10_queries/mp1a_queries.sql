/* ============================================================
   File: mp1a_queries.sql
   Author: <Student Name>
   Course: DBAS 3200 / DBAS 4002
   Mini-Project 1A – Join & Subquery Suite
   Description:
     Demonstrates SQL proficiency with JOINs, subqueries, and
     relational integrity using the Event Management schema.
   ============================================================ */

/*
    Each query represents a learning checkpoint:
    Queries 1–3 → mastering JOINs
    Queries 4–6 → mastering aggregation and subqueries
    Queries 7–10 → mastering filtering, sets, and functions
*/

/* ------------------------------------------------------------
   Query 1 – List all events with their category name.
   Demonstrates INNER JOIN and column aliasing.
   ------------------------------------------------------------ */
SELECT 
    e.event_id,
    e.name AS event_name,
    c.name AS category_name,
    e.start_date,
    e.end_date,
    e.location
FROM event e
INNER JOIN category c ON e.category_id = c.category_id
ORDER BY e.start_date;


/* ------------------------------------------------------------
   Query 2 – Show all participants and the events they are registered for.
   Demonstrates multi-table JOIN across Registration + Event + Participant.
   ------------------------------------------------------------ */
SELECT 
    p.participant_id,
    p.first_name || ' ' || p.last_name AS participant_name,
    e.name AS event_name,
    e.start_date,
    r.payment_status
FROM registration r
INNER JOIN participant p ON r.participant_id = p.participant_id
INNER JOIN event e ON r.event_id = e.event_id
ORDER BY participant_name;


/* ------------------------------------------------------------
   Query 3 – Find events that currently have no registrations.
   Demonstrates LEFT JOIN and NULL filtering.
   ------------------------------------------------------------ */
SELECT 
    e.name AS unregistered_event,
    e.start_date,
    e.location
FROM event e
LEFT JOIN registration r ON e.event_id = r.event_id
WHERE r.registration_id IS NULL
ORDER BY e.name;


/* ------------------------------------------------------------
   Query 4 – Count total registrations per category.
   Demonstrates aggregate functions and GROUP BY.
   ------------------------------------------------------------ */
SELECT 
    c.name AS category_name,
    COUNT(r.registration_id) AS total_registrations
FROM category c
LEFT JOIN event e ON c.category_id = e.category_id
LEFT JOIN registration r ON e.event_id = r.event_id
GROUP BY c.name
ORDER BY total_registrations DESC;


/* ------------------------------------------------------------
   Query 5 – Find participants who have registered for more than one event.
   Demonstrates HAVING clause with GROUP BY.
   ------------------------------------------------------------ */
SELECT 
    p.participant_id,
    p.first_name || ' ' || p.last_name AS participant_name,
    COUNT(r.event_id) AS num_events_registered
FROM participant p
INNER JOIN registration r ON p.participant_id = r.participant_id
GROUP BY p.participant_id, participant_name
HAVING COUNT(r.event_id) > 1
ORDER BY num_events_registered DESC;


/* ------------------------------------------------------------
   Query 6 – Find the most popular event(s) by registration count.
   Demonstrates subquery comparison.
   ------------------------------------------------------------ */
SELECT 
    e.name AS popular_event,
    COUNT(r.registration_id) AS registration_count
FROM event e
INNER JOIN registration r ON e.event_id = r.event_id
GROUP BY e.name
HAVING COUNT(r.registration_id) = (
    SELECT MAX(reg_count)
    FROM (
        SELECT COUNT(r2.registration_id) AS reg_count
        FROM event e2
        INNER JOIN registration r2 ON e2.event_id = r2.event_id
        GROUP BY e2.event_id
    ) AS sub
);


/* ------------------------------------------------------------
   Query 7 – List all participants who have not paid for an event.
   Demonstrates WHERE filtering and set membership.
   ------------------------------------------------------------ */
SELECT 
    DISTINCT p.first_name || ' ' || p.last_name AS unpaid_participant,
    r.payment_status
FROM participant p
INNER JOIN registration r ON p.participant_id = r.participant_id
WHERE r.payment_status <> 'Paid'
ORDER BY unpaid_participant;


/* ------------------------------------------------------------
   Query 8 – Display events happening in the next 30 days.
   Demonstrates date arithmetic and current_timestamp.
   ------------------------------------------------------------ */
SELECT 
    e.name AS upcoming_event,
    e.start_date,
    e.end_date,
    e.location
FROM event e
WHERE e.start_date BETWEEN CURRENT_DATE AND (CURRENT_DATE + INTERVAL '30 days')
ORDER BY e.start_date;


/* ------------------------------------------------------------
   Query 9 – List categories with their average event duration (in days).
   Demonstrates date functions and AVG aggregate.
   ------------------------------------------------------------ */
SELECT 
    c.name AS category_name,
    ROUND(AVG(e.end_date - e.start_date), 2) AS avg_duration_days
FROM category c
INNER JOIN event e ON c.category_id = e.category_id
GROUP BY c.name
ORDER BY avg_duration_days DESC;


/* ------------------------------------------------------------
   Query 10 – Find participants who have not registered for any event.
   Demonstrates NOT IN subquery.
   ------------------------------------------------------------ */
SELECT 
    p.participant_id,
    p.first_name || ' ' || p.last_name AS participant_name
FROM participant p
WHERE p.participant_id NOT IN (
    SELECT DISTINCT r.participant_id FROM registration r
)
ORDER BY participant_name;


/* ============================================================
   End of File
   ============================================================ */
