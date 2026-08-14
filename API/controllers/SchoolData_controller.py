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


def _pct(part: float, total: float) -> float:
    """Safe percent helper -- avoids ZeroDivisionError on an empty snapshot."""
    return round(part / total * 100, 2) if total else 0.0


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
        {"grade": r.grade, "total": r.total, "normal": r.normal, "absent": r.total - r.normal}
        for r in rows
    ]


def _serialize_monthly_trend(rows: list[MonthlyAttendanceTrend]) -> list[dict]:
    return [
        {
            "month": r.month,
            "attendance_percent": r.attendance_percent,
            "absent_percent": round(100 - r.attendance_percent, 2),
        }
        for r in rows
    ]


def _serialize_attendance_status(row: AttendanceStatus) -> dict:
    total = row.on_time_count + row.late_count + row.leave_count + row.absent_count
    return {
        "on_time": {"count": row.on_time_count, "percent": _pct(row.on_time_count, total)},
        "late": {"count": row.late_count, "percent": _pct(row.late_count, total)},
        "leave": {"count": row.leave_count, "percent": _pct(row.leave_count, total)},
        "absent": {"count": row.absent_count, "percent": _pct(row.absent_count, total)},
    }


def _serialize_gender_distribution(row: GenderDistribution) -> dict:
    total = row.female_count + row.male_count
    return {
        "female": {"count": row.female_count, "percent": _pct(row.female_count, total)},
        "male": {"count": row.male_count, "percent": _pct(row.male_count, total)},
    }


def _serialize_streams_breakdown(row: StreamsBreakdown) -> dict:
    total = row.science_count + row.social_science_count
    return {
        "science": {"count": row.science_count, "percent": _pct(row.science_count, total)},
        "social_science": {
            "count": row.social_science_count,
            "percent": _pct(row.social_science_count, total),
        },
    }


async def get_all_school_data(db: Session = Depends(get_db)):
    try:
        snapshot = _latest_snapshot(db)
        data = {
            "summary": _serialize_summary(snapshot),
            "grade_level_breakdown": _serialize_grade_levels(snapshot.grade_levels),
            "monthly_attendance_trend": _serialize_monthly_trend(snapshot.monthly_trends),
            "attendance_status": _serialize_attendance_status(snapshot.attendance_status),
            "gender_distribution": _serialize_gender_distribution(snapshot.gender_distribution),
            "streams_breakdown": _serialize_streams_breakdown(snapshot.streams_breakdown),
        }
        return {"data": data, "msg": "School data retrieved successfully", "status": "success"}

    except HTTPException:
        raise
    except Exception as err:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(err))


async def get_summary(db: Session = Depends(get_db)):
    try:
        snapshot = _latest_snapshot(db)
        data = _serialize_summary(snapshot)
        return {"data": data, "msg": "Summary retrieved successfully", "status": "success"}

    except HTTPException:
        raise
    except Exception as err:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(err))


async def get_grade_level_breakdown(db: Session = Depends(get_db)):
    try:
        snapshot = _latest_snapshot(db)
        data = _serialize_grade_levels(snapshot.grade_levels)
        return {"data": data, "msg": "Grade level breakdown retrieved successfully", "status": "success"}

    except HTTPException:
        raise
    except Exception as err:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(err))


async def get_grade_level_by_name(grade: str, db: Session = Depends(get_db)):
    try:
        snapshot = _latest_snapshot(db)
        for row in snapshot.grade_levels:
            if row.grade == grade:
                data = {
                    "grade": row.grade,
                    "total": row.total,
                    "normal": row.normal,
                    "absent": row.total - row.normal,
                }
                return {"data": data, "msg": "Grade level retrieved successfully", "status": "success"}

        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Grade not found")

    except HTTPException:
        raise
    except Exception as err:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(err))


async def get_monthly_attendance_trend(db: Session = Depends(get_db)):
    try:
        snapshot = _latest_snapshot(db)
        data = _serialize_monthly_trend(snapshot.monthly_trends)
        return {"data": data, "msg": "Monthly attendance trend retrieved successfully", "status": "success"}

    except HTTPException:
        raise
    except Exception as err:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(err))


async def get_attendance_status(db: Session = Depends(get_db)):
    try:
        snapshot = _latest_snapshot(db)
        data = _serialize_attendance_status(snapshot.attendance_status)
        return {"data": data, "msg": "Attendance status retrieved successfully", "status": "success"}

    except HTTPException:
        raise
    except Exception as err:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(err))


async def get_gender_distribution(db: Session = Depends(get_db)):
    try:
        snapshot = _latest_snapshot(db)
        data = _serialize_gender_distribution(snapshot.gender_distribution)
        return {"data": data, "msg": "Gender distribution retrieved successfully", "status": "success"}

    except HTTPException:
        raise
    except Exception as err:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(err))


async def get_streams_breakdown(db: Session = Depends(get_db)):
    try:
        snapshot = _latest_snapshot(db)
        data = _serialize_streams_breakdown(snapshot.streams_breakdown)
        return {"data": data, "msg": "Streams breakdown retrieved successfully", "status": "success"}

    except HTTPException:
        raise
    except Exception as err:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(err))


async def update_school_data(new_data: dict, db: Session = Depends(get_db)):
    """
    Create a NEW snapshot with the given data. Unlike the old JSON version,
    this does not overwrite history -- each update adds a new snapshot, so
    you keep a full timeline of past stats.

    Only raw counts need to be supplied -- percent/absent fields are
    derived automatically on read and are ignored here even if present
    in the payload.
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
                normal=row["normal"],
            ))

        for row in new_data["monthly_attendance_trend"]:
            db.add(MonthlyAttendanceTrend(
                snapshot_id=snapshot.id,
                month=row["month"],
                attendance_percent=row["attendance_percent"],
            ))

        status_data = new_data["attendance_status"]
        db.add(AttendanceStatus(
            snapshot_id=snapshot.id,
            on_time_count=status_data["on_time"]["count"],
            late_count=status_data["late"]["count"],
            leave_count=status_data["leave"]["count"],
            absent_count=status_data["absent"]["count"],
        ))

        gender = new_data["gender_distribution"]
        db.add(GenderDistribution(
            snapshot_id=snapshot.id,
            female_count=gender["female"]["count"],
            male_count=gender["male"]["count"],
        ))

        streams = new_data["streams_breakdown"]
        db.add(StreamsBreakdown(
            snapshot_id=snapshot.id,
            science_count=streams["science"]["count"],
            social_science_count=streams["social_science"]["count"],
        ))

        db.commit()
        return {
            "data": {"snapshot_id": snapshot.id},
            "msg": "School data updated successfully",
            "status": "success",
        }

    except KeyError as err:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=f"Missing required field: {err}"
        )
    except HTTPException:
        db.rollback()
        raise
    except Exception as err:
        db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(err))