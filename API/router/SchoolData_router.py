from fastapi import APIRouter
from controllers.SchoolData_controller import (
    get_all_school_data, get_summary, get_grade_level_breakdown, get_grade_level_by_name,
    get_monthly_attendance_trend, get_attendance_status, get_gender_distribution,
    get_streams_breakdown, update_school_data
)

router = APIRouter(prefix="/schooldata", tags=["SchoolData"])

router.get("/all")(get_all_school_data)
router.get("/summary")(get_summary)
router.get("/grade-level")(get_grade_level_breakdown)
router.get("/grade-level/{grade}")(get_grade_level_by_name)
router.get("/monthly-trend")(get_monthly_attendance_trend)
router.get("/attendance-status")(get_attendance_status)
router.get("/gender-distribution")(get_gender_distribution)
router.get("/streams-breakdown")(get_streams_breakdown)
router.put("/update")(update_school_data)