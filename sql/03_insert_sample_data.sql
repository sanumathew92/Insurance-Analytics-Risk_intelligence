
-- =====================================================
-- Project: Insurance Analytics & Risk Intelligence
-- Script: 03_insert_sample_data.sql
-- Database: insurance_analytics
-- MySQL 8.0
-- =====================================================

USE insurance_analytics;

-- -----------------------------------------------------
-- 1. CUSTOMERS
-- Gender and signup_date were not supplied in the
-- original sample data, so they are kept NULL.
-- -----------------------------------------------------

INSERT INTO customers
(customer_id, customer_name, gender, age, city, signup_date)
VALUES
(101, 'Amit',   NULL, 29, 'Mumbai',    NULL),
(102, 'Priya',  NULL, 32, 'Pune',      NULL),
(103, 'Rahul',  NULL, 26, 'Delhi',     NULL),
(104, 'Neha',   NULL, 35, 'Mumbai',    NULL),
(105, 'Karan',  NULL, 30, 'Bangalore', NULL),
(106, 'Sneha',  NULL, 28, 'Pune',      NULL),
(107, 'Arjun',  NULL, 41, 'Delhi',     NULL),
(108, 'Meera',  NULL, 33, 'Mumbai',    NULL),
(109, 'Vikram', NULL, 27, 'Chennai',   NULL),
(110, 'Anjali', NULL, 31, 'Bangalore', NULL);


-- -----------------------------------------------------
-- 2. INSURANCE PRODUCTS
-- -----------------------------------------------------

INSERT INTO insurance_products
(product_id, product_name, insurance_type, base_premium)
VALUES
(1, 'Health Secure', 'Health', 12000.00),
(2, 'Life Protect',  'Life',   18000.00),
(3, 'Motor Plus',    'Motor',   8000.00),
(4, 'Travel Shield', 'Travel',  5000.00);


-- -----------------------------------------------------
-- 3. POLICIES
-- -----------------------------------------------------

INSERT INTO policies
(
    policy_id,
    customer_id,
    product_id,
    policy_start_date,
    policy_end_date,
    sum_insured,
    premium_amount,
    policy_status
)
VALUES
(2001, 101, 1, '2026-01-05', '2026-12-31',  500000.00, 12000.00, 'Active'),
(2002, 102, 2, '2026-01-10', '2026-12-31', 2500000.00, 18000.00, 'Active'),
(2003, 103, 3, '2026-01-15', '2026-04-30',  500000.00,  8000.00, 'Expired'),
(2004, 104, 1, '2026-02-02', '2026-12-31', 1000000.00, 15000.00, 'Active'),
(2005, 105, 2, '2026-02-10', '2026-12-31', 5000000.00, 25000.00, 'Active'),
(2006, 106, 3, '2026-02-15', '2026-05-31',  800000.00,  9000.00, 'Cancelled'),
(2007, 107, 1, '2026-03-01', '2026-12-31', 1500000.00, 20000.00, 'Active'),
(2008, 108, 4, '2026-03-05', '2026-09-30', 1000000.00,  5000.00, 'Active'),
(2009, 109, 3, '2026-03-10', '2026-04-30',  400000.00,  4000.00, 'Expired'),
(2010, 110, 2, '2026-03-15', '2026-12-31', 3000000.00, 22000.00, 'Active'),
(2011, 101, 4, '2026-04-02', '2026-09-30',  500000.00,  6000.00, 'Active'),
(2012, 102, 1, '2026-04-08', '2026-12-31',  700000.00, 14000.00, 'Active'),
(2013, 103, 2, '2026-04-12', '2026-12-31', 2000000.00, 19000.00, 'Active'),
(2014, 105, 3, '2026-04-20', '2026-10-31', 1200000.00, 11000.00, 'Active'),
(2015, 106, 4, '2026-05-01', '2026-10-31',  600000.00,  5500.00, 'Active');


-- -----------------------------------------------------
-- 4. PREMIUM PAYMENTS
-- -----------------------------------------------------

INSERT INTO premium_payments
(payment_id, policy_id, payment_date, amount_paid, payment_status)
VALUES
(3001, 2001, '2026-01-05', 12000.00, 'Paid'),
(3002, 2002, '2026-01-10', 18000.00, 'Paid'),
(3003, 2003, '2026-01-15',  8000.00, 'Paid'),
(3004, 2004, '2026-02-02', 15000.00, 'Paid'),
(3005, 2005, '2026-02-10', 25000.00, 'Paid'),
(3006, 2006, '2026-02-15',  9000.00, 'Pending'),
(3007, 2007, '2026-03-01', 20000.00, 'Paid'),
(3008, 2008, '2026-03-05',  5000.00, 'Paid'),
(3009, 2009, '2026-03-10',  4000.00, 'Failed'),
(3010, 2010, '2026-03-15', 22000.00, 'Paid'),
(3011, 2011, '2026-04-02',  6000.00, 'Paid'),
(3012, 2012, '2026-04-08', 14000.00, 'Pending'),
(3013, 2013, '2026-04-12', 19000.00, 'Paid'),
(3014, 2014, '2026-04-20', 11000.00, 'Paid'),
(3015, 2015, '2026-05-01',  5500.00, 'Paid');


-- -----------------------------------------------------
-- 5. CLAIMS
-- -----------------------------------------------------

INSERT INTO claims
(
    claim_id,
    policy_id,
    claim_date,
    claim_amount,
    approved_amount,
    claim_status
)
VALUES
(4001, 2001, '2026-02-05',  50000.00,  45000.00, 'Approved'),
(4002, 2002, '2026-02-10', 100000.00,  90000.00, 'Approved'),
(4003, 2003, '2026-02-15',  30000.00,      0.00, 'Rejected'),
(4004, 2004, '2026-03-02',  80000.00,  70000.00, 'Approved'),
(4005, 2005, '2026-03-10', 200000.00, 180000.00, 'Approved'),
(4006, 2006, '2026-03-15',  40000.00,      0.00, 'Pending'),
(4007, 2007, '2026-04-01', 150000.00, 130000.00, 'Approved'),
(4008, 2008, '2026-04-05',  25000.00,  20000.00, 'Approved'),
(4009, 2009, '2026-04-10',  60000.00,      0.00, 'Rejected'),
(4010, 2010, '2026-04-15', 120000.00, 100000.00, 'Approved'),
(4011, 2011, '2026-04-20',  15000.00,  12000.00, 'Approved'),
(4012, 2012, '2026-05-05',  70000.00,  60000.00, 'Approved'),
(4013, 2013, '2026-05-10', 180000.00, 160000.00, 'Approved'),
(4014, 2014, '2026-05-15',  90000.00,  75000.00, 'Approved'),
(4015, 2015, '2026-05-20',  35000.00,      0.00, 'Pending');


-- -----------------------------------------------------
-- 6. AGENTS
-- No source records or policy-agent mapping supplied.
-- Therefore, no artificial agent records are inserted.
-- -----------------------------------------------------


-- =====================================================
-- INITIAL RECORD COUNT
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
