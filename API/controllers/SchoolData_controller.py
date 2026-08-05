import json
from pathlib import Path
from fastapi import HTTPException, status

DATA_FILE = Path("school_data.json")


def _read_data():
    if not DATA_FILE.exists():
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="school_data.json not found")
    try:
        with open(DATA_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    except json.JSONDecodeError as err:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail={"data error": str(err)})


def _write_data(data):
    try:
        with open(DATA_FILE, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
    except OSError as err:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail={"data error": str(err)})


async def get_all_school_data():
    return _read_data()


async def get_summary():
    data = _read_data()
    return data["summary"]


async def get_grade_level_breakdown():
    data = _read_data()
    return data["grade_level_breakdown"]


async def get_grade_level_by_name(grade: str):
    data = _read_data()
    for item in data["grade_level_breakdown"]:
        if item["grade"] == grade:
            return item
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Grade not found")


async def get_monthly_attendance_trend():
    data = _read_data()
    return data["monthly_attendance_trend"]


async def get_attendance_status():
    data = _read_data()
    return data["attendance_status"]


async def get_gender_distribution():
    data = _read_data()
    return data["gender_distribution"]


async def get_streams_breakdown():
    data = _read_data()
    return data["streams_breakdown"]


async def update_school_data(new_data: dict):
    """Overwrite the whole file with new data (expects same shape as SchoolDataResponse)."""
    _write_data(new_data)
    return {"msg": "School data updated successfully"}