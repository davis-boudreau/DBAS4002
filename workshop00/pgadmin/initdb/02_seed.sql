INSERT INTO banking.accounts(owner, balance) VALUES
  ('Alice', 1000.00),
  ('Bob',    500.00),
  ('Carol',  250.00)
ON CONFLICT DO NOTHING;