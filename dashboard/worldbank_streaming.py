"""
================================================================================
WORLD BANK DATA - STREAMING PROCESSING (3.5 GB File)
================================================================================

WHAT IS STREAMING?
------------------
Normal way:   Load entire 3.5GB file → RAM explodes → Computer crashes
Streaming:    Read 100 records → Process → Save → Read next 100 → Repeat

WHY STREAMING?
--------------
Your JSON file is 3.5 GB. Most computers have 8-16 GB RAM.
Loading it all at once would use ALL your memory + crash.
Streaming uses only ~50 MB RAM at any time.

FILE STRUCTURE:
---------------
The JSON file is an array of country objects:
[
  {
    "Country Name": "United States",
    "Country Code": "USA",
    "Indicators": [
      {"Year": "1960", "Indicator Value for Year": "12345"},
      {"Year": "1961", "Indicator Value for Year": "12390"},
      ... (many years)
    ]
  },
  ... (many countries)
]
================================================================================
"""

import json
import pandas as pd
import sqlite3
import os
from datetime import datetime

# ============================================================================
# CONFIGURATION
# ============================================================================

DATA_FILE = 'world_bank_data.json'   # Your 3.5 GB file
DB_FILE = 'world_bank.db'            # Output database
CHUNK_SIZE = 100                     # Process 100 countries at a time
MAX_RECORDS = 500                    # Safety limit (set to None for all)

print("="*70)
print("🌍 WORLD BANK DATA - STREAMING PROCESSING")
print("="*70)

# ============================================================================
# STEP 1: STREAMING JSON READER
# ============================================================================

def stream_json_records(file_path):
    """
    STREAMING GENERATOR - The key to handling large files
    
    WHAT IS A GENERATOR?
    --------------------
    Normal function: Returns ALL data at once → uses lots of memory
    Generator:       Returns ONE item at a time → very little memory
    
    The 'yield' keyword makes this a generator.
    Each time you call it, it gives you the NEXT record.
    
    EXAMPLE:
    --------
    for record in stream_json_records('file.json'):
        print(record)  # Only this ONE record is in memory!
    """
    
    print(f"\n📂 File: {file_path}")
    print(f"📊 Size: {os.path.getsize(file_path) / (1024**3):.2f} GB")
    print(f"💡 Strategy: Streaming (low memory usage)")
    
    # Open file in streaming mode (doesn't load whole file)
    with open(file_path, 'r', encoding='utf-8') as f:
        
        # JSON arrays start with '[' - skip it
        f.read(1)
        
        # Variables to track parsing
        buffer = ""           # Characters we've read
        brace_count = 0       # Track nested braces { }
        in_string = False     # Track if we're inside "quotes"
        
        # Read file ONE CHARACTER at a time
        while True:
            char = f.read(1)  # Read single character
            
            if not char:      # End of file
                break
            
            buffer += char
            
            # Handle quotes (but not escaped quotes like \")
            if char == '"' and (len(buffer) < 2 or buffer[-2] != '\\'):
                in_string = not in_string
            
            # Only count braces when NOT inside a string
            elif not in_string:
                if char == '{':
                    brace_count += 1
                elif char == '}':
                    brace_count -= 1
                    
                    # If brace_count returns to 0, we found a complete object
                    if brace_count == 0:
                        try:
                            # Parse the JSON object
                            record = json.loads(buffer.strip().rstrip(','))
                            yield record  # Return this ONE record
                            buffer = ""   # Clear buffer for next object
                        except json.JSONDecodeError:
                            # Skip malformed JSON
                            pass


# ============================================================================
# STEP 2: PROCESS DATA IN CHUNKS
# ============================================================================

def process_worldbank_data():
    """
    Main processing function
    
    CHUNKING STRATEGY:
    ------------------
    Instead of loading all 3.5 GB:
    1. Read 100 countries
    2. Transform to flat table format
    3. Save to database
    4. Delete from memory
    5. Read next 100 countries
    6. Repeat
    
    MEMORY FLOW:
    ------------
    [Read 100 records] → [Transform] → [Save to DB] → [Clear memory]
           ↑                                                    ↓
           └──────────────────[Repeat]────────────────────────┘
    
    Result: Only ~50 MB used at any time instead of 3.5 GB!
    """
    
    print("\n" + "="*70)
    print("📥 STEP 1: EXTRACTION & CHUNKING")
    print("="*70)
    
    # Statistics tracking
    stats = {
        'total_countries': 0,
        'total_indicators': 0,
        'chunks_processed': 0,
        'start_time': datetime.now()
    }
    
    # Current chunk being built
    current_chunk = []
    
    # Setup database
    conn = sqlite3.connect(DB_FILE)
    
    # Create table (will be overwritten each chunk)
    conn.execute('''
        CREATE TABLE IF NOT EXISTS world_indicators (
            country_name TEXT,
            country_code TEXT,
            indicator_name TEXT,
            year INTEGER,
            value REAL
        )
    ''')
    
    # Clear old data
    conn.execute("DELETE FROM world_indicators")
    conn.commit()
    
    print("\n🔄 Processing records in chunks...")
    print("-" * 50)
    
    # Process streaming records
    for country_record in stream_json_records(DATA_FILE):
        
        # Add to current chunk
        current_chunk.append(country_record)
        stats['total_countries'] += 1
        
        # When chunk is full, process it
        if len(current_chunk) >= CHUNK_SIZE:
            process_chunk(current_chunk, conn, stats)
            current_chunk = []  # Clear chunk from memory
            stats['chunks_processed'] += 1
            
            # Progress update
            elapsed = (datetime.now() - stats['start_time']).seconds
            print(f"   ⏳ Countries: {stats['total_countries']} | "
                  f"Chunks: {stats['chunks_processed']} | "
                  f"Time: {elapsed}s", end='\r')
        
        # Safety limit (remove this line to process all data)
        if MAX_RECORDS and stats['total_countries'] >= MAX_RECORDS:
            print(f"\n   ⚠️  Reached limit of {MAX_RECORDS} records")
            break
    
    # Process any remaining records in final chunk
    if current_chunk:
        process_chunk(current_chunk, conn, stats)
        stats['chunks_processed'] += 1
    
    conn.close()
    
    # Final report
    elapsed = (datetime.now() - stats['start_time']).seconds
    print(f"\n\n{'='*70}")
    print("✅ PROCESSING COMPLETE")
    print(f"{'='*70}")
    print(f"📊 Total countries processed: {stats['total_countries']}")
    print(f"📊 Total indicator records: {stats['total_indicators']}")
    print(f"📊 Chunks processed: {stats['chunks_processed']}")
    print(f"⏱️  Time elapsed: {elapsed} seconds")
    print(f"💾 Database: {DB_FILE}")


def process_chunk(chunk, conn, stats):
    """
    Transform and save one chunk of data
    
    FLATTENING DATA:
    ----------------
    Input (nested):
    {
      "Country Name": "USA",
      "Indicators": [
        {"Year": "1960", "Indicator Value": "100"},
        {"Year": "1961", "Indicator Value": "105"}
      ]
    }
    
    Output (flat table):
    | Country | Year | Value |
    |---------|------|-------|
    | USA     | 1960 | 100   |
    | USA     | 1961 | 105   |
    
    Flat tables are easier to query and analyze!
    """
    
    rows = []
    
    for country in chunk:
        country_name = country.get('Country Name', 'Unknown')
        country_code = country.get('Country Code', 'Unknown')
        
        # Get all indicators for this country
        indicators = country.get('Indicators', [])
        
        for indicator in indicators:
            # Extract year and value
            year_str = indicator.get('Year', '')
            value_str = indicator.get('Indicator Value for Year', '')
            
            # Skip if missing data
            if not year_str or not value_str:
                continue
            
            # Convert to proper types
            try:
                year = int(year_str)
                value = float(value_str)
            except (ValueError, TypeError):
                continue  # Skip invalid values
            
            # Create flat row
            rows.append({
                'country_name': country_name,
                'country_code': country_code,
                'year': year,
                'value': value
            })
            
            stats['total_indicators'] += 1
    
    # Convert to DataFrame and save to database
    if rows:
        df = pd.DataFrame(rows)
        df.to_sql('world_indicators', conn, if_exists='append', index=False)


# ============================================================================
# STEP 3: VERIFY RESULTS
# ============================================================================

def verify_results():
    """
    Quick verification of processed data
    """
    print(f"\n{'='*70}")
    print("🔍 STEP 2: VERIFICATION")
    print(f"{'='*70}")
    
    conn = sqlite3.connect(DB_FILE)
    
    # Count total rows
    cursor = conn.execute("SELECT COUNT(*) FROM world_indicators")
    total_rows = cursor.fetchone()[0]
    print(f"📊 Total rows in database: {total_rows:,}")
    
    # Count unique countries
    cursor = conn.execute("SELECT COUNT(DISTINCT country_name) FROM world_indicators")
    unique_countries = cursor.fetchone()[0]
    print(f"📊 Unique countries: {unique_countries}")
    
    # Year range
    cursor = conn.execute("SELECT MIN(year), MAX(year) FROM world_indicators")
    min_year, max_year = cursor.fetchone()
    print(f"📊 Year range: {min_year} - {max_year}")
    
    # Sample data
    print(f"\n📋 Sample records:")
    df = pd.read_sql("SELECT * FROM world_indicators LIMIT 5", conn)
    print(df.to_string())
    
    conn.close()


# ============================================================================
# MAIN EXECUTION
# ============================================================================

if __name__ == "__main__":
    # Step 1: Process data
    process_worldbank_data()
    
    # Step 2: Verify results
    verify_results()
    
    print(f"\n{'='*70}")
    print("🎉 ALL DONE!")
    print(f"{'='*70}")
    print("\nNext steps:")
    print("   1. Check world_bank.db for processed data")
    print("   2. Run analysis queries")
    print("   3. Create visualizations")
