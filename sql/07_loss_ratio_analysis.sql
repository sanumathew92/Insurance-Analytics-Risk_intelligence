
# Q1. Calculate approved claims versus collected_premium by insurance_type 

USE insurance_analytics;

WITH premium_summary AS (
    SELECT
        ip.insurance_type,
        SUM(
            CASE WHEN pp.payment_status = 'Paid'
                 THEN pp.amount_paid ELSE 0 END
        ) AS collected_premium
    FROM insurance_products ip
    JOIN policies p
        ON ip.product_id = p.product_id
    LEFT JOIN premium_payments pp
        ON p.policy_id = pp.policy_id
    GROUP BY ip.insurance_type
),
claim_summary AS (
    SELECT
        ip.insurance_type,
        SUM(
            CASE WHEN cl.claim_status = 'Approved'
                 THEN cl.approved_amount ELSE 0 END
        ) AS approved_claims
    FROM insurance_products ip
    JOIN policies p
        ON ip.product_id = p.product_id
    LEFT JOIN claims cl
        ON p.policy_id = cl.policy_id
    GROUP BY ip.insurance_type
)
SELECT
    ps.insurance_type,
    ps.collected_premium,
    cs.approved_claims,
    ROUND(
        cs.approved_claims * 100.0 /
        NULLIF(ps.collected_premium, 0),
        2
    ) AS indicative_claims_ratio
FROM premium_summary ps
JOIN claim_summary cs
    ON ps.insurance_type = cs.insurance_type
ORDER BY indicative_claims_ratio DESC;

# Q2. Calculate overall indicative claims ratio.

WITH premium AS (
    SELECT SUM(amount_paid) AS collected_premium
    FROM premium_payments
    WHERE payment_status = 'Paid'
),
claims_total AS (
    SELECT SUM(approved_amount) AS approved_claims
    FROM claims
    WHERE claim_status = 'Approved'
)
SELECT
    premium.collected_premium,
    claims_total.approved_claims,
    ROUND(
        claims_total.approved_claims * 100.0 /
        NULLIF(premium.collected_premium, 0),
        2
    ) AS indicative_claims_ratio
FROM premium
CROSS JOIN claims_total;

# Q3. Rank insurance categories by indicative claims ratio

WITH premium_summary AS (
    SELECT
        ip.insurance_type,
        SUM(
            CASE WHEN pp.payment_status = 'Paid'
                 THEN pp.amount_paid ELSE 0 END
        ) AS collected_premium
    FROM insurance_products ip
    JOIN policies p
        ON ip.product_id = p.product_id
    LEFT JOIN premium_payments pp
        ON p.policy_id = pp.policy_id
    GROUP BY ip.insurance_type
),
claim_summary AS (
    SELECT
        ip.insurance_type,
        SUM(
            CASE WHEN cl.claim_status = 'Approved'
                 THEN cl.approved_amount ELSE 0 END
        ) AS approved_claims
    FROM insurance_products ip
    JOIN policies p
        ON ip.product_id = p.product_id
    LEFT JOIN claims cl
        ON p.policy_id = cl.policy_id
    GROUP BY ip.insurance_type
),
ratio_data AS (
    SELECT
        ps.insurance_type,
        ps.collected_premium,
        cs.approved_claims,
        cs.approved_claims * 100.0 /
            NULLIF(ps.collected_premium, 0) AS claims_ratio
    FROM premium_summary ps
    JOIN claim_summary cs
        ON ps.insurance_type = cs.insurance_type
)
SELECT
    insurance_type,
    collected_premium,
    approved_claims,
    ROUND(claims_ratio, 2) AS claims_ratio,
    DENSE_RANK() OVER (
        ORDER BY claims_ratio DESC
    ) AS ratio_rank
FROM ratio_data
ORDER BY ratio_rank;

# Q4. Calculate approved claim amount per policy 

SELECT
    ip.insurance_type,
    ip.product_name,
    COUNT(DISTINCT p.policy_id) AS total_policies,
    COALESCE(SUM(
        CASE WHEN cl.claim_status = 'Approved'
             THEN cl.approved_amount ELSE 0 END
    ), 0) AS approved_claims,
    ROUND(
        COALESCE(SUM(
            CASE WHEN cl.claim_status = 'Approved'
                 THEN cl.approved_amount ELSE 0 END
        ), 0) / COUNT(DISTINCT p.policy_id),
        2
    ) AS approved_claim_amount_per_policy
FROM insurance_products ip
JOIN policies p
    ON ip.product_id = p.product_id
LEFT JOIN claims cl
    ON p.policy_id = cl.policy_id
GROUP BY
    ip.insurance_type,
    ip.product_id,
    ip.product_name
ORDER BY approved_claim_amount_per_policy DESC;

# Q4. Calculate approved claim amount per policy 

SELECT
    ip.insurance_type,
    ip.product_name,
    COUNT(DISTINCT p.policy_id) AS total_policies,
    COALESCE(SUM(
        CASE WHEN cl.claim_status = 'Approved'
             THEN cl.approved_amount ELSE 0 END
    ), 0) AS approved_claims,
    ROUND(
        COALESCE(SUM(
            CASE WHEN cl.claim_status = 'Approved'
                 THEN cl.approved_amount ELSE 0 END
        ), 0) / COUNT(DISTINCT p.policy_id),
        2
    ) AS approved_claim_amount_per_policy
FROM insurance_products ip
JOIN policies p
    ON ip.product_id = p.product_id
LEFT JOIN claims cl
    ON p.policy_id = cl.policy_id
GROUP BY
    ip.insurance_type,
    ip.product_id,
    ip.product_name
ORDER BY approved_claim_amount_per_policy DESC;

# Q5. Identify products with a high indicative claims ratio 

WITH premium_summary AS (
    SELECT
        ip.product_id,
        ip.product_name,
        SUM(
            CASE WHEN pp.payment_status = 'Paid'
                 THEN pp.amount_paid ELSE 0 END
        ) AS collected_premium
    FROM insurance_products ip
    JOIN policies p
        ON ip.product_id = p.product_id
    LEFT JOIN premium_payments pp
        ON p.policy_id = pp.policy_id
    GROUP BY ip.product_id, ip.product_name
),
claim_summary AS (
    SELECT
        ip.product_id,
        SUM(
            CASE WHEN cl.claim_status = 'Approved'
                 THEN cl.approved_amount ELSE 0 END
        ) AS approved_claims
    FROM insurance_products ip
    JOIN policies p
        ON ip.product_id = p.product_id
    LEFT JOIN claims cl
        ON p.policy_id = cl.policy_id
    GROUP BY ip.product_id
)
SELECT
    ps.product_name,
    ps.collected_premium,
    cs.approved_claims,
    ROUND(
        cs.approved_claims * 100.0 /
        NULLIF(ps.collected_premium, 0),
        2
    ) AS indicative_claims_ratio
FROM premium_summary ps
JOIN claim_summary cs
    ON ps.product_id = cs.product_id
WHERE cs.approved_claims * 100.0 /
      NULLIF(ps.collected_premium, 0) > 100
ORDER BY indicative_claims_ratio DESC;

