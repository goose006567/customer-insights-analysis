-- ============================================
-- Customer Insights Analysis — SQL Queries
-- Database: customer_insights
-- Author: Wagih Emad (Goose)
-- ============================================


-- ============================================
-- 1. TABLE SETUP
-- ============================================

CREATE TABLE customers (
    id INTEGER PRIMARY KEY,
    year_birth INTEGER,
    education VARCHAR(50),
    marital_status VARCHAR(50),
    income NUMERIC(12,2),
    kidhome INTEGER,
    teenhome INTEGER,
    dt_customer DATE,
    recency INTEGER,
    mntwines INTEGER,
    mntfruits INTEGER,
    mntmeatproducts INTEGER,
    mntfishproducts INTEGER,
    mntsweetproducts INTEGER,
    mntgoldprods INTEGER,
    numdealspurchases INTEGER,
    numwebpurchases INTEGER,
    numcatalogpurchases INTEGER,
    numstorepurchases INTEGER,
    numwebvisitsmonth INTEGER,
    acceptedcmp1 INTEGER,
    acceptedcmp2 INTEGER,
    acceptedcmp3 INTEGER,
    acceptedcmp4 INTEGER,
    acceptedcmp5 INTEGER,
    complain INTEGER,
    z_costcontact INTEGER,
    z_revenue INTEGER,
    response INTEGER,
    totalspending INTEGER,
    segment VARCHAR(20)
);


-- ============================================
-- 2. DATA ENRICHMENT
-- ============================================

-- Calculate total spending per customer
UPDATE customers
SET totalspending =
    mntwines + mntfruits + mntmeatproducts +
    mntfishproducts + mntsweetproducts + mntgoldprods;

-- Segment customers by spending behavior
UPDATE customers SET segment =
    CASE
        WHEN totalspending >= 1000 THEN 'High-Value'
        WHEN totalspending >= 400  THEN 'Mid-Value'
        ELSE 'Low-Value'
    END;


-- ============================================
-- 3. CUSTOMER SEGMENTATION ANALYSIS
-- ============================================

-- Segment summary: count, avg income, avg spending
SELECT
    segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(income), 2) AS avg_income,
    ROUND(AVG(totalspending), 2) AS avg_spending
FROM customers
GROUP BY segment
ORDER BY avg_spending DESC;


-- ============================================
-- 4. TOP CUSTOMERS
-- ============================================

-- Top 10 highest spending customers
SELECT
    id,
    income,
    totalspending,
    segment
FROM customers
ORDER BY totalspending DESC
LIMIT 10;


-- ============================================
-- 5. CHURN RISK ANALYSIS
-- ============================================

-- Average days since last purchase by segment
SELECT
    segment,
    ROUND(AVG(recency), 1) AS avg_days_since_purchase,
    COUNT(*) AS customer_count
FROM customers
GROUP BY segment
ORDER BY avg_days_since_purchase DESC;


-- ============================================
-- 6. PURCHASE CHANNEL ANALYSIS
-- ============================================

-- Average purchases per channel
SELECT
    ROUND(AVG(numwebpurchases), 2)     AS avg_web,
    ROUND(AVG(numcatalogpurchases), 2) AS avg_catalog,
    ROUND(AVG(numstorepurchases), 2)   AS avg_store
FROM customers;


-- ============================================
-- 7. FAMILY STRUCTURE IMPACT
-- ============================================

-- Impact of number of children on spending
SELECT
    kidhome + teenhome AS num_children,
    COUNT(*) AS customers,
    ROUND(AVG(totalspending), 2) AS avg_spending
FROM customers
GROUP BY num_children
ORDER BY num_children;


-- ============================================
-- 8. EDUCATION & SPENDING
-- ============================================

-- Avg spending by education level
SELECT
    education,
    COUNT(*) AS customers,
    ROUND(AVG(income), 2) AS avg_income,
    ROUND(AVG(totalspending), 2) AS avg_spending
FROM customers
GROUP BY education
ORDER BY avg_spending DESC;


-- ============================================
-- 9. MARITAL STATUS & SPENDING
-- ============================================

-- Avg spending by marital status
SELECT
    marital_status,
    COUNT(*) AS customers,
    ROUND(AVG(totalspending), 2) AS avg_spending
FROM customers
GROUP BY marital_status
ORDER BY avg_spending DESC;


-- ============================================
-- 10. CAMPAIGN RESPONSE ANALYSIS
-- ============================================

-- Which segment responds best to campaigns
SELECT
    segment,
    COUNT(*) AS total_customers,
    SUM(response) AS accepted_campaign,
    ROUND(100.0 * SUM(response) / COUNT(*), 1) AS response_rate_pct
FROM customers
GROUP BY segment
ORDER BY response_rate_pct DESC;
