from fastapi import HTTPException, status, Depends
from sqlalchemy.orm import Session
from sqlalchemy import desc

from database import get_db
from models.db_models import (
    Snapshot, GradeLevelBreakdown, MonthlyAttendanceTrend,
    AttendanceStatus, GenderDistribution, StreamsBreakdown
)


def _latest_snapshot(db: Session) -> Snapshot:
    snapshot = db.query(Snapshot).order_by(desc(Snapshot.recorded_at)).first()
    if not snapshot:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No school data has been recorded yet"
        )
    return snapshot


def _serialize_summary(snapshot: Snapshot) -> dict:
    return {
        "total_students": snapshot.total_students,
        "change_from_last_month_percent": snapshot.change_from_last_month_percent,
        "normal_attendance": {
            "count": snapshot.normal_attendance_count,
            "percent": snapshot.normal_attendance_percent,
        },
        "abnormal_attendance": {
            "count": snapshot.abnormal_attendance_count,
            "percent": snapshot.abnormal_attendance_percent,
        },
    }


def _serialize_grade_levels(rows: list[GradeLevelBreakdown]) -> list[dict]:
    return [
        {"grade": r.grade, "total": r.total, "normal": r.normal, "absent": r.absent}
        for r in rows
    ]


def _serialize_monthly_trend(rows: list[MonthlyAttendanceTrend]) -> list[dict]:
    return [
        {"month": r.month, "attendance_percent": r.attendance_percent, "absent_percent": r.absent_percent}
        for r in rows
    ]


def _serialize_attendance_status(row: AttendanceStatus) -> dict:
    return {
        "on_time": {"count": row.on_time_count, "percent": row.on_time_percent},
        "late": {"count": row.late_count, "percent": row.late_percent},
        "leave": {"count": row.leave_count, "percent": row.leave_percent},
        "absent": {"count": row.absent_count, "percent": row.absent_percent},
    }


def _serialize_gender_distribution(row: GenderDistribution) -> dict:
    return {
        "female": {"count": row.female_count, "percent": row.female_percent},
        "male": {"count": row.male_count, "percent": row.male_percent},
    }


def _serialize_streams_breakdown(row: StreamsBreakdown) -> dict:
    return {
        "science": {"count": row.science_count, "percent": row.science_percent},
        "social_science": {"count": row.social_science_count, "percent": row.social_science_percent},
    }


async def get_all_school_data(db: Session = Depends(get_db)):
    snapshot = _latest_snapshot(db)
    return {
        "summary": _serialize_summary(snapshot),
        "grade_level_breakdown": _serialize_grade_levels(snapshot.grade_levels),
        "monthly_attendance_trend": _serialize_monthly_trend(snapshot.monthly_trends),
        "attendance_status": _serialize_attendance_status(snapshot.attendance_status),
        "gender_distribution": _serialize_gender_distribution(snapshot.gender_distribution),
        "streams_breakdown": _serialize_streams_breakdown(snapshot.streams_breakdown),
    }


async def get_summary(db: Session = Depends(get_db)):
    snapshot = _latest_snapshot(db)
    return _serialize_summary(snapshot)


async def get_grade_level_breakdown(db: Session = Depends(get_db)):
    snapshot = _latest_snapshot(db)
    return _serialize_grade_levels(snapshot.grade_levels)


async def get_grade_level_by_name(grade: str, db: Session = Depends(get_db)):
    snapshot = _latest_snapshot(db)
    for row in snapshot.grade_levels:
        if row.grade == grade:
            return {"grade": row.grade, "total": row.total, "normal": row.normal, "absent": row.absent}
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Grade not found")


async def get_monthly_attendance_trend(db: Session = Depends(get_db)):
    snapshot = _latest_snapshot(db)
    return _serialize_monthly_trend(snapshot.monthly_trends)


async def get_attendance_status(db: Session = Depends(get_db)):
    snapshot = _latest_snapshot(db)
    return _serialize_attendance_status(snapshot.attendance_status)


async def get_gender_distribution(db: Session = Depends(get_db)):
    snapshot = _latest_snapshot(db)
    return _serialize_gender_distribution(snapshot.gender_distribution)


async def get_streams_breakdown(db: Session = Depends(get_db)):
    snapshot = _latest_snapshot(db)
    return _serialize_streams_breakdown(snapshot.streams_breakdown)


async def update_school_data(new_data: dict, db: Session = Depends(get_db)):
    """
    Create a NEW snapshot with the given data (expects same shape as
    SchoolDataResponse in schema.py). Unlike the old JSON version, this
    does not overwrite history -- each update adds a new snapshot, so you
    keep a full timeline of past stats.
    """
    try:
        summary = new_data["summary"]
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

        for row in new_data["grade_level_breakdown"]:
            db.add(GradeLevelBreakdown(
                snapshot_id=snapshot.id,
                grade=row["grade"], total=row["total"],
                normal=row["normal"], absent=row["absent"],
            ))

        for row in new_data["monthly_attendance_trend"]:
            db.add(MonthlyAttendanceTrend(
                snapshot_id=snapshot.id,
                month=row["month"],
                attendance_percent=row["attendance_percent"],
                absent_percent=row["absent_percent"],
            ))

        status_data = new_data["attendance_status"]
        db.add(AttendanceStatus(
            snapshot_id=snapshot.id,
            on_time_count=status_data["on_time"]["count"], on_time_percent=status_data["on_time"]["percent"],
            late_count=status_data["late"]["count"], late_percent=status_data["late"]["percent"],
            leave_count=status_data["leave"]["count"], leave_percent=status_data["leave"]["percent"],
            absent_count=status_data["absent"]["count"], absent_percent=status_data["absent"]["percent"],
        ))

        gender = new_data["gender_distribution"]
        db.add(GenderDistribution(
            snapshot_id=snapshot.id,
            female_count=gender["female"]["count"], female_percent=gender["female"]["percent"],
            male_count=gender["male"]["count"], male_percent=gender["male"]["percent"],
        ))

        streams = new_data["streams_breakdown"]
        db.add(StreamsBreakdown(
            snapshot_id=snapshot.id,
            science_count=streams["science"]["count"], science_percent=streams["science"]["percent"],
            social_science_count=streams["social_science"]["count"],
            social_science_percent=streams["social_science"]["percent"],
        ))

        db.commit()
        return {"msg": "School data updated successfully", "snapshot_id": snapshot.id}

    except KeyError as err:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=f"Missing required field: {err}"
        )
    except Exception as err:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(err))