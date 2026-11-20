
# Q1. Calculate customer-wise policy and premium details.

USE insurance_analytics;

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(p.policy_id) AS total_policies,
    COALESCE(SUM(p.premium_amount), 0) AS written_premium
FROM customers c
LEFT JOIN policies p
    ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY written_premium DESC;

# Q2. Identify customers with pending premiums 

SELECT
    c.customer_name,
    COUNT(pp.payment_id) AS pending_transactions,
    SUM(pp.amount_paid) AS pending_premium
FROM customers c
JOIN policies p
    ON c.customer_id = p.customer_id
JOIN premium_payments pp
    ON p.policy_id = pp.policy_id
WHERE pp.payment_status = 'Pending'
GROUP BY c.customer_id, c.customer_name
ORDER BY pending_premium DESC;

# Q3. Identify customers with failed premium payment_status

SELECT
    c.customer_name,
    COUNT(pp.payment_id) AS failed_transactions,
    SUM(pp.amount_paid) AS failed_premium
FROM customers c
JOIN policies p
    ON c.customer_id = p.customer_id
JOIN premium_payments pp
    ON p.policy_id = pp.policy_id
WHERE pp.payment_status = 'Failed'
GROUP BY c.customer_id, c.customer_name
ORDER BY failed_premium DESC;

# Q4. Calculate claim frequency and total claimed amount per customer

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(cl.claim_id) AS total_claims,
    COALESCE(SUM(cl.claim_amount), 0) AS total_claimed_amount,
    COALESCE(SUM(cl.approved_amount), 0) AS recorded_approved_amount
FROM customers c
LEFT JOIN policies p
    ON c.customer_id = p.customer_id
LEFT JOIN claims cl
    ON p.policy_id = cl.policy_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_claims DESC, total_claimed_amount DESC;

# Q5. Calculate customer risk scores.

WITH claim_summary AS (
    SELECT
        p.customer_id,
        COUNT(cl.claim_id) AS total_claims,
        COALESCE(SUM(cl.claim_amount), 0) AS total_claimed_amount,
        SUM(
            CASE WHEN cl.claim_status = 'Pending'
                 THEN 1 ELSE 0 END
        ) AS pending_claims
    FROM policies p
    LEFT JOIN claims cl
        ON p.policy_id = cl.policy_id
    GROUP BY p.customer_id
),
payment_summary AS (
    SELECT
        p.customer_id,
        SUM(
            CASE WHEN pp.payment_status = 'Pending'
                 THEN pp.amount_paid ELSE 0 END
        ) AS pending_premium,
        SUM(
            CASE WHEN pp.payment_status = 'Failed'
                 THEN pp.amount_paid ELSE 0 END
        ) AS failed_premium
    FROM policies p
    LEFT JOIN premium_payments pp
        ON p.policy_id = pp.policy_id
    GROUP BY p.customer_id
),
customer_metrics AS (
    SELECT
        c.customer_id,
        c.customer_name,
        COALESCE(cs.total_claims, 0) AS total_claims,
        COALESCE(cs.total_claimed_amount, 0)
            AS total_claimed_amount,
        COALESCE(cs.pending_claims, 0) AS pending_claims,
        COALESCE(ps.pending_premium, 0) AS pending_premium,
        COALESCE(ps.failed_premium, 0) AS failed_premium
    FROM customers c
    LEFT JOIN claim_summary cs
        ON c.customer_id = cs.customer_id
    LEFT JOIN payment_summary ps
        ON c.customer_id = ps.customer_id
),
risk_scores AS (
    SELECT
        *,
        (CASE WHEN total_claims > 1 THEN 2 ELSE 0 END)
        +
        (CASE WHEN total_claimed_amount > 150000
              THEN 2 ELSE 0 END)
        +
        (CASE WHEN pending_premium > 0 THEN 1 ELSE 0 END)
        +
        (CASE WHEN failed_premium > 0 THEN 2 ELSE 0 END)
        +
        (CASE WHEN pending_claims > 0 THEN 1 ELSE 0 END)
        AS risk_score
    FROM customer_metrics
)
SELECT
    customer_id,
    customer_name,
    total_claims,
    total_claimed_amount,
    pending_premium,
    failed_premium,
    pending_claims,
    risk_score,
    CASE
        WHEN risk_score >= 4 THEN 'High Risk'
        WHEN risk_score >= 2 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_category
FROM risk_scores
ORDER BY risk_score DESC, total_claimed_amount DESC;

# Q6. Summarise customers by risk category 

SELECT
    CASE
        WHEN risk_score >= 4 THEN 'High Risk'
        WHEN risk_score >= 2 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_category,
    COUNT(*) AS total_customers,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM customers),
        2
    ) AS customer_percentage
FROM risk_scores
GROUP BY risk_category
ORDER BY
    CASE risk_category
        WHEN 'High Risk' THEN 1
        WHEN 'Medium Risk' THEN 2
        ELSE 3
    END;

# Q7. Rank customers by total claimed amount

WITH customer_claims AS (
    SELECT
        c.customer_id,
        c.customer_name,
        COALESCE(SUM(cl.claim_amount), 0) AS total_claimed
    FROM customers c
    LEFT JOIN policies p
        ON c.customer_id = p.customer_id
    LEFT JOIN claims cl
        ON p.policy_id = cl.policy_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    customer_id,
    customer_name,
    total_claimed,
    DENSE_RANK() OVER (
        ORDER BY total_claimed DESC
    ) AS claim_amount_rank
FROM customer_claims
ORDER BY claim_amount_rank;

# Q8. Identify customers with both pending premiums and claims 

WITH pending_premiums AS (
    SELECT
        p.customer_id,
        SUM(pp.amount_paid) AS pending_premium
    FROM policies p
    JOIN premium_payments pp
        ON p.policy_id = pp.policy_id
    WHERE pp.payment_status = 'Pending'
    GROUP BY p.customer_id
),
pending_claims AS (
    SELECT
        p.customer_id,
        COUNT(cl.claim_id) AS pending_claim_count
    FROM policies p
    JOIN claims cl
        ON p.policy_id = cl.policy_id
    WHERE cl.claim_status = 'Pending'
    GROUP BY p.customer_id
)
SELECT
    c.customer_name,
    pp.pending_premium,
    pc.pending_claim_count
FROM customers c
JOIN pending_premiums pp
    ON c.customer_id = pp.customer_id
JOIN pending_claims pc
    ON c.customer_id = pc.customer_id;


# Q9. Find customers with high claim amounts but no failed amounts.

WITH customer_claims AS (
    SELECT
        p.customer_id,
        SUM(cl.claim_amount) AS total_claimed
    FROM policies p
    JOIN claims cl
        ON p.policy_id = cl.policy_id
    GROUP BY p.customer_id
),
customer_payments AS (
    SELECT
        p.customer_id,
        SUM(
            CASE WHEN pp.payment_status = 'Failed'
                 THEN 1 ELSE 0 END
        ) AS failed_count
    FROM policies p
    JOIN premium_payments pp
        ON p.policy_id = pp.policy_id
    GROUP BY p.customer_id
)
SELECT
    c.customer_name,
    cc.total_claimed,
    cp.failed_count
FROM customers c
JOIN customer_claims cc
    ON c.customer_id = cc.customer_id
JOIN customer_payments cp
    ON c.customer_id = cp.customer_id
WHERE cc.total_claimed > 150000
  AND cp.failed_count = 0
ORDER BY cc.total_claimed DESC;

# Q10. Create a customer risk Intelligence report.

WITH claim_summary AS (
    SELECT
        p.customer_id,
        COUNT(cl.claim_id) AS total_claims,
        COALESCE(SUM(cl.claim_amount), 0) AS total_claimed
    FROM policies p
    LEFT JOIN claims cl
        ON p.policy_id = cl.policy_id
    GROUP BY p.customer_id
),
payment_summary AS (
    SELECT
        p.customer_id,
        SUM(
            CASE WHEN pp.payment_status = 'Paid'
                 THEN pp.amount_paid ELSE 0 END
        ) AS collected_premium,
        SUM(
            CASE WHEN pp.payment_status = 'Pending'
                 THEN pp.amount_paid ELSE 0 END
        ) AS pending_premium,
        SUM(
            CASE WHEN pp.payment_status = 'Failed'
                 THEN pp.amount_paid ELSE 0 END
        ) AS failed_premium
    FROM policies p
    LEFT JOIN premium_payments pp
        ON p.policy_id = pp.policy_id
    GROUP BY p.customer_id
)
SELECT
    c.customer_id,
    c.customer_name,
    COALESCE(cs.total_claims, 0) AS total_claims,
    COALESCE(cs.total_claimed, 0) AS total_claimed,
    COALESCE(ps.collected_premium, 0) AS collected_premium,
    COALESCE(ps.pending_premium, 0) AS pending_premium,
    COALESCE(ps.failed_premium, 0) AS failed_premium
FROM customers c
LEFT JOIN claim_summary cs
    ON c.customer_id = cs.customer_id
LEFT JOIN payment_summary ps
    ON c.customer_id = ps.customer_id
ORDER BY total_claimed DESC;

