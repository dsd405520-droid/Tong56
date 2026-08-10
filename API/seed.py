"""
Seed the database using the numbers already in school_data.json.

v2: batches inserts instead of flushing per-row (the original version did
one network round-trip per student, which for ~18k students took forever
and looked "stuck"). This version builds rows in memory and flushes once
per grade instead of once per student.

Also adds --sample so you can seed a smaller, fast dataset for local
dev/testing instead of the full ~18,000 students every time.

Usage:
    python seed.py                  # full dataset (~18k students)
    python seed.py --sample 0.05    # seed ~5% of each grade, fast, for quick dev testing
"""

import argparse
import json
import random
from datetime import date
from pathlib import Path

from database import SessionLocal
from db_models import Grade, Stream, Student, AttendanceRecord

JSON_PATH = Path("school_data.json")
STREAM_START_GRADE = "ມ.4"


def load_json():
    with open(JSON_PATH, "r", encoding="utf-8") as f:
        return json.load(f)


def main(sample_fraction: float):
    data = load_json()
    db = SessionLocal()

    try:
        # ---- 1. Create streams ----
        stream_names = list(data["streams_breakdown"].keys())
        streams = {}
        for name in stream_names:
            existing = db.query(Stream).filter_by(name=name).first()
            if not existing:
                existing = Stream(name=name)
                db.add(existing)
                db.flush()
            streams[name] = existing

        female_ratio = data["gender_distribution"]["female"]["percent"] / 100
        grade_rows = data["grade_level_breakdown"]
        today = date.today()

        total_students = 0
        total_records = 0
        stream_started = False

        for row in grade_rows:
            grade_name = row["grade"]
            total = max(1, round(row["total"] * sample_fraction))
            absent = max(0, round(row["absent"] * sample_fraction))
            absent = min(absent, total)  # never exceed total after rounding

            grade = db.query(Grade).filter_by(name=grade_name).first()
            if not grade:
                grade = Grade(name=grade_name)
                db.add(grade)
                db.flush()

            if grade_name == STREAM_START_GRADE:
                stream_started = True

            absent_indexes = set(random.sample(range(total), absent)) if absent > 0 else set()

            # Build all Student objects for this grade in memory first
            students_batch = []
            for i in range(total):
                gender = "female" if random.random() < female_ratio else "male"
                stream = random.choice(list(streams.values())) if stream_started else None
                students_batch.append(Student(
                    full_name=f"Student {grade_name} #{i + 1}",
                    gender=gender,
                    grade_id=grade.id,
                    stream_id=stream.id if stream else None,
                ))

            # Bulk insert this grade's students in one round-trip, then get their IDs back
            db.add_all(students_batch)
            db.flush()

            # Now build attendance records using the IDs we just got
            records_batch = []
            for i, student in enumerate(students_batch):
                status = "absent" if i in absent_indexes else "on_time"
                records_batch.append(AttendanceRecord(
                    student_id=student.id,
                    date=today,
                    status=status,
                ))
            db.add_all(records_batch)

            total_students += len(students_batch)
            total_records += len(records_batch)
            print(f"  {grade_name}: {len(students_batch)} students queued")

        db.commit()
        print(f"✅ Seeded {total_students} students and {total_records} attendance records "
              f"for {today.isoformat()} (sample_fraction={sample_fraction}).")

    except Exception as e:
        db.rollback()
        print(f"❌ Seeding failed, rolled back: {e}")
        raise
    finally:
        db.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--sample", type=float, default=1.0,
        help="Fraction of each grade's students to seed, e.g. 0.05 for 5%%. Default 1.0 = full dataset."
    )
    args = parser.parse_args()
    main(args.sample)
