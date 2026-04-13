-- ============================================================
-- ANALYSIS QUERIES - Key Insights from Student Loan Data
-- Run these in Neon's SQL Editor to get insights
-- ============================================================

-- ============================================================
-- INSIGHT 1: Portfolio Distribution by Status
-- ============================================================
SELECT 
    loan_status,
    COUNT(*) as loan_count,
    SUM(loan_amount_usd) as total_amount,
    ROUND(AVG(loan_amount_usd), 2) as avg_loan_amount,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) as pct_of_portfolio
FROM student_loans
GROUP BY loan_status
ORDER BY total_amount DESC;

-- ============================================================
-- INSIGHT 2: Default Rate Analysis by Country
-- ============================================================
WITH country_totals AS (
    SELECT 
        country_code,
        country_name,
        COUNT(*) as total_loans,
        SUM(loan_amount_usd) as total_amount
    FROM student_loans
    GROUP BY country_code, country_name
),
defaults AS (
    SELECT 
        country_code,
        COUNT(*) as default_count,
        SUM(loan_amount_usd) as default_amount
    FROM student_loans
    WHERE loan_status = 'default'
    GROUP BY country_code
)
SELECT 
    ct.country_name,
    ct.total_loans,
    COALESCE(d.default_count, 0) as defaults,
    ROUND(100.0 * COALESCE(d.default_count, 0) / ct.total_loans, 2) as default_rate_pct,
    ct.total_amount,
    COALESCE(d.default_amount, 0) as default_amount,
    ROUND(100.0 * COALESCE(d.default_amount, 0) / ct.total_amount, 2) as default_amount_pct
FROM country_totals ct
LEFT JOIN defaults d ON ct.country_code = d.country_code
ORDER BY default_rate_pct DESC;

-- ============================================================
-- INSIGHT 3: Loan Trends by Year
-- ============================================================
SELECT 
    disbursement_year,
    COUNT(*) as loans_disbursed,
    SUM(loan_amount_usd) as total_disbursed,
    ROUND(AVG(loan_amount_usd), 2) as avg_loan_size,
    SUM(recipients_millions) as total_recipients_millions
FROM student_loans
GROUP BY disbursement_year
ORDER BY disbursement_year DESC;

-- ============================================================
-- INSIGHT 4: Economic Correlation (Join with World Bank data)
-- ============================================================
SELECT 
    sl.country_name,
    sl.loan_status,
    COUNT(*) as loan_count,
    SUM(sl.loan_amount_usd) as loan_amount,
    ROUND(AVG(wb.value), 2) as avg_unemployment_rate,
    ROUND(AVG(wb2.value), 2) as avg_inflation_rate
FROM student_loans sl
LEFT JOIN world_bank_indicators wb 
    ON sl.country_code = wb.country_code 
    AND wb.indicator_name = 'Unemployment Rate (%)'
    AND wb.year = 2021
LEFT JOIN world_bank_indicators wb2 
    ON sl.country_code = wb2.country_code 
    AND wb2.indicator_name = 'Inflation Rate (%)'
    AND wb2.year = 2021
GROUP BY sl.country_name, sl.loan_status
ORDER BY sl.country_name, loan_amount DESC;

-- ============================================================
-- INSIGHT 5: Interest Rate vs Default Risk
-- ============================================================
SELECT 
    CASE 
        WHEN interest_rate < 4 THEN 'Low (< 4%)'
        WHEN interest_rate < 6 THEN 'Medium (4-6%)'
        WHEN interest_rate < 8 THEN 'High (6-8%)'
        ELSE 'Very High (> 8%)'
    END as rate_category,
    COUNT(*) as total_loans,
    SUM(CASE WHEN loan_status = 'default' THEN 1 ELSE 0 END) as defaults,
    ROUND(100.0 * SUM(CASE WHEN loan_status = 'default' THEN 1 ELSE 0 END) / COUNT(*), 2) as default_rate_pct,
    ROUND(AVG(loan_amount_usd), 2) as avg_loan_amount
FROM student_loans
GROUP BY 
    CASE 
        WHEN interest_rate < 4 THEN 'Low (< 4%)'
        WHEN interest_rate < 6 THEN 'Medium (4-6%)'
        WHEN interest_rate < 8 THEN 'High (6-8%)'
        ELSE 'Very High (> 8%)'
    END
ORDER BY default_rate_pct DESC;

-- ============================================================
-- INSIGHT 6: Top 5 Countries by Total Loan Portfolio
-- ============================================================
SELECT 
    country_name,
    COUNT(*) as total_loans,
    SUM(loan_amount_usd) as total_portfolio,
    ROUND(AVG(loan_amount_usd), 2) as avg_loan_size,
    SUM(recipients_millions) as total_recipients_millions,
    ROUND(SUM(outstanding_amount), 2) as total_outstanding
FROM student_loans
GROUP BY country_name
ORDER BY total_portfolio DESC
LIMIT 5;

-- ============================================================
-- INSIGHT 7: Loan Status Transition (Current vs Defaulted vs Paid)
-- ============================================================
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

-- ============================================================
-- BONUS: Quick Stats Summary
-- ============================================================
SELECT 
    'Total Portfolio Value' as metric,
    TO_CHAR(SUM(loan_amount_usd), 'FM$999,999,999,999,999') as value
FROM student_loans
UNION ALL
SELECT 
    'Total Countries' as metric,
    COUNT(DISTINCT country_code)::text as value
FROM student_loans
UNION ALL
SELECT 
    'Total Loan Records' as metric,
    COUNT(*)::text as value
FROM student_loans
UNION ALL
SELECT 
    'Average Interest Rate' as metric,
    ROUND(AVG(interest_rate), 2)::text || '%' as value
FROM student_loans
UNION ALL
SELECT 
    'Default Rate' as metric,
    ROUND(100.0 * SUM(CASE WHEN loan_status = 'default' THEN 1 ELSE 0 END) / COUNT(*), 2)::text || '%' as value
FROM student_loans;
