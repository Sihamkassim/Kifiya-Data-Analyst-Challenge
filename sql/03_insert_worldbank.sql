-- ============================================================
-- INSERT WORLD BANK INDICATORS (MOCK ECONOMIC DATA)
-- Economic indicators for analysis correlation
-- ============================================================

-- Clear existing data
TRUNCATE TABLE world_bank_indicators RESTART IDENTITY;

-- Insert GDP data (indicator: NY.GDP.MKTP.CD)
INSERT INTO world_bank_indicators (country_code, country_name, indicator_name, year, value) VALUES
('USA', 'United States', 'GDP (current US$)', 2020, 21060000000000.00),
('USA', 'United States', 'GDP (current US$)', 2021, 23320000000000.00),
('USA', 'United States', 'GDP (current US$)', 2022, 25460000000000.00),
('CAN', 'Canada', 'GDP (current US$)', 2020, 1643000000000.00),
('CAN', 'Canada', 'GDP (current US$)', 2021, 1991000000000.00),
('CAN', 'Canada', 'GDP (current US$)', 2022, 2140000000000.00),
('GBR', 'United Kingdom', 'GDP (current US$)', 2020, 2760000000000.00),
('GBR', 'United Kingdom', 'GDP (current US$)', 2021, 3131000000000.00),
('GBR', 'United Kingdom', 'GDP (current US$)', 2022, 3089000000000.00),
('AUS', 'Australia', 'GDP (current US$)', 2020, 1330000000000.00),
('AUS', 'Australia', 'GDP (current US$)', 2021, 1542000000000.00),
('AUS', 'Australia', 'GDP (current US$)', 2022, 1675000000000.00),
('DEU', 'Germany', 'GDP (current US$)', 2020, 3890000000000.00),
('DEU', 'Germany', 'GDP (current US$)', 2021, 4260000000000.00),
('DEU', 'Germany', 'GDP (current US$)', 2022, 4080000000000.00),
('FRA', 'France', 'GDP (current US$)', 2020, 2630000000000.00),
('FRA', 'France', 'GDP (current US$)', 2021, 2960000000000.00),
('FRA', 'France', 'GDP (current US$)', 2022, 2780000000000.00),
('JPN', 'Japan', 'GDP (current US$)', 2020, 5050000000000.00),
('JPN', 'Japan', 'GDP (current US$)', 2021, 4940000000000.00),
('JPN', 'Japan', 'GDP (current US$)', 2022, 4230000000000.00),
('IND', 'India', 'GDP (current US$)', 2020, 2670000000000.00),
('IND', 'India', 'GDP (current US$)', 2021, 3170000000000.00),
('IND', 'India', 'GDP (current US$)', 2022, 3380000000000.00);

-- Insert Unemployment data (indicator: SL.UEM.TOTL.ZS)
INSERT INTO world_bank_indicators (country_code, country_name, indicator_name, year, value) VALUES
('USA', 'United States', 'Unemployment Rate (%)', 2020, 8.05),
('USA', 'United States', 'Unemployment Rate (%)', 2021, 5.35),
('USA', 'United States', 'Unemployment Rate (%)', 2022, 3.63),
('CAN', 'Canada', 'Unemployment Rate (%)', 2020, 9.46),
('CAN', 'Canada', 'Unemployment Rate (%)', 2021, 7.51),
('CAN', 'Canada', 'Unemployment Rate (%)', 2022, 5.28),
('GBR', 'United Kingdom', 'Unemployment Rate (%)', 2020, 4.52),
('GBR', 'United Kingdom', 'Unemployment Rate (%)', 2021, 4.53),
('GBR', 'United Kingdom', 'Unemployment Rate (%)', 2022, 3.73),
('AUS', 'Australia', 'Unemployment Rate (%)', 2020, 6.46),
('AUS', 'Australia', 'Unemployment Rate (%)', 2021, 5.16),
('AUS', 'Australia', 'Unemployment Rate (%)', 2022, 3.67),
('DEU', 'Germany', 'Unemployment Rate (%)', 2020, 3.75),
('DEU', 'Germany', 'Unemployment Rate (%)', 2021, 3.61),
('DEU', 'Germany', 'Unemployment Rate (%)', 2022, 3.05),
('FRA', 'France', 'Unemployment Rate (%)', 2020, 7.84),
('FRA', 'France', 'Unemployment Rate (%)', 2021, 7.89),
('FRA', 'France', 'Unemployment Rate (%)', 2022, 7.25),
('JPN', 'Japan', 'Unemployment Rate (%)', 2020, 2.80),
('JPN', 'Japan', 'Unemployment Rate (%)', 2021, 2.80),
('JPN', 'Japan', 'Unemployment Rate (%)', 2022, 2.60),
('IND', 'India', 'Unemployment Rate (%)', 2020, 7.89),
('IND', 'India', 'Unemployment Rate (%)', 2021, 5.98),
('IND', 'India', 'Unemployment Rate (%)', 2022, 4.82);

-- Insert Inflation data (indicator: FP.CPI.TOTL.ZG)
INSERT INTO world_bank_indicators (country_code, country_name, indicator_name, year, value) VALUES
('USA', 'United States', 'Inflation Rate (%)', 2020, 1.23),
('USA', 'United States', 'Inflation Rate (%)', 2021, 4.70),
('USA', 'United States', 'Inflation Rate (%)', 2022, 8.00),
('CAN', 'Canada', 'Inflation Rate (%)', 2020, 0.72),
('CAN', 'Canada', 'Inflation Rate (%)', 2021, 3.40),
('CAN', 'Canada', 'Inflation Rate (%)', 2022, 6.80),
('GBR', 'United Kingdom', 'Inflation Rate (%)', 2020, 0.85),
('GBR', 'United Kingdom', 'Inflation Rate (%)', 2021, 2.60),
('GBR', 'United Kingdom', 'Inflation Rate (%)', 2022, 9.10),
('AUS', 'Australia', 'Inflation Rate (%)', 2020, 0.90),
('AUS', 'Australia', 'Inflation Rate (%)', 2021, 2.80),
('AUS', 'Australia', 'Inflation Rate (%)', 2022, 6.60),
('DEU', 'Germany', 'Inflation Rate (%)', 2020, 0.51),
('DEU', 'Germany', 'Inflation Rate (%)', 2021, 3.20),
('DEU', 'Germany', 'Inflation Rate (%)', 2022, 6.90),
('FRA', 'France', 'Inflation Rate (%)', 2020, 0.53),
('FRA', 'France', 'Inflation Rate (%)', 2021, 2.10),
('FRA', 'France', 'Inflation Rate (%)', 2022, 5.20),
('JPN', 'Japan', 'Inflation Rate (%)', 2020, 0.00),
('JPN', 'Japan', 'Inflation Rate (%)', 2021, -0.20),
('JPN', 'Japan', 'Inflation Rate (%)', 2022, 2.50),
('IND', 'India', 'Inflation Rate (%)', 2020, 6.62),
('IND', 'India', 'Inflation Rate (%)', 2021, 5.13),
('IND', 'India', 'Inflation Rate (%)', 2022, 6.70);

-- Insert Population data (indicator: SP.POP.TOTL)
INSERT INTO world_bank_indicators (country_code, country_name, indicator_name, year, value) VALUES
('USA', 'United States', 'Population (total)', 2020, 331500000),
('USA', 'United States', 'Population (total)', 2021, 332500000),
('USA', 'United States', 'Population (total)', 2022, 334000000),
('CAN', 'Canada', 'Population (total)', 2020, 38000000),
('CAN', 'Canada', 'Population (total)', 2021, 38200000),
('CAN', 'Canada', 'Population (total)', 2022, 38400000),
('GBR', 'United Kingdom', 'Population (total)', 2020, 67200000),
('GBR', 'United Kingdom', 'Population (total)', 2021, 67500000),
('GBR', 'United Kingdom', 'Population (total)', 2022, 67800000),
('AUS', 'Australia', 'Population (total)', 2020, 25600000),
('AUS', 'Australia', 'Population (total)', 2021, 25900000),
('AUS', 'Australia', 'Population (total)', 2022, 26200000),
('DEU', 'Germany', 'Population (total)', 2020, 83200000),
('DEU', 'Germany', 'Population (total)', 2021, 83200000),
('DEU', 'Germany', 'Population (total)', 2022, 84300000),
('FRA', 'France', 'Population (total)', 2020, 67300000),
('FRA', 'France', 'Population (total)', 2021, 67600000),
('FRA', 'France', 'Population (total)', 2022, 67900000),
('JPN', 'Japan', 'Population (total)', 2020, 125800000),
('JPN', 'Japan', 'Population (total)', 2021, 125700000),
('JPN', 'Japan', 'Population (total)', 2022, 125500000),
('IND', 'India', 'Population (total)', 2020, 1380000000),
('IND', 'India', 'Population (total)', 2021, 1393000000),
('IND', 'India', 'Population (total)', 2022, 1406000000);

-- Verify data was inserted
SELECT 
    indicator_name,
    COUNT(*) as record_count,
    MIN(year) as start_year,
    MAX(year) as end_year
FROM world_bank_indicators
GROUP BY indicator_name;
