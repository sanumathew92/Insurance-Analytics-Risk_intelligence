
# Q1. Executive summary report. 

USE insurance_analytics;

WITH policy_metrics AS (
    SELECT
        COUNT(*) AS total_policies,
        SUM(premium_amount) AS written_premium,
        SUM(sum_insured) AS total_sum_insured,
        SUM(CASE WHEN policy_status = 'Active'
                 THEN 1 ELSE 0 END) AS active_policies,
        SUM(CASE WHEN policy_status = 'Expired'
                 THEN 1 ELSE 0 END) AS expired_policies,
        SUM(CASE WHEN policy_status = 'Cancelled'
                 THEN 1 ELSE 0 END) AS cancelled_policies
    FROM policies
),
payment_metrics AS (
    SELECT
        COUNT(*) AS total_payment_records,
        SUM(CASE WHEN payment_status = 'Paid'
                 THEN amount_paid ELSE 0 END) AS collected_premium,
        SUM(CASE WHEN payment_status = 'Pending'
                 THEN amount_paid ELSE 0 END) AS pending_premium,
        SUM(CASE WHEN payment_status = 'Failed'
                 THEN amount_paid ELSE 0 END) AS failed_premium
    FROM premium_payments
),
claim_metrics AS (
    SELECT
        COUNT(*) AS total_claims,
        SUM(CASE WHEN claim_status = 'Approved'
                 THEN 1 ELSE 0 END) AS approved_claims,
        SUM(CASE WHEN claim_status = 'Rejected'
                 THEN 1 ELSE 0 END) AS rejected_claims,
        SUM(CASE WHEN claim_status = 'Pending'
                 THEN 1 ELSE 0 END) AS pending_claims,
        SUM(CASE WHEN claim_status = 'Approved'
                 THEN approved_amount ELSE 0 END)
            AS approved_claim_amount
    FROM claims
)
SELECT
    (SELECT COUNT(*) FROM customers) AS total_customers,

    pm.total_policies,
    pm.active_policies,
    pm.expired_policies,
    pm.cancelled_policies,

    pm.written_premium,
    pm.total_sum_insured,

    pay.collected_premium,
    pay.pending_premium,
    pay.failed_premium,

    ROUND(
        pay.collected_premium * 100.0 /
        NULLIF(pm.written_premium, 0),
        2
    ) AS premium_collection_rate,

    cm.total_claims,
    cm.approved_claims,
    cm.rejected_claims,
    cm.pending_claims,
    cm.approved_claim_amount,

    ROUND(
        cm.approved_claims * 100.0 /
        NULLIF(cm.total_claims, 0),
        2
    ) AS claim_approval_rate,

    ROUND(
        cm.approved_claim_amount * 100.0 /
        NULLIF(pay.collected_premium, 0),
        2
    ) AS indicative_claims_ratio

FROM policy_metrics pm
CROSS JOIN payment_metrics pay
CROSS JOIN claim_metrics cm;


# Q2. Product-wise management performance.

WITH premium_data AS (
    SELECT
        ip.product_id,
        ip.product_name,
        ip.insurance_type,
        COUNT(DISTINCT p.policy_id) AS total_policies,
        SUM(p.premium_amount) AS written_premium,
        SUM(
            CASE WHEN pp.payment_status = 'Paid'
                 THEN pp.amount_paid ELSE 0 END
        ) AS collected_premium
    FROM insurance_products ip
    LEFT JOIN policies p
        ON ip.product_id = p.product_id
    LEFT JOIN premium_payments pp
        ON p.policy_id = pp.policy_id
    GROUP BY
        ip.product_id,
        ip.product_name,
        ip.insurance_type
),
claim_data AS (
    SELECT
        p.product_id,
        COUNT(cl.claim_id) AS total_claims,
        SUM(
            CASE WHEN cl.claim_status = 'Approved'
                 THEN cl.approved_amount ELSE 0 END
        ) AS approved_claims
    FROM policies p
    LEFT JOIN claims cl
        ON p.policy_id = cl.policy_id
    GROUP BY p.product_id
)
SELECT
    pd.product_name,
    pd.insurance_type,
    pd.total_policies,
    pd.written_premium,
    pd.collected_premium,
    COALESCE(cd.total_claims, 0) AS total_claims,
    COALESCE(cd.approved_claims, 0) AS approved_claims,

    ROUND(
        COALESCE(cd.approved_claims, 0) * 100.0 /
        NULLIF(pd.collected_premium, 0),
        2
    ) AS indicative_claims_ratio

FROM premium_data pd
LEFT JOIN claim_data cd
    ON pd.product_id = cd.product_id
ORDER BY indicative_claims_ratio DESC;

# Q3. Monthly premium collection and claims performance

WITH monthly_premium AS (
    SELECT
        DATE_FORMAT(payment_date, '%Y-%m') AS report_month,
        SUM(
            CASE WHEN payment_status = 'Paid'
                 THEN amount_paid ELSE 0 END
        ) AS collected_premium
    FROM premium_payments
    GROUP BY DATE_FORMAT(payment_date, '%Y-%m')
),
monthly_claims AS (
    SELECT
        DATE_FORMAT(claim_date, '%Y-%m') AS report_month,
        COUNT(*) AS total_claims,
        SUM(
            CASE WHEN claim_status = 'Approved'
                 THEN approved_amount ELSE 0 END
        ) AS approved_claim_amount
    FROM claims
    GROUP BY DATE_FORMAT(claim_date, '%Y-%m')
)
SELECT
    COALESCE(mp.report_month, mc.report_month) AS report_month,
    COALESCE(mp.collected_premium, 0) AS collected_premium,
    COALESCE(mc.total_claims, 0) AS total_claims,
    COALESCE(mc.approved_claim_amount, 0)
        AS approved_claim_amount
FROM monthly_premium mp
LEFT JOIN monthly_claims mc
    ON mp.report_month = mc.report_month

UNION ALL

SELECT
    mc.report_month,
    0,
    mc.total_claims,
    mc.approved_claim_amount
FROM monthly_claims mc
LEFT JOIN monthly_premium mp
    ON mc.report_month = mp.report_month
WHERE mp.report_month IS NULL

ORDER BY report_month;

# Q4. Identify customers requiring management attention

This version creates a reusable customer risk view. It avoids recalculating the same risk score in several dashboard queries.

CREATE OR REPLACE VIEW vw_customer_risk AS

WITH claim_summary AS (
    SELECT
        p.customer_id,
        COUNT(cl.claim_id) AS total_claims,
        COALESCE(SUM(cl.claim_amount), 0) AS total_claimed,
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
        COALESCE(cs.total_claimed, 0) AS total_claimed,
        COALESCE(cs.pending_claims, 0) AS pending_claims,
        COALESCE(ps.pending_premium, 0) AS pending_premium,
        COALESCE(ps.failed_premium, 0) AS failed_premium
    FROM customers c
    LEFT JOIN claim_summary cs
        ON c.customer_id = cs.customer_id
    LEFT JOIN payment_summary ps
        ON c.customer_id = ps.customer_id
),
scored AS (
    SELECT
        *,
        (CASE WHEN total_claims > 1 THEN 2 ELSE 0 END)
        +
        (CASE WHEN total_claimed > 150000 THEN 2 ELSE 0 END)
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
    *,
    CASE
        WHEN risk_score >= 4 THEN 'High Risk'
        WHEN risk_score >= 2 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_category
FROM scored;

No we can query the view:

SELECT *
FROM vw_customer_risk
ORDER BY risk_score DESC, total_claimed DESC;

Or identify high-risk customers only:

SELECT
    customer_id,
    customer_name,
    total_claims,
    total_claimed,
    pending_premium,
    failed_premium,
    risk_score,
    risk_category
FROM vw_customer_risk
WHERE risk_category = 'High Risk'
ORDER BY risk_score DESC, total_claimed DESC;

# Q5. Final management recommendations.

Based on the sample data:
Observation	                            Business recommendation
Health claims ratio is 648.94%	        Review claims experience and earned-premium adequacy
Life claims ratio is 630.95%	        Investigate claim severity and product pricing assumptions
Premium collection rate is 86.05%	    Improve payment reminders and collection follow-up
Four customers are classified high risk	Conduct appropriate case-level reviews
₹23,000 premium is pending	            Follow up with Priya and Sneha
₹4,000 premium has failed	            Investigate Vikram's payment failure

These are preliminary findings from a small illustrative dataset, not statistically reliable portfolio conclusions.

