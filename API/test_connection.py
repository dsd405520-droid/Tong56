"""
Quick test script to confirm your Supabase Postgres connection works.

Before running:
1. Make sure you've added DATABASE_URL to your .env file, e.g.:
   DATABASE_URL=postgresql://postgres:yourpassword@db.xxxxxxxxxxxx.supabase.co:5432/postgres

2. Install the required packages (if you haven't already):
   pip install sqlalchemy psycopg2-binary python-dotenv

3. Run this script from the same folder as your .env file:
   python test_connection.py
"""

import os
from dotenv import load_dotenv
from sqlalchemy import create_engine, text
from sqlalchemy.exc import OperationalError, ArgumentError

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")


def main():
    if not DATABASE_URL:
        print("❌ DATABASE_URL not found. Check that:")
        print("   - Your .env file is named exactly '.env' (not '.env.txt' or '_env')")
        print("   - It's in the same folder you're running this script from")
        print("   - It contains a line like: DATABASE_URL=postgresql://...")
        return

    print(f"Attempting to connect...")

    try:
        engine = create_engine(DATABASE_URL)
        with engine.connect() as conn:
            result = conn.execute(text("SELECT version();"))
            version = result.fetchone()[0]
            print("✅ Connection successful!")
            print(f"Postgres version: {version}")

            # Bonus: list existing tables (should be empty on a fresh project)
            tables_result = conn.execute(text(
                "SELECT table_name FROM information_schema.tables "
                "WHERE table_schema = 'public';"
            ))
            tables = [row[0] for row in tables_result]
            if tables:
                print(f"Existing tables in 'public' schema: {tables}")
            else:
                print("No tables yet in 'public' schema (expected on a fresh project).")

    except ArgumentError:
        print("❌ DATABASE_URL looks malformed. It should look like:")
        print("   postgresql://postgres:yourpassword@db.xxxxxxxxxxxx.supabase.co:5432/postgres")
    except OperationalError as e:
        print("❌ Could not connect to the database. Common causes:")
        print("   - Wrong password in the connection string")
        print("   - Typo in the host (db.xxxxxxxxxxxx.supabase.co)")
        print("   - Project still provisioning (wait a minute and retry)")
        print(f"\nFull error:\n{e}")
    except Exception as e:
        print(f"❌ Unexpected error: {e}")


if __name__ == "__main__":
    main()
