"""
Database engine and session setup.

Import `get_db` in your route/controller functions to get a DB session,
and `Base` in db_models.py so Alembic can detect your tables.
"""

import os
from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")

if not DATABASE_URL:
    raise RuntimeError(
        "DATABASE_URL not set. Check that your .env file exists and "
        "contains a valid DATABASE_URL."
    )

engine = create_engine(DATABASE_URL)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()


def get_db():
    """FastAPI dependency: yields a DB session, closes it when the request ends."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()