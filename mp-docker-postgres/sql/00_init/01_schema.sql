/* ============================================================
   File: 01_schema.sql
   Purpose: Base schema for the Event Management System
   Notes:
     - Created for PostgreSQL 16
     - Lowercase, snake_case identifiers (no quoted names)
     - Tables: category, event, participant, registration
   ============================================================ */

-- Safety: create in public schema (default)
SET search_path TO public;

-- ========== CATEGORY =========================================
CREATE TABLE IF NOT EXISTS category (
  category_id   SERIAL PRIMARY KEY,
  name          VARCHAR(100) NOT NULL UNIQUE
);

-- ========== EVENT ============================================
CREATE TABLE IF NOT EXISTS event (
  event_id      SERIAL PRIMARY KEY,
  name          VARCHAR(150) NOT NULL,
  category_id   INT NOT NULL,
  start_date    TIMESTAMP NOT NULL,
  end_date      TIMESTAMP NOT NULL,
  priority      INT DEFAULT 1,
  description   TEXT DEFAULT '',
  location      VARCHAR(255) DEFAULT '',
  organizer     VARCHAR(100) DEFAULT ''
  -- FKs added in 02_constraints.sql
);

-- ========== PARTICIPANT ======================================
CREATE TABLE IF NOT EXISTS participant (
  participant_id  SERIAL PRIMARY KEY,
  first_name      VARCHAR(100) NOT NULL,
  last_name       VARCHAR(100) NOT NULL,
  email           VARCHAR(150) NOT NULL,
  phone           VARCHAR(30),                 -- included to match 03_seed.sql
  registered_at   TIMESTAMP DEFAULT NOW()
  -- additional constraints in 02_constraints.sql
);

-- ========== REGISTRATION =====================================
CREATE TABLE IF NOT EXISTS registration (
  registration_id SERIAL PRIMARY KEY,
  event_id        INT NOT NULL,
  participant_id  INT NOT NULL,
  registered_on   TIMESTAMP DEFAULT NOW(),
  payment_status  VARCHAR(20) DEFAULT 'Pending'
  -- FKs, uniqueness & checks in 02_constraints.sql
);

-- Optional: helpful indexes created in 02_constraints.sql.
-- Keep schema creation minimal here to separate DDL from constraints/rules.
