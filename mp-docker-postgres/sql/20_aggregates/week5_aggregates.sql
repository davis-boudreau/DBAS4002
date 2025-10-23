-- Aggregates: totals per category
SELECT c.name AS category, COUNT(e.event_id) AS total
FROM Category c
LEFT JOIN Event e ON e.category_id = c.category_id
GROUP BY c.name
HAVING COUNT(e.event_id) >= 0
ORDER BY total DESC, c.name;

-- Aggregates: avg & max duration (minutes)
SELECT c.name AS category,
       AVG(EXTRACT(EPOCH FROM (e.end_date - e.start_date))/60.0) AS avg_minutes,
       MAX(EXTRACT(EPOCH FROM (e.end_date - e.start_date))/60.0) AS max_minutes
FROM Category c
JOIN Event e ON e.category_id = c.category_id
GROUP BY c.name;

-- Window: rank categories by volume
SELECT category,
       total,
       RANK() OVER (ORDER BY total DESC) AS volume_rank
FROM (
  SELECT c.name AS category, COUNT(e.event_id) AS total
  FROM Category c
  LEFT JOIN Event e ON e.category_id = c.category_id
  GROUP BY c.name
) t;

-- Window: running count by start_date
SELECT e.name,
       e.start_date,
       COUNT(*) OVER (ORDER BY e.start_date) AS running_total
FROM Event e
ORDER BY e.start_date;

-- Window vs Aggregate comparison: value vs group avg (priority)
SELECT e.name,
       e.priority,
       AVG(e.priority) OVER (PARTITION BY e.category_id) AS avg_priority_in_cat
FROM Event e;
