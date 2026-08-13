import json
from pathlib import Path

from database import SessionLocal
from models.db_models import (
    Snapshot, GradeLevelBreakdown, MonthlyAttendanceTrend,
    AttendanceStatus, GenderDistribution, StreamsBreakdown
)

JSON_PATH = Path("school_data.json")


def load_json():
    with open(JSON_PATH, "r", encoding="utf-8") as f:
        return json.load(f)


def main():
    data = load_json()
    db = SessionLocal()

    try:
        summary = data["summary"]
        snapshot = Snapshot(
            total_students=summary["total_students"],
            change_from_last_month_percent=summary["change_from_last_month_percent"],
            normal_attendance_count=summary["normal_attendance"]["count"],
            normal_attendance_percent=summary["normal_attendance"]["percent"],
            abnormal_attendance_count=summary["abnormal_attendance"]["count"],
            abnormal_attendance_percent=summary["abnormal_attendance"]["percent"],
        )
        db.add(snapshot)
        db.flush() 

        for row in data["grade_level_breakdown"]:
            db.add(GradeLevelBreakdown(
                snapshot_id=snapshot.id,
                grade=row["grade"],
                total=row["total"],
                normal=row["normal"],
            ))

        for row in data["monthly_attendance_trend"]:
            db.add(MonthlyAttendanceTrend(
                snapshot_id=snapshot.id,
                month=row["month"],
                attendance_percent=row["attendance_percent"],
            ))

        status = data["attendance_status"]
        db.add(AttendanceStatus(
            snapshot_id=snapshot.id,
            on_time_count=status["on_time"]["count"],
            late_count=status["late"]["count"],
            leave_count=status["leave"]["count"],
            absent_count=status["absent"]["count"],
        ))

        gender = data["gender_distribution"]
        db.add(GenderDistribution(
            snapshot_id=snapshot.id,
            female_count=gender["female"]["count"],
            male_count=gender["male"]["count"],
        ))

        streams = data["streams_breakdown"]
        db.add(StreamsBreakdown(
            snapshot_id=snapshot.id,
            science_count=streams["science"]["count"],
            social_science_count=streams["social_science"]["count"],
        ))

        db.commit()
        print(f"Seeded snapshot id={snapshot.id} with all breakdown tables.")

    except Exception as e:
        db.rollback()
        print(f"Seeding failed, rolled back: {e}")
        raise
    finally:
        db.close()


if __name__ == "__main__":
    main()