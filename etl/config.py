"""
Configuration module for database connections and paths
Uses python-dotenv to load credentials from .env file
"""

import os
from dotenv import load_dotenv
from sqlalchemy import create_engine

# Load environment variables from .env file
load_dotenv()

# Database Configuration
DATABASE_URL = os.getenv('DATABASE_URL')
DB_HOST = os.getenv('DB_HOST')
DB_NAME = os.getenv('DB_NAME')
DB_USER = os.getenv('DB_USER')
DB_PASSWORD = os.getenv('DB_PASSWORD')
DB_PORT = os.getenv('DB_PORT', '5432')

# Data Files
STUDENT_LOAN_FILE = 'PortfoliobyLoanStatus.xls'
WORLDBANK_FILE = 'world_bank_data.json'

# Chunk sizes for memory efficiency
CHUNK_SIZE = 10000  # For database inserts
STREAM_CHUNK = 100  # For JSON streaming

def get_engine():
    """Create SQLAlchemy engine for Neon PostgreSQL"""
    if DATABASE_URL:
        # Use full URL if available
        engine = create_engine(
            DATABASE_URL,
            pool_pre_ping=True,
            pool_recycle=300,
        )
    else:
        # Build URL from components
        connection_string = f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}?sslmode=require"
        engine = create_engine(
            connection_string,
            pool_pre_ping=True,
            pool_recycle=300,
        )
    return engine

def test_connection():
    """Test database connectivity"""
    try:
        engine = get_engine()
        with engine.connect() as conn:
            result = conn.execute("SELECT version();")
            version = result.fetchone()[0]
            return True, version
    except Exception as e:
        return False, str(e)

if __name__ == "__main__":
    print("Testing database connection...")
    success, message = test_connection()
    if success:
        print(f"✅ Connected to Neon PostgreSQL")
        print(f"   Version: {message}")
    else:
        print(f"❌ Connection failed: {message}")
