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
        print("DATABASE_URL looks malformed. It should look like:")
    except OperationalError as e:
        print(f"\nFull error:\n{e}")
    except Exception as e:
        print(f"Unexpected error: {e}")


if __name__ == "__main__":
    main()
