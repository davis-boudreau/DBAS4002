/* ============================================================
   File: 02_constraints.sql
   Purpose: Integrity rules, foreign keys, checks, and indexes
   Depends on: 01_schema.sql
   ============================================================ */

SET search_path TO public;

-- ========== FOREIGN KEYS =====================================

-- event → category
ALTER TABLE event
  ADD CONSTRAINT fk_event_category
  FOREIGN KEY (category_id)
  REFERENCES category(category_id)
  ON DELETE CASCADE;

-- registration → event
ALTER TABLE registration
  ADD CONSTRAINT fk_registration_event
  FOREIGN KEY (event_id)
  REFERENCES event(event_id)
  ON DELETE CASCADE;

-- registration → participant
ALTER TABLE registration
  ADD CONSTRAINT fk_registration_participant
  FOREIGN KEY (participant_id)
  REFERENCES participant(participant_id)
  ON DELETE CASCADE;

-- ========== UNIQUENESS / BUSINESS RULES ======================

-- One registration per (event, participant)
ALTER TABLE registration
  ADD CONSTRAINT uq_registration_event_participant
  UNIQUE (event_id, participant_id);

-- Participant email must be unique
ALTER TABLE participant
  ADD CONSTRAINT uq_participant_email UNIQUE (email);

-- ========== CHECK CONSTRAINTS ================================

-- Event must end after it starts; priority within a small bounded range
ALTER TABLE event
  ADD CONSTRAINT chk_event_dates
    CHECK (end_date > start_date),
  ADD CONSTRAINT chk_event_priority
    CHECK (priority BETWEEN 1 AND 5);

-- Payment status limited to known values
ALTER TABLE registration
  ADD CONSTRAINT chk_registration_payment_status
    CHECK (payment_status IN ('Pending', 'Paid', 'Cancelled'));

-- ========== PERFORMANCE INDEXES ==============================

-- Common join/filter paths
CREATE INDEX IF NOT EXISTS idx_registration_event_id
  ON registration (event_id);

CREATE INDEX IF NOT EXISTS idx_registration_participant_id
  ON registration (participant_id);

-- Useful for date-range queries, dashboards, and reporting
CREATE INDEX IF NOT EXISTS idx_event_dates
  ON event (start_date, end_date);

-- Covering style index that supports common filters/analytics
-- (helps when frequently filtering by event + participant + status)
CREATE INDEX IF NOT EXISTS idx_reg_event_participant_status
  ON registration (event_id, participant_id, payment_status);

-- ========== ANALYZE (optional but helpful for plans) =========
-- Refresh planner statistics after initial load
-- (You can also run this after 03_seed.sql finishes)
ANALYZE;
