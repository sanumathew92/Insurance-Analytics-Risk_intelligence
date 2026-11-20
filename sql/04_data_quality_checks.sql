
-- =====================================================
-- Project: Insurance Analytics & Risk Intelligence
-- Script: 04_data_quality_checks.sql
-- Database: insurance_analytics
-- =====================================================

USE insurance_analytics;


-- =====================================================
-- CHECK 1: RECORD COUNTS
-- =====================================================

SELECT 'customers' AS table_name, COUNT(*) AS total_records
FROM customers

UNION ALL

SELECT 'insurance_products', COUNT(*)
FROM insurance_products

UNION ALL

SELECT 'policies', COUNT(*)
FROM policies

UNION ALL

SELECT 'premium_payments', COUNT(*)
FROM premium_payments

UNION ALL

SELECT 'claims', COUNT(*)
FROM claims

UNION ALL

SELECT 'agents', COUNT(*)
FROM agents;


-- =====================================================
-- CHECK 2: DUPLICATE PRIMARY KEY VALUES
-- Primary keys should make these queries return no rows.
-- =====================================================

SELECT customer_id, COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT product_id, COUNT(*) AS duplicate_count
FROM insurance_products
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT policy_id, COUNT(*) AS duplicate_count
FROM policies
GROUP BY policy_id
HAVING COUNT(*) > 1;

SELECT payment_id, COUNT(*) AS duplicate_count
FROM premium_payments
GROUP BY payment_id
HAVING COUNT(*) > 1;

SELECT claim_id, COUNT(*) AS duplicate_count
FROM claims
GROUP BY claim_id
HAVING COUNT(*) > 1;


-- =====================================================
-- CHECK 3: MISSING IMPORTANT VALUES
-- =====================================================

SELECT
    COUNT(*) AS total_customers,
    SUM(customer_name IS NULL) AS missing_customer_names,
    SUM(city IS NULL) AS missing_cities,
    SUM(age IS NULL) AS missing_ages
FROM customers;

SELECT
    COUNT(*) AS total_policies,
    SUM(customer_id IS NULL) AS missing_customer_ids,
    SUM(product_id IS NULL) AS missing_product_ids,
    SUM(policy_start_date IS NULL) AS missing_start_dates,
    SUM(policy_status IS NULL) AS missing_policy_status
FROM policies;

SELECT
    COUNT(*) AS total_payments,
    SUM(policy_id IS NULL) AS missing_policy_ids,
    SUM(payment_date IS NULL) AS missing_payment_dates,
    SUM(payment_status IS NULL) AS missing_payment_status
FROM premium_payments;

SELECT
    COUNT(*) AS total_claims,
    SUM(policy_id IS NULL) AS missing_policy_ids,
    SUM(claim_date IS NULL) AS missing_claim_dates,
    SUM(claim_status IS NULL) AS missing_claim_status
FROM claims;


-- =====================================================
-- CHECK 4: FOREIGN KEY VALIDATION
-- Each query should return zero rows.
-- =====================================================

SELECT p.policy_id, p.customer_id
FROM policies p
LEFT JOIN customers c
    ON p.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

SELECT p.policy_id, p.product_id
FROM policies p
LEFT JOIN insurance_products ip
    ON p.product_id = ip.product_id
WHERE ip.product_id IS NULL;

SELECT pp.payment_id, pp.policy_id
FROM premium_payments pp
LEFT JOIN policies p
    ON pp.policy_id = p.policy_id
WHERE p.policy_id IS NULL;

SELECT cl.claim_id, cl.policy_id
FROM claims cl
LEFT JOIN policies p
    ON cl.policy_id = p.policy_id
WHERE p.policy_id IS NULL;


-- =====================================================
-- CHECK 5: POLICY STATUS DISTRIBUTION
-- =====================================================

SELECT
    policy_status,
    COUNT(*) AS total_policies,
    SUM(premium_amount) AS total_policy_premium
FROM policies
GROUP BY policy_status
ORDER BY total_policies DESC;


-- =====================================================
-- CHECK 6: PAYMENT STATUS DISTRIBUTION
-- =====================================================

SELECT
    payment_status,
    COUNT(*) AS total_transactions,
    SUM(amount_paid) AS total_amount
FROM premium_payments
GROUP BY payment_status
ORDER BY total_amount DESC;


-- =====================================================
-- CHECK 7: CLAIM STATUS DISTRIBUTION
-- =====================================================

SELECT
    claim_status,
    COUNT(*) AS total_claims,
    SUM(claim_amount) AS total_claimed_amount,
    SUM(approved_amount) AS total_approved_amount
FROM claims
GROUP BY claim_status
ORDER BY total_claims DESC;


-- =====================================================
-- CHECK 8: INVALID FINANCIAL VALUES
-- These queries should return no rows.
-- =====================================================

SELECT *
FROM policies
WHERE sum_insured <= 0
   OR premium_amount < 0;

SELECT *
FROM premium_payments
WHERE amount_paid < 0;

SELECT *
FROM claims
WHERE claim_amount < 0
   OR approved_amount < 0
   OR approved_amount > claim_amount;


-- =====================================================
-- CHECK 9: DATE VALIDATION
-- These queries should return no rows.
-- =====================================================

SELECT *
FROM policies
WHERE policy_end_date IS NOT NULL
  AND policy_end_date < policy_start_date;

SELECT *
FROM premium_payments pp
JOIN policies p
    ON pp.policy_id = p.policy_id
WHERE pp.payment_date < p.policy_start_date;

SELECT *
FROM claims cl
JOIN policies p
    ON cl.policy_id = p.policy_id
WHERE cl.claim_date < p.policy_start_date;


-- =====================================================
-- CHECK 10: CLAIM STATUS / APPROVED AMOUNT CONSISTENCY
-- Pending and rejected claims should have zero approved
-- amount in this sample dataset.
-- =====================================================

SELECT *
FROM claims
WHERE
    (claim_status IN ('Pending', 'Rejected')
        AND approved_amount <> 0)
    OR
    (claim_status = 'Approved'
        AND approved_amount <= 0);


-- =====================================================
-- CHECK 11: PREMIUM RECONCILIATION
-- Compare policy premium values with payment records.
-- Multiple payment rows per policy are allowed.
-- =====================================================

WITH payment_summary AS (
    SELECT
        policy_id,
        SUM(amount_paid) AS recorded_payment_amount,
        SUM(
            CASE
                WHEN payment_status = 'Paid'
                THEN amount_paid ELSE 0
            END
        ) AS paid_amount
    FROM premium_payments
    GROUP BY policy_id
)
SELECT
    p.policy_id,
    p.premium_amount,
    COALESCE(ps.recorded_payment_amount, 0)
        AS recorded_payment_amount,
    COALESCE(ps.paid_amount, 0)
        AS successful_paid_amount,
    COALESCE(ps.recorded_payment_amount, 0)
        - p.premium_amount AS payment_difference
FROM policies p
LEFT JOIN payment_summary ps
    ON p.policy_id = ps.policy_id
WHERE COALESCE(ps.recorded_payment_amount, 0)
      <> p.premium_amount
ORDER BY p.policy_id;


-- =====================================================
-- CHECK 12: OVERALL FINANCIAL RECONCILIATION
-- =====================================================

SELECT
    COUNT(*) AS total_policies,
    SUM(premium_amount) AS total_policy_premium
FROM policies;

SELECT
    COUNT(*) AS total_payment_records,
    SUM(amount_paid) AS total_recorded_payments,

    SUM(
        CASE WHEN payment_status = 'Paid'
             THEN amount_paid ELSE 0 END
    ) AS total_paid_premium,

    SUM(
        CASE WHEN payment_status = 'Pending'
             THEN amount_paid ELSE 0 END
    ) AS total_pending_premium,

    SUM(
        CASE WHEN payment_status = 'Failed'
             THEN amount_paid ELSE 0 END
    ) AS total_failed_premium

FROM premium_payments;


-- =====================================================
-- CHECK 13: CLAIM FINANCIAL RECONCILIATION
-- =====================================================

SELECT
    COUNT(*) AS total_claims,
    SUM(claim_amount) AS total_claimed_amount,

    SUM(
        CASE WHEN claim_status = 'Approved'
             THEN approved_amount ELSE 0 END
    ) AS approved_claim_amount,

    SUM(
        CASE WHEN claim_status = 'Rejected'
             THEN claim_amount ELSE 0 END
    ) AS rejected_claim_amount,

    SUM(
        CASE WHEN claim_status = 'Pending'
             THEN claim_amount ELSE 0 END
    ) AS pending_claim_amount

FROM claims;


-- =====================================================
-- CHECK 14: CUSTOMER-LEVEL POLICY COUNTS
-- =====================================================

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(p.policy_id) AS total_policies
FROM customers c
LEFT JOIN policies p
    ON c.customer_id = p.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY total_policies DESC, c.customer_id;


-- =====================================================
-- CHECK 15: FINAL EXPECTED BASELINE
-- Compare these results with the expected figures.
-- =====================================================

SELECT
    (SELECT COUNT(*) FROM customers)
        AS total_customers,

    (SELECT COUNT(*) FROM insurance_products)
        AS total_products,

    (SELECT COUNT(*) FROM policies)
        AS total_policies,

    (SELECT COUNT(*) FROM premium_payments)
        AS total_payment_records,

    (SELECT COUNT(*) FROM claims)
        AS total_claims,

    (SELECT SUM(premium_amount) FROM policies)
        AS total_policy_premium,

    (SELECT SUM(amount_paid)
     FROM premium_payments
     WHERE payment_status = 'Paid')
        AS collected_premium,

    (SELECT SUM(amount_paid)
     FROM premium_payments
     WHERE payment_status = 'Pending')
        AS pending_premium,

    (SELECT SUM(amount_paid)
     FROM premium_payments
     WHERE payment_status = 'Failed')
        AS failed_premium,

    (SELECT SUM(approved_amount)
     FROM claims
     WHERE claim_status = 'Approved')
        AS approved_claim_amount;
