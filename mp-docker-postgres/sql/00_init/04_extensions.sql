CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS tablefunc;


/* ============================================================
   File: 04_extensions.sql
   Course: DBAS 3200 / DBAS 4002
   Stack: DBAS PostgreSQL DevOps Stack (v3.2)
   Purpose:
     Enable commonly used PostgreSQL extensions that improve
     query diagnostics, performance tuning, text matching,
     and data validation for the Event Management System.

   Each CREATE EXTENSION command includes a description
   of its purpose and why it's useful for developers.
   ============================================================ */

-- Set default schema for clarity
SET search_path TO public;

-- ============================================================
-- 1) PERFORMANCE MONITORING & DIAGNOSTICS
-- ============================================================

-- 🧠 pg_stat_statements:
-- Tracks execution statistics for all SQL statements executed.
-- This helps identify which queries consume the most time or I/O,
-- a crucial tool when tuning query performance in later workshops.
-- ⚙️ Requires PostgreSQL to be started with:
--     shared_preload_libraries='pg_stat_statements'
-- (The setting can be pre-configured in the Docker image.)
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- ============================================================
-- 2) TEXT SEARCH & CASE-INSENSITIVE MATCHING
-- ============================================================

-- 🔎 pg_trgm (Trigram Matching):
-- Provides similarity operators and indexes for fuzzy text search.
-- This lets you efficiently use queries like:
--     SELECT * FROM event WHERE name ILIKE '%postgres%';
-- Ideal for flexible matching of event names, locations, or organizers.
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- 🔤 citext (Case-Insensitive Text):
-- Creates a new text type that ignores case when comparing.
-- Very useful for attributes like email or usernames where
-- 'User@domain.com' and 'user@domain.com' should be treated as identical.
CREATE EXTENSION IF NOT EXISTS citext;

-- ============================================================
-- 3) ADVANCED INDEX SUPPORT PACKS
-- ============================================================

-- ⚡ btree_gin:
-- Extends GIN indexes to handle simple scalar types like int, text, and date.
-- It allows complex multi-column or expression-based indexes that combine
-- equality, range, and pattern searches efficiently.
CREATE EXTENSION IF NOT EXISTS btree_gin;

-- ⚙️ btree_gist:
-- Similar to btree_gin, but for GiST index types.
-- Enables indexing of data types that use ranges, geometries, and composites.
-- Often used in advanced indexing strategies or with exclusion constraints.
CREATE EXTENSION IF NOT EXISTS btree_gist;

-- ============================================================
-- 4) IDENTIFIERS, MATCHING, & UTILITY EXTENSIONS
-- ============================================================

-- 🧩 uuid-ossp:
-- Provides functions for generating Universally Unique Identifiers (UUIDs),
-- such as uuid_generate_v4(). These are useful when designing distributed
-- or microservice architectures where SERIAL IDs may conflict.
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 🔊 fuzzystrmatch:
-- Provides string comparison functions like levenshtein() and soundex().
-- Enables you to find similar-sounding or mistyped names
-- (e.g., “Jon Smith” vs. “John Smyth”) — useful for data cleaning.
CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;

-- 🔢 intarray:
-- Adds functions and operators for working with integer arrays,
-- supporting analytics and advanced filtering queries.
-- For example, you could easily query events where priority IN ARRAY[1,2,3].
CREATE EXTENSION IF NOT EXISTS intarray;

-- ============================================================
-- 5) OPTIONAL (COMMENTED OUT) — TURN ON WHEN NEEDED
-- ============================================================

-- Example A) Convert email column to case-insensitive type
-- Recommended once your dataset is clean of duplicate emails.
-- ALTER TABLE participant
--   ALTER COLUMN email TYPE citext;

-- Example B) Create trigram indexes for faster partial-text searches
-- CREATE INDEX IF NOT EXISTS idx_event_name_trgm
--   ON event USING gin (name gin_trgm_ops);
-- CREATE INDEX IF NOT EXISTS idx_event_description_trgm
--   ON event USING gin (description gin_trgm_ops);

-- Example C) Partial index for most common filter (“Paid” registrations)
-- CREATE INDEX IF NOT EXISTS idx_registration_paid
--   ON registration (event_id)
--   WHERE payment_status = 'Paid';

-- Example D) Example of UUID use:
-- ALTER TABLE participant
--   ADD COLUMN participant_uuid uuid DEFAULT uuid_generate_v4() UNIQUE;

-- ============================================================
-- 6) HOUSEKEEPING
-- ============================================================

-- Refresh planner statistics after enabling extensions
-- so query plans reflect accurate cost estimates.
ANALYZE;

-- End of file
