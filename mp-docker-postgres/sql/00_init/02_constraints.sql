ALTER TABLE Event
  ADD CONSTRAINT chk_event_dates CHECK (end_date > start_date),
  ADD CONSTRAINT chk_priority_range CHECK (priority BETWEEN 1 AND 5);

ALTER TABLE Registration
  ADD CONSTRAINT chk_payment_status CHECK (payment_status IN ('Pending', 'Paid', 'Cancelled'));