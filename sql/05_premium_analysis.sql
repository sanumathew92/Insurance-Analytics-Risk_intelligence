
# Q1. Calculate total policy premium 

USE insurance_analytics;

SELECT
    COUNT(*) AS total_policies,
    SUM(premium_amount) AS total_written_premium,
    ROUND(AVG(premium_amount), 2) AS average_policy_premium
FROM policies;

# Q2. Analyse premium collection by payment status

SELECT
    payment_status,
    COUNT(*) AS total_transactions,
    SUM(amount_paid) AS total_amount,
    ROUND(
        SUM(amount_paid) * 100.0 /
        (SELECT SUM(amount_paid) FROM premium_payments),
        2
    ) AS amount_percentage
FROM premium_payments
GROUP BY payment_status
ORDER BY total_amount DESC;

# Q3. Calculate premium collection rate

SELECT
    SUM(p.premium_amount) AS written_premium,
    SUM(
        CASE WHEN pp.payment_status = 'Paid'
             THEN pp.amount_paid ELSE 0 END
    ) AS collected_premium,
    ROUND(
        SUM(
            CASE WHEN pp.payment_status = 'Paid'
                 THEN pp.amount_paid ELSE 0 END
        ) * 100.0 / SUM(p.premium_amount),
        2
    ) AS collection_rate
FROM policies p
LEFT JOIN premium_payments pp
    ON p.policy_id = pp.policy_id;

# Q4. Calculate customer-wise premium contribution

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(p.policy_id) AS total_policies,
    SUM(p.premium_amount) AS written_premium
FROM customers c
JOIN policies p
    ON c.customer_id = p.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY written_premium DESC;

# Q5. Rank customers by written premium 

WITH customer_premium AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(p.premium_amount) AS total_premium
    FROM customers c
    JOIN policies p
        ON c.customer_id = p.customer_id
    GROUP BY
        c.customer_id,
        c.customer_name
)
SELECT
    customer_id,
    customer_name,
    total_premium,
    DENSE_RANK() OVER (
        ORDER BY total_premium DESC
    ) AS premium_rank
FROM customer_premium
ORDER BY premium_rank;

# Q6. Analyse premium by insurance category

SELECT
    ip.insurance_type,
    COUNT(p.policy_id) AS total_policies,
    SUM(p.premium_amount) AS written_premium,
    ROUND(AVG(p.premium_amount), 2) AS average_premium
FROM insurance_products ip
JOIN policies p
    ON ip.product_id = p.product_id
GROUP BY ip.insurance_type
ORDER BY written_premium DESC;

# Q7. Calculate premium collections by category

SELECT
    ip.insurance_type,
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
FROM insurance_products ip
JOIN policies p
    ON ip.product_id = p.product_id
LEFT JOIN premium_payments pp
    ON p.policy_id = pp.policy_id
GROUP BY ip.insurance_type
ORDER BY collected_premium DESC;

# Q8. Calculate month-wise premium collection 

SELECT
    DATE_FORMAT(payment_date, '%Y-%m') AS payment_month,
    SUM(
        CASE WHEN payment_status = 'Paid'
             THEN amount_paid ELSE 0 END
    ) AS collected_premium
FROM premium_payments
GROUP BY DATE_FORMAT(payment_date, '%Y-%m')
ORDER BY payment_month;

# Q9. Identify customers with pending premium

SELECT
    c.customer_id,
    c.customer_name,
    SUM(pp.amount_paid) AS pending_amount,
    COUNT(pp.payment_id) AS pending_transactions
FROM customers c
JOIN policies p
    ON c.customer_id = p.customer_id
JOIN premium_payments pp
    ON p.policy_id = pp.policy_id
WHERE pp.payment_status = 'Pending'
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY pending_amount DESC;


# Q10. Identify failed premium payment 

SELECT
    c.customer_name,
    p.policy_id,
    pp.payment_id,
    pp.payment_date,
    pp.amount_paid,
    pp.payment_status
FROM customers c
JOIN policies p
    ON c.customer_id = p.customer_id
JOIN premium_payments pp
    ON p.policy_id = pp.policy_id
WHERE pp.payment_status = 'Failed';

