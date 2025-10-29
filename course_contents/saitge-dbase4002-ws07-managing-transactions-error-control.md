![alt text](image.png)

---

## **1. Assignment Details**

* **Course Code:** DBAS 4002
* **Course Name:** Transactional Database Programming
* **Workshop Title:** Workshop 07 – Managing Transactions & Error Control
* **Assignment Type:** Guided Workshop / Hands-On Lab
* **Duration:** 1 - 2 hours
* **Version:** 1.0 (Fall 2025)
* **Instructor:** Davis Boudreau

---

## **2. Overview / Purpose / Objectives**

**Purpose:**
This workshop teaches you how to safeguard data integrity by managing **ACID transactions**, handling **runtime errors**, and designing **safe rollback logic** in your Dockerized PostgreSQL environment.
You will implement multi-statement operations that behave as one atomic transaction and analyze how errors trigger rollbacks.

**Objectives:**

1. Explain and demonstrate ACID principles in a transactional context.
2. Implement explicit transactions (`BEGIN … COMMIT … ROLLBACK`).
3. Use `SAVEPOINT` and `EXCEPTION` to isolate and recover from partial failures.
4. Test rollback behaviour with intentional errors in seeded data.
5. Reflect on the importance of atomicity and error control in production systems.

---

## **3. Learning Outcomes Addressed**

* **O1:** Code SQL logic that maintains consistency under transactional control.
* **O2:** Implement procedural SQL with error handling and safe rollback mechanisms.
* **O3:** Use Docker to reproduce transactional tests in a controlled environment.

---

## **4. Assignment Description / Use Case**

Continuing with the **Event Management System** from the Docker mini-project, you will now:

* Perform a multi-step transaction that registers participants for events.
* Add a payment record only if the registration succeeds.
* Handle failures (e.g., duplicate registration or invalid event ID) gracefully using rollbacks.

---

## **5. Tasks / Instructions**

### 🧭 Step 1 – Start Your Docker Environment

```bash
make up
make psql
```

Verify your schema and seed data are present:

```sql
\dt
SELECT * FROM Event;
SELECT * FROM Participant;
```

---

### ⚙️ Step 2 – Create a Transactional Procedure

In `sql/50_transactions/workshop7_registration_txn.sql`, create a procedure that registers a participant for an event.

```sql
CREATE OR REPLACE PROCEDURE register_participant_txn(
    p_event_id INT,
    p_participant_id INT,
    p_payment_status VARCHAR DEFAULT 'Pending'
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Start explicit transaction
    BEGIN
        -- Validate event exists
        IF NOT EXISTS (SELECT 1 FROM Event WHERE event_id = p_event_id) THEN
            RAISE EXCEPTION 'Event ID % does not exist', p_event_id;
        END IF;

        -- Validate participant exists
        IF NOT EXISTS (SELECT 1 FROM Participant WHERE participant_id = p_participant_id) THEN
            RAISE EXCEPTION 'Participant ID % does not exist', p_participant_id;
        END IF;

        -- Attempt registration
        INSERT INTO Registration (event_id, participant_id, payment_status)
        VALUES (p_event_id, p_participant_id, p_payment_status);

        RAISE NOTICE 'Participant % successfully registered for event %',
                     p_participant_id, p_event_id;

        COMMIT;
    EXCEPTION
        WHEN unique_violation THEN
            ROLLBACK;
            RAISE NOTICE 'Registration already exists for participant % on event %', p_participant_id, p_event_id;
        WHEN others THEN
            ROLLBACK;
            RAISE NOTICE 'Transaction failed: %', SQLERRM;
    END;
END;
$$;
```

Run:

```sql
CALL register_participant_txn(2, 1, 'Paid');
```

and then query:

```sql
SELECT * FROM Registration WHERE event_id = 2;
```

---

### 🧩 Step 3 – Simulate a Failure

Try a duplicate insert:

```sql
CALL register_participant_txn(2, 1, 'Paid');
```

Expected output:
`NOTICE: Registration already exists…`
Confirm that no duplicate row appears.

---

### 💾 Step 4 – Nested Transactions with SAVEPOINTS

Enhance the procedure to include a SAVEPOINT for partial recovery:

```sql
BEGIN
    SAVEPOINT before_payment;

    INSERT INTO Registration (event_id, participant_id, payment_status)
    VALUES (p_event_id, p_participant_id, 'Pending');

    -- Simulate failure in payment
    IF p_payment_status NOT IN ('Pending','Paid','Cancelled') THEN
        RAISE EXCEPTION 'Invalid payment status: %', p_payment_status;
    END IF;

    UPDATE Registration SET payment_status = p_payment_status
    WHERE event_id = p_event_id AND participant_id = p_participant_id;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO before_payment;
        RAISE NOTICE 'Payment failed, registration retained as Pending.';
        COMMIT;
END;
```

Test:

```sql
CALL register_participant_txn(3, 2, 'InvalidStatus');
```

Then:

```sql
SELECT * FROM Registration WHERE event_id = 3;
```

Result: Registration exists with `Pending` status — the savepoint worked.

---

### 🧮 Step 5 – Error Analysis

Query the transaction log:

```sql
SELECT NOW() AS check_time, COUNT(*) FROM Registration;
```

Observe that successful transactions increased row count; failed ones did not.

---

### 🧠 Step 6 – Reflection Activity

Discuss in pairs or reflect in your journal:

> Why is it dangerous to mix application-level logic with uncontrolled multi-table SQL statements?
> How do transactions and error handling improve data trust and consistency?

---

## **6. Deliverables**

Submit a zip named:

```
studentid_dbas4002_workshop7_transactions.zip
```

Including:

* `sql/50_transactions/workshop7_registration_txn.sql`
* `workshop7_reflection.docx`

---

## **7. Reflection Questions**

1. Describe each ACID property and how PostgreSQL ensures it.
2. Why might a SAVEPOINT be preferable to a full ROLLBACK?
3. What risks exist if error handling is omitted from procedures?
4. How does Dockerization improve the consistency of transaction testing across machines?
5. Provide a real-world example where rollback prevents data corruption.

---

## **8. Assessment & Rubric (10 pts)**

| **Criteria**                | **Excellent (3)**                          | **Satisfactory (2)**   | **Needs Improvement (1)** | **Pts** |
| --------------------------- | ------------------------------------------ | ---------------------- | ------------------------- | ------- |
| Transactional Integrity     | Fully atomic, tested for success & failure | Works with minor flaws | Incomplete or non-atomic  | __/3    |
| Error Handling & Savepoints | Robust EXCEPTION logic + SAVEPOINT use     | Basic error handling   | No rollback logic         | __/3    |
| Code Clarity & Comments     | Clear structure + comments                 | Some comments          | None                      | __/2    |
| Reflection Depth            | Analytical and practical                   | General                | Missing                   | __/2    |
| **Total**                   |                                            |                        |                           | **/10** |

---

## **9. Submission Guidelines**

* Test your procedure in Docker before submission (`make run-tests`).
* Add header comments for each procedure with your name and purpose.
* Submit via Brightspace or GitHub repository.

---

## **10. Resources / Equipment**

* Dockerized PostgreSQL stack (from MP-Docker).
* `make` commands for build & testing.
* Reference: [PostgreSQL Transactions Documentation](https://www.postgresql.org/docs/current/tutorial-transactions.html)

---

## **11. Academic Policies**

Follow NSCC academic integrity guidelines. All SQL must be authored by you; cite any adapted examples in comments.

---

## **12. Copyright Notice**

© 2025 Nova Scotia Community College – Transactional Database Programming (DBAS 4002). For educational use only.

