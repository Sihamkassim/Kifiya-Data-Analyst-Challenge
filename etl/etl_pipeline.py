"""
Student Loan ETL Pipeline - XLS Version
Works with old Excel (.xls) files
"""

import pandas as pd
import sqlite3
import os

print("="*60)
print("STUDENT LOAN DATA PIPELINE (XLS Version)")
print("="*60)

# ============================================
# STEP 1: LOAD XLS FILE
# ============================================

print("\n📥 STEP 1: Loading XLS file...")

# CHANGE THIS TO YOUR FILE NAME
FILE_NAME = 'PortfoliobyLoanStatus.xls'  # <-- PUT YOUR FILE NAME HERE

# Method 1: Using xlrd engine
try:
    df = pd.read_excel(FILE_NAME, engine='xlrd', skiprows=5)
    print(f"✅ Successfully loaded {FILE_NAME}")
    print(f"📊 Shape: {len(df)} rows, {len(df.columns)} columns")
    
except Exception as e:
    print(f"❌ Error: {e}")
    
    # Method 2: Try without specifying engine
    try:
        print("   Trying alternative method...")
        df = pd.read_excel(FILE_NAME, skiprows=5)
        print(f"✅ Successfully loaded with default engine")
    except Exception as e2:
        print(f"❌ Still having issues: {e2}")
        print("\n💡 Solutions:")
        print("   1. Run: pip install xlrd")
        print("   2. Or convert file to CSV using Excel")
        print("   3. Or use: pip install openpyxl xlrd")
        exit()

# See what's in your file
print("\n📋 First 3 rows:")
print(df.head(3))

print("\n📋 Column names:")
for i, col in enumerate(df.columns):
    print(f"   {i+1}. {col}")

# ============================================
# STEP 2: UNDERSTAND YOUR DATA
# ============================================

print("\n🔍 STEP 2: Data Overview...")

# Show data types
print("\nData types:")
print(df.dtypes)

# Show missing values
print("\nMissing values:")
missing = df.isnull().sum()
print(missing[missing > 0])

# ============================================
# STEP 3: INTELLIGENT CLEANING
# ============================================

print("\n🧹 STEP 3: Cleaning data...")

df_clean = df.copy()

# AUTO-DETECT COLUMNS (works with any Excel file)
# This tries to figure out which column is which

# Find loan amount column
amount_col = None
for col in df_clean.columns:
    col_lower = str(col).lower()
    if any(word in col_lower for word in ['amount', 'loan', 'principal', 'balance', 'value']):
        if amount_col is None:  # Take first match
            amount_col = col
            print(f"   → Detected amount column: '{col}'")

# Find status column
status_col = None
for col in df_clean.columns:
    col_lower = str(col).lower()
    if any(word in col_lower for word in ['status', 'state', 'condition', 'performance']):
        if status_col is None:
            status_col = col
            print(f"   → Detected status column: '{col}'")

# Find interest rate column
rate_col = None
for col in df_clean.columns:
    col_lower = str(col).lower()
    if any(word in col_lower for word in ['interest', 'rate', 'int', 'apr']):
        if rate_col is None:
            rate_col = col
            print(f"   → Detected interest rate column: '{col}'")

# Find date column
date_col = None
for col in df_clean.columns:
    col_lower = str(col).lower()
    if any(word in col_lower for word in ['date', 'day', 'issued', 'disbursement']):
        if date_col is None:
            date_col = col
            print(f"   → Detected date column: '{col}'")

# If no columns detected, show all columns for manual identification
if not any([amount_col, status_col, rate_col, date_col]):
    print("\n   ⚠️ Could not auto-detect columns. Available columns:")
    for i, col in enumerate(df_clean.columns):
        print(f"      {i+1}. '{col}'")
    print("\n   💡 Please tell me which column is which, and I'll update the code!")

# Clean the detected columns
if amount_col:
    # Convert to numeric
    df_clean[amount_col] = pd.to_numeric(df_clean[amount_col], errors='coerce')
    print(f"   ✅ Cleaned amount column")

if status_col:
    # Standardize text
    df_clean[status_col] = df_clean[status_col].astype(str).str.lower().str.strip()
    print(f"   ✅ Cleaned status column")

if rate_col:
    # Convert to numeric
    df_clean[rate_col] = pd.to_numeric(df_clean[rate_col], errors='coerce')
    # Fill missing with median
    if df_clean[rate_col].isnull().any():
        median_rate = df_clean[rate_col].median()
        df_clean[rate_col] = df_clean[rate_col].fillna(median_rate)
    print(f"   ✅ Cleaned interest rate column")

if date_col:
    # Convert to datetime
    df_clean[date_col] = pd.to_datetime(df_clean[date_col], errors='coerce')
    print(f"   ✅ Cleaned date column")

# Remove rows with critical missing data
critical_cols = [col for col in [amount_col, status_col] if col is not None]
if critical_cols:
    before_count = len(df_clean)
    df_clean = df_clean.dropna(subset=critical_cols)
    after_count = len(df_clean)
    if before_count > after_count:
        print(f"   → Removed {before_count - after_count} rows with missing critical data")

# ============================================
# STEP 4: CREATE DERIVED COLUMNS
# ============================================

print("\n📊 STEP 4: Creating analysis columns...")

if amount_col:
    # Create loan size categories
    def categorize_loan(amount):
        if pd.isna(amount):
            return 'Unknown'
        elif amount < 10000:
            return 'Small (<$10k)'
        elif amount < 20000:
            return 'Medium ($10k-$20k)'
        elif amount < 50000:
            return 'Large ($20k-$50k)'
        else:
            return 'Very Large (>$50k)'
    
    df_clean['loan_size'] = df_clean[amount_col].apply(categorize_loan)
    print(f"   ✅ Created 'loan_size' column")

if status_col:
    # Create high-risk flag
    df_clean['high_risk'] = (df_clean[status_col] == 'default').astype(int)
    print(f"   ✅ Created 'high_risk' flag")

if date_col:
    # Extract year
    df_clean['year'] = df_clean[date_col].dt.year
    print(f"   ✅ Created 'year' column")

    # Extract month
    df_clean['month'] = df_clean[date_col].dt.month
    print(f"   ✅ Created 'month' column")

print(f"\n✅ Cleaning complete! {len(df_clean)} rows ready")

# ============================================
# STEP 5: SAVE TO DATABASE
# ============================================

print("\n💾 STEP 5: Saving to SQLite database...")

conn = sqlite3.connect('student_loans.db')

# Save to database
df_clean.to_sql('loans', conn, if_exists='replace', index=False)
print("✅ Data saved to student_loans.db")

# Verify
verify = pd.read_sql("SELECT COUNT(*) as count FROM loans", conn)
print(f"📊 Verified: {verify['count'].iloc[0]} records in database")

conn.close()

# ============================================
# STEP 6: GENERATE INSIGHTS
# ============================================

print("\n📈 STEP 6: Key Insights")
print("="*60)

if status_col and amount_col:
    # Insight 1: Portfolio by Status (This is your "Portfolio by Loan Status"!)
    print(f"\n📊 INSIGHT 1: Portfolio by {status_col}")
    status_summary = df_clean.groupby(status_col).agg({
        amount_col: ['count', 'sum', 'mean']
    }).round(2)
    
    for status in df_clean[status_col].unique():
        count = len(df_clean[df_clean[status_col] == status])
        total = df_clean[df_clean[status_col] == status][amount_col].sum()
        pct = (count / len(df_clean)) * 100
        print(f"   • {status}: {count} loans (${total:,.2f}) - {pct:.1f}%")

if amount_col:
    # Insight 2: Total portfolio value
    total_value = df_clean[amount_col].sum()
    avg_value = df_clean[amount_col].mean()
    print(f"\n💰 INSIGHT 2: Portfolio Value")
    print(f"   • Total value: ${total_value:,.2f}")
    print(f"   • Average loan: ${avg_value:,.2f}")
    print(f"   • Number of loans: {len(df_clean)}")

if status_col:
    # Insight 3: Risk assessment
    if 'default' in df_clean[status_col].unique():
        default_count = len(df_clean[df_clean[status_col] == 'default'])
        default_pct = (default_count / len(df_clean)) * 100
        print(f"\n⚠️ INSIGHT 3: Risk Assessment")
        print(f"   • Default rate: {default_count} loans ({default_pct:.1f}%)")
        if default_pct > 30:
            print(f"   • ALERT: High default rate!")
        else:
            print(f"   • Default rate within acceptable range")

if rate_col:
    # Insight 4: Interest rate analysis
    print(f"\n💳 INSIGHT 4: Interest Rate Analysis")
    print(f"   • Average rate: {df_clean[rate_col].mean():.2f}%")
    print(f"   • Highest rate: {df_clean[rate_col].max():.2f}%")
    print(f"   • Lowest rate: {df_clean[rate_col].min():.2f}%")
    
    if status_col:
        rates_by_status = df_clean.groupby(status_col)[rate_col].mean()
        print(f"\n   Average rates by status:")
        for status, rate in rates_by_status.items():
            print(f"      • {status}: {rate:.2f}%")

if amount_col:
    # Insight 5: Loan size distribution
    print(f"\n📏 INSIGHT 5: Loan Size Distribution")
    size_summary = df_clean.groupby('loan_size')[amount_col].agg(['count', 'sum'])
    for size in size_summary.index:
        count = size_summary.loc[size, 'count']
        total = size_summary.loc[size, 'sum']
        print(f"   • {size}: {count} loans (${total:,.2f})")

# ============================================
# STEP 7: SAVE OUTPUTS
# ============================================

print("\n💾 STEP 7: Saving outputs...")

# Save as CSV
df_clean.to_csv('cleaned_student_loans.csv', index=False)
print("✅ Saved: cleaned_student_loans.csv")

# Save column mapping for reference
with open('column_mapping.txt', 'w') as f:
    f.write("Column Mapping for this dataset:\n")
    f.write("="*40 + "\n")
    f.write(f"Amount column: {amount_col}\n")
    f.write(f"Status column: {status_col}\n")
    f.write(f"Rate column: {rate_col}\n")
    f.write(f"Date column: {date_col}\n")
    f.write("\nAll columns:\n")
    for col in df_clean.columns:
        f.write(f"  - {col}\n")
print("✅ Saved: column_mapping.txt")

print("\n" + "="*60)
print("✅ PIPELINE COMPLETE!")
print("="*60)

print("\n📁 Files created in your folder:")
print("   1. student_loans.db - SQLite database")
print("   2. cleaned_student_loans.csv - Cleaned data")
print("   3. column_mapping.txt - Documentation of columns")
print("\n🎯 Next: Run 'python dashboard.py' to create visualizations")