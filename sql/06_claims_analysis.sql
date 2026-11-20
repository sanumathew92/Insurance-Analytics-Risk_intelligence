
# Q1. Calculate total claims and claim amounts.

USE insurance_analytics;

SELECT
    COUNT(*) AS total_claims,
    SUM(claim_amount) AS total_claimed_amount,
    SUM(approved_amount) AS total_recorded_approved_amount,
    ROUND(AVG(claim_amount), 2) AS average_claim_amount
FROM claims;

# Q2. Analyze claims by status 

SELECT
    claim_status,
    COUNT(*) AS total_claims,
    SUM(claim_amount) AS claimed_amount,
    SUM(approved_amount) AS approved_amount
FROM claims
GROUP BY claim_status
ORDER BY total_claims DESC;

# Q3. Calculate claim approval rate 

SELECT
    COUNT(*) AS total_claims,

    SUM(
        CASE WHEN claim_status = 'Approved'
             THEN 1 ELSE 0 END
    ) AS approved_claims,

    ROUND(
        SUM(
            CASE WHEN claim_status = 'Approved'
                 THEN 1 ELSE 0 END
        ) * 100.0 / COUNT(*),
        2
    ) AS approval_rate
FROM claims;

# Q4. Calculate average claim severity by insurance_type 

SELECT
    ip.insurance_type,
    COUNT(cl.claim_id) AS total_claims,
    ROUND(AVG(cl.claim_amount), 2) AS average_claim_amount,
    SUM(cl.claim_amount) AS total_claimed_amount
FROM claims cl
JOIN policies p
    ON cl.policy_id = p.policy_id
JOIN insurance_products ip
    ON p.product_id = ip.product_id
GROUP BY ip.insurance_type
ORDER BY average_claim_amount DESC;

# Q5. Calculate approved claims by insurance category 

SELECT
    ip.insurance_type,
    COUNT(cl.claim_id) AS total_claims,
    SUM(
        CASE WHEN cl.claim_status = 'Approved'
             THEN cl.approved_amount ELSE 0 END
    ) AS approved_claim_amount
FROM claims cl
JOIN policies p
    ON cl.policy_id = p.policy_id
JOIN insurance_products ip
    ON p.product_id = ip.product_id
GROUP BY ip.insurance_type
ORDER BY approved_claim_amount DESC;

# Q6. Identify customers with multiple claims 

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(cl.claim_id) AS total_claims,
    SUM(cl.claim_amount) AS total_claimed_amount,
    SUM(cl.approved_amount) AS total_recorded_approved_amount
FROM customers c
JOIN policies p
    ON c.customer_id = p.customer_id
JOIN claims cl
    ON p.policy_id = cl.policy_id
GROUP BY
    c.customer_id,
    c.customer_name
HAVING COUNT(cl.claim_id) > 1
ORDER BY total_claims DESC, total_claimed_amount DESC;

# Q7. Find the highest-value claim.

SELECT
    cl.claim_id,
    c.customer_name,
    ip.insurance_type,
    cl.claim_amount,
    cl.approved_amount,
    cl.claim_status
FROM claims cl
JOIN policies p
    ON cl.policy_id = p.policy_id
JOIN customers c
    ON p.customer_id = c.customer_id
JOIN insurance_products ip
    ON p.product_id = ip.product_id
ORDER BY cl.claim_amount DESC
LIMIT 1;

# Q8. Find claims exceeding twice the average claim amount 

WITH claim_average AS (
    SELECT AVG(claim_amount) AS avg_claim
    FROM claims
)
SELECT
    cl.claim_id,
    c.customer_name,
    cl.claim_amount,
    ca.avg_claim
FROM claims cl
JOIN policies p
    ON cl.policy_id = p.policy_id
JOIN customers c
    ON p.customer_id = c.customer_id
CROSS JOIN claim_average ca
WHERE cl.claim_amount > 2 * ca.avg_claim
ORDER BY cl.claim_amount DESC;

# Q9. Calculate monthly claims 

SELECT
    DATE_FORMAT(claim_date, '%Y-%m') AS claim_month,
    COUNT(*) AS total_claims,
    SUM(claim_amount) AS total_claimed_amount,
    SUM(
        CASE WHEN claim_status = 'Approved'
             THEN approved_amount ELSE 0 END
    ) AS approved_amount
FROM claims
GROUP BY DATE_FORMAT(claim_date, '%Y-%m')
ORDER BY claim_month;

# Q10. Calculate customer-wise claim frequency and severity 

SELECT
    c.customer_name,
    COUNT(cl.claim_id) AS claim_frequency,
    SUM(cl.claim_amount) AS total_claimed_amount,
    ROUND(AVG(cl.claim_amount), 2) AS average_claim_severity
FROM customers c
LEFT JOIN policies p
    ON c.customer_id = p.customer_id
LEFT JOIN claims cl
    ON p.policy_id = cl.policy_id
GROUP BY c.customer_id, c.customer_name
ORDER BY claim_frequency DESC, total_claimed_amount DESC;

