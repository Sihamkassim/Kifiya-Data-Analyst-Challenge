-- ============================================================
-- STUDENT LOAN ETL - SQL SCHEMA FOR NEON
-- Copy and paste this entire file into Neon's SQL Editor
-- Run each section separately (or all at once)
-- ============================================================

-- 1. STUDENT LOANS TABLE
-- Stores individual loan records with status and amounts
DROP TABLE IF EXISTS student_loans CASCADE;

CREATE TABLE student_loans (
    id SERIAL PRIMARY KEY,
    country_code VARCHAR(3) NOT NULL,
    country_name VARCHAR(100) NOT NULL,
    loan_status VARCHAR(50) NOT NULL,
    loan_amount_usd DECIMAL(15, 2) NOT NULL,
    interest_rate DECIMAL(5, 2),
    disbursement_year INTEGER,
    recipients_millions DECIMAL(8, 2),
    outstanding_amount DECIMAL(15, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index for faster queries
CREATE INDEX idx_loans_status ON student_loans(loan_status);
CREATE INDEX idx_loans_country ON student_loans(country_code);
CREATE INDEX idx_loans_year ON student_loans(disbursement_year);

-- 2. WORLD BANK INDICATORS TABLE
-- Stores economic indicators by country and year
DROP TABLE IF EXISTS world_bank_indicators CASCADE;

CREATE TABLE world_bank_indicators (
    id SERIAL PRIMARY KEY,
    country_code VARCHAR(3) NOT NULL,
    country_name VARCHAR(100) NOT NULL,
    indicator_name VARCHAR(100) NOT NULL,
    year INTEGER NOT NULL,
    value DECIMAL(20, 6),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for common query patterns
CREATE INDEX idx_wb_country ON world_bank_indicators(country_code);
CREATE INDEX idx_wb_year ON world_bank_indicators(year);
CREATE INDEX idx_wb_indicator ON world_bank_indicators(indicator_name);

-- 3. LOAN SUMMARY VIEW (for quick analytics)
DROP VIEW IF EXISTS loan_summary_by_status;

CREATE VIEW loan_summary_by_status AS
SELECT 
    loan_status,
    COUNT(*) as loan_count,
    SUM(loan_amount_usd) as total_amount,
    AVG(loan_amount_usd) as avg_amount,
    SUM(recipients_millions) as total_recipients
FROM student_loans
GROUP BY loan_status;

-- 4. COUNTRY LOAN TOTALS VIEW
DROP VIEW IF EXISTS country_loan_totals;

CREATE VIEW country_loan_totals AS
SELECT 
    country_code,
    country_name,
    COUNT(*) as total_loans,
    SUM(loan_amount_usd) as total_loan_amount,
    AVG(interest_rate) as avg_interest_rate
FROM student_loans
GROUP BY country_code, country_name
ORDER BY total_loan_amount DESC;

-- Verify tables were created
SELECT 'Tables created successfully!' as status;
