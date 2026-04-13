"""
Student Loan Dashboard - Creates interactive visualizations
Supports both SQLite (local) and PostgreSQL (Neon)
"""

import pandas as pd
import sqlite3
import os
from dotenv import load_dotenv
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots
from sqlalchemy import create_engine

# Load environment variables
load_dotenv()

print("📊 Student Loan Dashboard Generator")
print("="*60)

# Try to connect to Neon PostgreSQL first, fall back to SQLite
try:
    DATABASE_URL = os.getenv('DATABASE_URL')
    if DATABASE_URL:
        engine = create_engine(DATABASE_URL)
        df = pd.read_sql("SELECT * FROM student_loans", engine)
        print("✅ Connected to Neon PostgreSQL")
    else:
        raise Exception("No DATABASE_URL found")
except Exception as e:
    print(f"⚠️  Neon connection failed: {e}")
    print("   Falling back to SQLite...")
    # Try multiple possible database locations
    db_paths = ['../student_loans.db', 'student_loans.db', '../data/student_loans.db']
    df = None
    for db_path in db_paths:
        if os.path.exists(db_path):
            conn = sqlite3.connect(db_path)
            try:
                df = pd.read_sql("SELECT * FROM loans", conn)
                print(f"✅ Connected to SQLite: {db_path}")
                break
            except:
                pass
            finally:
                conn.close()
    if df is None:
        print("⚠️  No local database found. Using sample data...")
        # Create sample data for demonstration
        df = pd.DataFrame({
            'country_code': ['USA', 'USA', 'USA', 'CAN', 'GBR'] * 9,
            'country_name': ['United States'] * 27 + ['Canada'] * 9 + ['United Kingdom'] * 9,
            'loan_status': ['in repayment', 'in school', 'default', 'in repayment', 'in repayment'] * 9,
            'loan_amount_usd': [150000000000, 45000000000, 8500000000, 25000000000, 18000000000] * 9,
            'interest_rate': [4.99, 4.99, 4.99, 5.00, 6.00] * 9,
            'disbursement_year': [2020, 2021, 2018, 2021, 2021] * 9
        })

print(f"✅ Loaded {len(df)} records")
print(f"📋 Columns available: {list(df.columns)}")

# Find the key columns (they were saved in the database)
amount_col = None
status_col = None
rate_col = None

for col in df.columns:
    if 'amount' in col.lower() or 'principal' in col.lower() or 'loan' in col.lower():
        if amount_col is None and col != 'loan_size':
            amount_col = col
    if 'status' in col.lower() or 'state' in col.lower():
        if status_col is None:
            status_col = col
    if 'rate' in col.lower() or 'interest' in col.lower():
        if rate_col is None:
            rate_col = col

print(f"\n📊 Using columns:")
print(f"   Amount: {amount_col}")
print(f"   Status: {status_col}")
print(f"   Rate: {rate_col}")

# Create visualizations
if status_col and amount_col:
    # Chart 1: Portfolio by Status (Bar Chart)
    status_data = df.groupby(status_col)[amount_col].sum().reset_index()
    fig1 = px.bar(status_data, x=status_col, y=amount_col,
                  title=f'Portfolio by {status_col}',
                  labels={status_col: 'Loan Status', amount_col: 'Total Amount ($)'},
                  color=status_col,
                  text=amount_col)
    fig1.update_traces(texttemplate='$%{text:,.0f}', textposition='outside')
    fig1.show()
    fig1.write_html("dashboard_portfolio_by_status.html")
    print("✅ Created: Portfolio by Status chart")

if amount_col:
    # Chart 2: Distribution of Loan Amounts
    fig2 = px.histogram(df, x=amount_col, 
                        title='Distribution of Loan Amounts',
                        labels={amount_col: 'Loan Amount ($)', 'count': 'Number of Loans'},
                        nbins=20)
    fig2.show()
    fig2.write_html("dashboard_loan_distribution.html")
    print("✅ Created: Loan amount distribution")

if status_col:
    # Chart 3: Status Distribution (Pie)
    status_counts = df[status_col].value_counts().reset_index()
    status_counts.columns = [status_col, 'count']
    fig3 = px.pie(status_counts, values='count', names=status_col,
                  title=f'Loan Status Distribution')
    fig3.show()
    fig3.write_html("dashboard_status_pie.html")
    print("✅ Created: Status distribution pie chart")

if amount_col and 'loan_size' in df.columns:
    # Chart 4: Loan Size Analysis
    size_data = df.groupby('loan_size')[amount_col].agg(['sum', 'count']).reset_index()
    fig4 = px.bar(size_data, x='loan_size', y='sum',
                  title='Total Amount by Loan Size Category',
                  labels={'loan_size': 'Loan Size', 'sum': 'Total Amount ($)'},
                  color='loan_size',
                  text='sum')
    fig4.update_traces(texttemplate='$%{text:,.0f}', textposition='outside')
    fig4.show()
    fig4.write_html("dashboard_loan_size.html")
    print("✅ Created: Loan size analysis")

if 'high_risk' in df.columns:
    # Chart 5: Risk Profile
    risk_data = df['high_risk'].value_counts().reset_index()
    risk_data.columns = ['high_risk', 'count']
    risk_data['risk_label'] = risk_data['high_risk'].map({0: 'Low Risk', 1: 'High Risk'})
    
    fig5 = px.pie(risk_data, values='count', names='risk_label',
                  title='Risk Profile of Portfolio',
                  color='risk_label',
                  color_discrete_map={'Low Risk': '#2ecc71', 'High Risk': '#e74c3c'})
    fig5.show()
    fig5.write_html("dashboard_risk.html")
    print("✅ Created: Risk profile")

if rate_col:
    # Chart 6: Interest Rate Analysis
    if status_col:
        rate_by_status = df.groupby(status_col)[rate_col].mean().reset_index()
        fig6 = px.bar(rate_by_status, x=status_col, y=rate_col,
                      title=f'Average Interest Rate by {status_col}',
                      labels={status_col: 'Status', rate_col: 'Interest Rate (%)'},
                      color=status_col)
        fig6.show()
        fig6.write_html("dashboard_interest_rates.html")
        print("✅ Created: Interest rate analysis")

print("\n📊 Creating combined dashboard...")

# Calculate metrics
total_loans = len(df)
total_amount = df[amount_col].sum() if amount_col else 0
default_count = len(df[df[status_col] == 'default']) if status_col else 0
default_rate = (default_count / total_loans * 100) if total_loans > 0 else 0
unique_countries = df['country_code'].nunique() if 'country_code' in df.columns else 0

# Create combined dashboard HTML
dashboard_html = f'''<!DOCTYPE html>
<html>
<head>
    <title>Student Loan Dashboard</title>
    <script src="https://cdn.plot.ly/plotly-2.27.0.min.js"></script>
    <style>
        body {{ font-family: Arial, sans-serif; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); margin: 0; padding: 20px; }}
        .container {{ max-width: 1400px; margin: 0 auto; }}
        .header {{ background: white; padding: 30px; border-radius: 15px; margin-bottom: 30px; text-align: center; }}
        .header h1 {{ margin: 0; color: #333; }}
        .metrics {{ display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 30px; }}
        .metric {{ background: white; padding: 20px; border-radius: 10px; text-align: center; }}
        .metric h3 {{ margin: 0 0 10px 0; color: #888; font-size: 14px; }}
        .metric .value {{ font-size: 28px; font-weight: bold; color: #333; }}
        .charts {{ display: grid; grid-template-columns: repeat(2, 1fr); gap: 30px; }}
        .chart {{ background: white; padding: 20px; border-radius: 10px; }}
        .chart.full-width {{ grid-column: 1 / -1; }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📊 Student Loan Portfolio Dashboard</h1>
            <p>Generated from PostgreSQL Database</p>
        </div>
        
        <div class="metrics">
            <div class="metric">
                <h3>Total Portfolio</h3>
                <div class="value">${total_amount/1e12:.2f}T</div>
            </div>
            <div class="metric">
                <h3>Total Records</h3>
                <div class="value">{total_loans}</div>
            </div>
            <div class="metric">
                <h3>Default Rate</h3>
                <div class="value">{default_rate:.1f}%</div>
            </div>
            <div class="metric">
                <h3>Countries</h3>
                <div class="value">{unique_countries}</div>
            </div>
        </div>
        
        <div class="charts">
            <div class="chart">
                <h3>Portfolio by Status</h3>
                <div id="statusChart"></div>
            </div>
            <div class="chart">
                <h3>Risk Profile</h3>
                <div id="riskChart"></div>
            </div>
            <div class="chart full-width">
                <h3>Top Countries by Portfolio Value</h3>
                <div id="countryChart"></div>
            </div>
        </div>
    </div>
    
    <script>
        // Status Pie Chart
        Plotly.newPlot('statusChart', [{values: {list(df[status_col].value_counts().tolist()) if status_col else []},
            labels: {list(df[status_col].value_counts().index) if status_col else []},
            type: 'pie', hole: 0.4}]);
        
        // Risk Chart
        Plotly.newPlot('riskChart', [{values: [{total_loans - default_count}, {default_count}],
            labels: ['Low Risk', 'High Risk'],
            type: 'pie', marker: {{'colors': ['#28a745', '#dc3545']}}}]);
        
        // Country Bar Chart
        Plotly.newPlot('countryChart', [{{'x': {list(df.groupby('country_code')[amount_col].sum().index) if amount_col and 'country_code' in df.columns else []},
            'y': {df.groupby('country_code')[amount_col].sum().tolist() if amount_col and 'country_code' in df.columns else []},
            'type': 'bar'}}]);
    </script>
</body>
</html>'''

with open('index.html', 'w', encoding='utf-8') as f:
    f.write(dashboard_html)

print("✅ Created: index.html (Combined Dashboard)")

print("\n" + "="*60)
print("🎉 Dashboard Complete!")
print("="*60)
print("\n📁 HTML files created - open any in your browser:")
print("   • index.html - Combined dashboard with all charts!")
print("   • dashboard_portfolio_by_status.html")
print("   • dashboard_loan_distribution.html")
print("   • dashboard_status_pie.html")
print("   • dashboard_loan_size.html")
print("   • dashboard_risk.html")