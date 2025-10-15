-- 1) INNER JOIN – items with categories
SELECT e.name AS item, c.name AS category, e.start_date, e.end_date
FROM Event e
JOIN Category c ON e.category_id = c.category_id;
-- Expect: all events with their category names

-- 2) LEFT JOIN – categories, even if no items
SELECT c.name AS category, e.name AS item
FROM Category c
LEFT JOIN Event e ON c.category_id = e.category_id
ORDER BY c.name, e.name NULLS LAST;
-- Expect: categories appear even if item is NULL

-- 3) Additional JOIN – INNER + predicate
SELECT e.name, e.location
FROM Event e
JOIN Category c ON e.category_id = c.category_id
WHERE c.name = 'Conference' AND COALESCE(e.location, '') <> '';
-- Expect: only conferences that have a location set

-- 4) WHERE Subquery – items belonging to a sub-selected category
SELECT name, start_date
FROM Event
WHERE category_id = (
  SELECT category_id FROM Category WHERE name = 'Workshop'
);
-- Expect: Workshop events

-- 5) SELECT Subquery (scalar) – count per category
SELECT c.name AS category,
       (SELECT COUNT(*) FROM Event e WHERE e.category_id = c.category_id) AS item_count
FROM Category c
ORDER BY item_count DESC, c.name;
-- Expect: one row per category with count

-- 6) Set Operation (UNION) – combine different domains
SELECT organizer AS name FROM Event WHERE organizer IS NOT NULL
UNION
SELECT name FROM Category;
-- Expect: unique list that contains all organizers + categories
