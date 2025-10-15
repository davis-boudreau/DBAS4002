-- Integrity & business rules (Week 4)
ALTER TABLE Event
  ADD CONSTRAINT chk_event_dates CHECK (end_date > start_date);

ALTER TABLE Event
  ADD CONSTRAINT chk_priority_range CHECK (priority BETWEEN 1 AND 5);

-- Example: prevent empty organizer strings (treat '' as NULL)
ALTER TABLE Event
  ADD CONSTRAINT chk_organizer_nonempty CHECK (organizer IS NULL OR organizer <> '');
