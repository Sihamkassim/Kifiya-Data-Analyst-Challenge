-- ============================================================
-- INSERT STUDENT LOAN DATA (MOCK DATA BASED ON REAL PATTERNS)
-- Copy and paste into Neon's SQL Editor
-- ============================================================

-- Clear existing data (if any)
TRUNCATE TABLE student_loans RESTART IDENTITY;

-- Insert realistic student loan portfolio data
-- Based on actual US Federal Student Aid patterns

INSERT INTO student_loans (country_code, country_name, loan_status, loan_amount_usd, interest_rate, disbursement_year, recipients_millions, outstanding_amount) VALUES
-- Direct Loans (most common)
('USA', 'United States', 'in repayment', 150000000000.00, 4.99, 2020, 18.5, 145000000000.00),
('USA', 'United States', 'in school', 45000000000.00, 4.99, 2021, 12.3, 45000000000.00),
('USA', 'United States', 'grace period', 25000000000.00, 4.99, 2021, 8.7, 25000000000.00),
('USA', 'United States', 'deferment', 18000000000.00, 4.99, 2020, 6.2, 18000000000.00),
('USA', 'United States', 'forbearance', 22000000000.00, 4.99, 2020, 4.1, 22000000000.00),

-- Defaulted loans (higher risk)
('USA', 'United States', 'default', 8500000000.00, 4.99, 2018, 2.8, 9200000000.00),
('USA', 'United States', 'default', 3200000000.00, 6.80, 2017, 1.2, 3500000000.00),
('USA', 'United States', 'default', 1500000000.00, 6.80, 2016, 0.8, 1650000000.00),

-- Paid in full (successful)
('USA', 'United States', 'paid in full', 89000000000.00, 4.50, 2015, 15.2, 0.00),
('USA', 'United States', 'paid in full', 67000000000.00, 5.00, 2014, 12.8, 0.00),

-- FFEL Loans (older program)
('USA', 'United States', 'in repayment', 25000000000.00, 6.80, 2010, 8.5, 18000000000.00),
('USA', 'United States', 'in repayment', 12000000000.00, 6.80, 2009, 4.2, 9500000000.00),
('USA', 'United States', 'default', 4500000000.00, 6.80, 2008, 1.5, 5100000000.00),

-- Perkins Loans (campus-based)
('USA', 'United States', 'in repayment', 800000000.00, 5.00, 2019, 0.5, 650000000.00),
('USA', 'United States', 'in school', 350000000.00, 5.00, 2020, 0.3, 350000000.00),
('USA', 'United States', 'default', 120000000.00, 5.00, 2015, 0.1, 135000000.00),

-- PLUS Loans (parents/grad students)
('USA', 'United States', 'in repayment', 28000000000.00, 7.54, 2021, 1.2, 27000000000.00),
('USA', 'United States', 'deferment', 8000000000.00, 7.54, 2021, 0.4, 8000000000.00),
('USA', 'United States', 'default', 1200000000.00, 7.54, 2019, 0.1, 1300000000.00),

-- Consolidated loans
('USA', 'United States', 'in repayment', 45000000000.00, 5.50, 2020, 5.5, 43000000000.00),
('USA', 'United States', 'in repayment', 28000000000.00, 5.50, 2019, 3.8, 26500000000.00),

-- Other countries (smaller datasets for comparison)
('CAN', 'Canada', 'in repayment', 25000000000.00, 5.00, 2021, 2.1, 23000000000.00),
('CAN', 'Canada', 'in school', 8000000000.00, 5.00, 2021, 1.5, 8000000000.00),
('CAN', 'Canada', 'default', 1200000000.00, 5.00, 2019, 0.3, 1350000000.00),

('GBR', 'United Kingdom', 'in repayment', 18000000000.00, 6.00, 2021, 1.8, 16500000000.00),
('GBR', 'United Kingdom', 'in school', 6000000000.00, 6.00, 2021, 1.2, 6000000000.00),
('GBR', 'United Kingdom', 'default', 800000000.00, 6.00, 2019, 0.2, 900000000.00),

('AUS', 'Australia', 'in repayment', 12000000000.00, 4.50, 2021, 1.5, 11000000000.00),
('AUS', 'Australia', 'in school', 4000000000.00, 4.50, 2021, 1.0, 4000000000.00),
('AUS', 'Australia', 'default', 500000000.00, 4.50, 2019, 0.15, 550000000.00),

('DEU', 'Germany', 'in repayment', 15000000000.00, 4.00, 2021, 1.2, 14000000000.00),
('DEU', 'Germany', 'in school', 5000000000.00, 4.00, 2021, 0.9, 5000000000.00),
('DEU', 'Germany', 'default', 300000000.00, 4.00, 2019, 0.08, 330000000.00),

('FRA', 'France', 'in repayment', 10000000000.00, 4.20, 2021, 1.0, 9200000000.00),
('FRA', 'France', 'in school', 3500000000.00, 4.20, 2021, 0.7, 3500000000.00),
('FRA', 'France', 'default', 400000000.00, 4.20, 2019, 0.1, 440000000.00),

('JPN', 'Japan', 'in repayment', 20000000000.00, 3.50, 2021, 1.5, 18500000000.00),
('JPN', 'Japan', 'in school', 7000000000.00, 3.50, 2021, 1.1, 7000000000.00),
('JPN', 'Japan', 'default', 600000000.00, 3.50, 2019, 0.12, 660000000.00),

('IND', 'India', 'in repayment', 8000000000.00, 8.50, 2021, 2.5, 7500000000.00),
('IND', 'India', 'in school', 3000000000.00, 8.50, 2021, 1.8, 3000000000.00),
('IND', 'India', 'default', 1200000000.00, 8.50, 2019, 0.5, 1350000000.00);

-- Verify data was inserted
SELECT 
    COUNT(*) as total_records,
    COUNT(DISTINCT country_code) as countries,
    COUNT(DISTINCT loan_status) as status_types,
    SUM(loan_amount_usd) as total_portfolio_value
FROM student_loans;
