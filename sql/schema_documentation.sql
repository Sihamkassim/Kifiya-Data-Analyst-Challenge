-- ============================================================
-- DATABASE SCHEMA DOCUMENTATION
-- Student Loan ETL Pipeline
-- ============================================================

-- ============================================================
-- CORE TABLE: STUDENT LOANS
-- Stores loan portfolio data with status and amounts
-- ============================================================

CREATE TABLE student_loans (
    id SERIAL PRIMARY KEY,                           -- Auto-incrementing unique ID
    country_code VARCHAR(3) NOT NULL,               -- ISO country code (USA, CAN, etc.)
    country_name VARCHAR(100) NOT NULL,               -- Full country name
    loan_status VARCHAR(50) NOT NULL,                 -- Current status: in repayment, default, etc.
    loan_amount_usd DECIMAL(15, 2) NOT NULL,        -- Original loan amount
    interest_rate DECIMAL(5, 2),                      -- Annual interest rate percentage
    disbursement_year INTEGER,                      -- Year loan was disbursed
    recipients_millions DECIMAL(8, 2),              -- Number of recipients in millions
    outstanding_amount DECIMAL(15, 2),                -- Current outstanding balance
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP    -- Record creation timestamp
);

-- Indexes for query performance
CREATE INDEX idx_loans_status ON student_loans(loan_status);
CREATE INDEX idx_loans_country ON student_loans(country_code);
CREATE INDEX idx_loans_year ON student_loans(disbursement_year);

COMMENT ON TABLE student_loans IS 'Primary table storing student loan portfolio records from US Federal Student Aid and international programs';

-- ============================================================
-- REFERENCE TABLE: WORLD BANK INDICATORS
-- Economic indicators by country and year for analysis
-- ============================================================

CREATE TABLE world_bank_indicators (
    id SERIAL PRIMARY KEY,                           -- Auto-incrementing unique ID
    country_code VARCHAR(3) NOT NULL,                 -- ISO country code
    country_name VARCHAR(100) NOT NULL,               -- Full country name
    indicator_name VARCHAR(100) NOT NULL,             -- Indicator type: GDP, unemployment, etc.
    year INTEGER NOT NULL,                            -- Year of measurement
    value DECIMAL(20, 6),                             -- Indicator value (supports decimals)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP    -- Record creation timestamp
);

-- Indexes for common query patterns
CREATE INDEX idx_wb_country ON world_bank_indicators(country_code);
CREATE INDEX idx_wb_year ON world_bank_indicators(year);
CREATE INDEX idx_wb_indicator ON world_bank_indicators(indicator_name);
CREATE INDEX idx_wb_country_year ON world_bank_indicators(country_code, year);

COMMENT ON TABLE world_bank_indicators IS 'World Bank economic indicators (GDP, unemployment, inflation, population) for correlation analysis with loan data';

-- ============================================================
-- ANALYTICS VIEWS
-- Pre-computed aggregations for dashboard and reporting
-- ============================================================

-- View 1: Portfolio Summary by Status
-- Provides quick overview of loan distribution
CREATE OR REPLACE VIEW loan_summary_by_status AS
SELECT 
    loan_status,
    COUNT(*) as loan_count,
    SUM(loan_amount_usd) as total_amount,
    AVG(loan_amount_usd) as avg_amount,
    SUM(recipients_millions) as total_recipients,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) as pct_of_portfolio
FROM student_loans
GROUP BY loan_status
ORDER BY total_amount DESC;

COMMENT ON VIEW loan_summary_by_status IS 'Aggregated view of loans grouped by status for portfolio analysis';

-- View 2: Country Loan Totals
-- Country-level portfolio metrics
CREATE OR REPLACE VIEW country_loan_totals AS
SELECT 
    country_code,
    country_name,
    COUNT(*) as total_loans,
    SUM(loan_amount_usd) as total_loan_amount,
    AVG(loan_amount_usd) as avg_loan_amount,
    AVG(interest_rate) as avg_interest_rate,
    SUM(recipients_millions) as total_recipients,
    ROUND(100.0 * SUM(CASE WHEN loan_status = 'default' THEN 1 ELSE 0 END) / COUNT(*), 2) as default_rate_pct
FROM student_loans
GROUP BY country_code, country_name
ORDER BY total_loan_amount DESC;

COMMENT ON VIEW country_loan_totals IS 'Country-level aggregated metrics including default rates';

-- View 3: Loan Status Categories
-- Simplified risk categorization
CREATE OR REPLACE VIEW loan_status_categories AS
SELECT 
    CASE 
        WHEN loan_status IN ('in repayment', 'in school', 'grace period') THEN 'Active'
        WHEN loan_status = 'default' THEN 'Defaulted'
        WHEN loan_status = 'paid in full' THEN 'Completed'
        ELSE 'Other'
    END as category,
    COUNT(*) as loan_count,
    SUM(loan_amount_usd) as total_amount,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) as pct_of_total
FROM student_loans
GROUP BY 
    CASE 
        WHEN loan_status IN ('in repayment', 'in school', 'grace period') THEN 'Active'
        WHEN loan_status = 'default' THEN 'Defaulted'
        WHEN loan_status = 'paid in full' THEN 'Completed'
        ELSE 'Other'
    END
ORDER BY total_amount DESC;

COMMENT ON VIEW loan_status_categories IS 'Risk-based categorization of loans (Active/Defaulted/Completed)';

-- View 4: Economic Correlation View
-- Joins loan data with economic indicators for analysis
CREATE OR REPLACE VIEW loan_economic_correlation AS
SELECT 
    sl.country_name,
    sl.loan_status,
    COUNT(*) as loan_count,
    SUM(sl.loan_amount_usd) as loan_amount,
    ROUND(AVG(wb_unemp.value), 2) as avg_unemployment_rate,
    ROUND(AVG(wb_gdp.value)/1e12, 2) as avg_gdp_trillions,
    ROUND(AVG(wb_inf.value), 2) as avg_inflation_rate
FROM student_loans sl
LEFT JOIN world_bank_indicators wb_unemp 
    ON sl.country_code = wb_unemp.country_code 
    AND wb_unemp.indicator_name = 'Unemployment Rate (%)'
    AND wb_unemp.year = 2021
LEFT JOIN world_bank_indicators wb_gdp 
    ON sl.country_code = wb_gdp.country_code 
    AND wb_gdp.indicator_name = 'GDP (current US$)'
    AND wb_gdp.year = 2021
LEFT JOIN world_bank_indicators wb_inf 
    ON sl.country_code = wb_inf.country_code 
    AND wb_inf.indicator_name = 'Inflation Rate (%)'
    AND wb_inf.year = 2021
GROUP BY sl.country_name, sl.loan_status
ORDER BY loan_amount DESC;

COMMENT ON VIEW loan_economic_correlation IS 'Joins loan data with 2021 economic indicators for correlation analysis';

-- ============================================================
-- DATA INTEGRITY CONSTRAINTS
-- Validation rules to ensure data quality
-- ============================================================

-- Add check constraints (optional, for production)
-- ALTER TABLE student_loans 
--     ADD CONSTRAINT chk_positive_amount CHECK (loan_amount_usd > 0),
--     ADD CONSTRAINT chk_valid_year CHECK (disbursement_year BETWEEN 1950 AND 2030),
--     ADD CONSTRAINT chk_positive_rate CHECK (interest_rate >= 0);

-- ============================================================
-- EXAMPLE QUERIES FOR VALIDATION
-- Use these to verify data loaded correctly
-- ============================================================

-- Verify row counts
SELECT 
    'student_loans' as table_name, 
    COUNT(*) as row_count 
FROM student_loans
UNION ALL
SELECT 
    'world_bank_indicators', 
    COUNT(*) 
FROM world_bank_indicators;

-- Check data ranges
SELECT 
    MIN(loan_amount_usd) as min_amount,
    MAX(loan_amount_usd) as max_amount,
    MIN(disbursement_year) as earliest_year,
    MAX(disbursement_year) as latest_year
FROM student_loans;

-- Verify relationships
SELECT 
    sl.country_code,
    sl.country_name,
    COUNT(DISTINCT sl.id) as loan_records,
    COUNT(DISTINCT wb.id) as indicator_records
FROM student_loans sl
LEFT JOIN world_bank_indicators wb ON sl.country_code = wb.country_code
GROUP BY sl.country_code, sl.country_name
ORDER BY loan_records DESC;
