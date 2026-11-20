
-- =====================================================
-- Project: Insurance Analytics & Risk Intelligence
-- Script: 02_create_tables.sql
-- Database: insurance_analytics
-- MySQL 8.0.16+ (for enforced CHECK constraints)
-- =====================================================

USE insurance_analytics;

-- -----------------------------------------------------
-- 1. CUSTOMERS
-- -----------------------------------------------------

CREATE TABLE IF NOT EXISTS customers (
    customer_id INT NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    gender VARCHAR(20),
    age TINYINT UNSIGNED,
    city VARCHAR(100),
    signup_date DATE,

    CONSTRAINT pk_customers
        PRIMARY KEY (customer_id),

    CONSTRAINT chk_customer_age
        CHECK (age IS NULL OR age BETWEEN 1 AND 120)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- 2. INSURANCE PRODUCTS
-- -----------------------------------------------------

CREATE TABLE IF NOT EXISTS insurance_products (
    product_id INT NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    insurance_type VARCHAR(50) NOT NULL,
    base_premium DECIMAL(12,2) NOT NULL,

    CONSTRAINT pk_insurance_products
        PRIMARY KEY (product_id),

    CONSTRAINT chk_base_premium
        CHECK (base_premium >= 0)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- 3. POLICIES
-- -----------------------------------------------------

CREATE TABLE IF NOT EXISTS policies (
    policy_id INT NOT NULL,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    policy_start_date DATE NOT NULL,
    policy_end_date DATE,
    sum_insured DECIMAL(15,2) NOT NULL,
    premium_amount DECIMAL(12,2) NOT NULL,
    policy_status VARCHAR(20) NOT NULL,

    CONSTRAINT pk_policies
        PRIMARY KEY (policy_id),

    CONSTRAINT fk_policies_customers
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_policies_products
        FOREIGN KEY (product_id)
        REFERENCES insurance_products(product_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_sum_insured
        CHECK (sum_insured > 0),

    CONSTRAINT chk_policy_premium
        CHECK (premium_amount >= 0),

    CONSTRAINT chk_policy_dates
        CHECK (
            policy_end_date IS NULL
            OR policy_end_date >= policy_start_date
        ),

    CONSTRAINT chk_policy_status
        CHECK (
            policy_status IN ('Active', 'Expired', 'Cancelled')
        )
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- 4. PREMIUM PAYMENTS
-- -----------------------------------------------------

CREATE TABLE IF NOT EXISTS premium_payments (
    payment_id INT NOT NULL,
    policy_id INT NOT NULL,
    payment_date DATE NOT NULL,
    amount_paid DECIMAL(12,2) NOT NULL,
    payment_status VARCHAR(20) NOT NULL,

    CONSTRAINT pk_premium_payments
        PRIMARY KEY (payment_id),

    CONSTRAINT fk_payments_policies
        FOREIGN KEY (policy_id)
        REFERENCES policies(policy_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_payment_amount
        CHECK (amount_paid >= 0),

    CONSTRAINT chk_payment_status
        CHECK (
            payment_status IN ('Paid', 'Pending', 'Failed')
        )
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- 5. CLAIMS
-- -----------------------------------------------------

CREATE TABLE IF NOT EXISTS claims (
    claim_id INT NOT NULL,
    policy_id INT NOT NULL,
    claim_date DATE NOT NULL,
    claim_amount DECIMAL(12,2) NOT NULL,
    approved_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    claim_status VARCHAR(20) NOT NULL,

    CONSTRAINT pk_claims
        PRIMARY KEY (claim_id),

    CONSTRAINT fk_claims_policies
        FOREIGN KEY (policy_id)
        REFERENCES policies(policy_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_claim_amount
        CHECK (claim_amount >= 0),

    CONSTRAINT chk_approved_amount
        CHECK (
            approved_amount >= 0
            AND approved_amount <= claim_amount
        ),

    CONSTRAINT chk_claim_status
        CHECK (
            claim_status IN ('Approved', 'Rejected', 'Pending')
        )
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- 6. AGENTS
-- -----------------------------------------------------

CREATE TABLE IF NOT EXISTS agents (
    agent_id INT NOT NULL,
    agent_name VARCHAR(100) NOT NULL,
    branch_city VARCHAR(100),

    CONSTRAINT pk_agents
        PRIMARY KEY (agent_id)
) ENGINE = InnoDB;


-- =====================================================
-- INDEXES FOR ANALYTICAL QUERIES
-- =====================================================

-- Customer analysis
CREATE INDEX idx_customers_city
    ON customers(city);

-- Product analysis
CREATE INDEX idx_products_type
    ON insurance_products(insurance_type);

-- Policy analysis
CREATE INDEX idx_policies_customer
    ON policies(customer_id);

CREATE INDEX idx_policies_product
    ON policies(product_id);

CREATE INDEX idx_policies_status_dates
    ON policies(policy_status, policy_start_date, policy_end_date);

-- Premium collection analysis
CREATE INDEX idx_payments_policy
    ON premium_payments(policy_id);

CREATE INDEX idx_payments_status_date
    ON premium_payments(payment_status, payment_date);

-- Claims analysis
CREATE INDEX idx_claims_policy
    ON claims(policy_id);

CREATE INDEX idx_claims_status_date
    ON claims(claim_status, claim_date);

-- Agent analysis
CREATE INDEX idx_agents_branch_city
    ON agents(branch_city);


-- =====================================================
-- VERIFY TABLE CREATION
-- =====================================================

SHOW TABLES;
