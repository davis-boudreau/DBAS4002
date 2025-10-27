-- Accounts & ledger-style transactions to explore ACID and isolation
CREATE SCHEMA IF NOT EXISTS banking;

CREATE TABLE IF NOT EXISTS banking.accounts (
  account_id SERIAL PRIMARY KEY,
  owner TEXT NOT NULL,
  balance NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (balance >= 0)
);

CREATE TABLE IF NOT EXISTS banking.txn (
  txn_id BIGSERIAL PRIMARY KEY,
  from_account INT REFERENCES banking.accounts(account_id),
  to_account   INT REFERENCES banking.accounts(account_id),
  amount NUMERIC(12,2) NOT NULL CHECK (amount > 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  note TEXT
);

-- Transfer function with explicit transaction semantics (demo only)
CREATE OR REPLACE FUNCTION banking.transfer(p_from INT, p_to INT, p_amount NUMERIC)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
  -- withdraw
  UPDATE banking.accounts
  SET balance = balance - p_amount
  WHERE account_id = p_from;

  -- deposit
  UPDATE banking.accounts
  SET balance = balance + p_amount
  WHERE account_id = p_to;

  INSERT INTO banking.txn(from_account, to_account, amount, note)
  VALUES (p_from, p_to, p_amount, 'demo transfer');
END;
$$;