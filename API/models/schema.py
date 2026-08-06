from pydantic import BaseModel
from typing import List


# ---------- school data ----------
class NormalAttendance(BaseModel):
    count: int
    percent: float


class AbnormalAttendance(BaseModel):
    count: int
    percent: float


class Summary(BaseModel):
    total_students: int
    change_from_last_month_percent: float
    normal_attendance: NormalAttendance
    abnormal_attendance: AbnormalAttendance


class GradeLevel(BaseModel):
    grade: str
    total: int
    normal: int
    absent: int


class MonthlyTrend(BaseModel):
    month: str
    attendance_percent: float
    absent_percent: float


class StatusEntry(BaseModel):
    count: float
    percent: float


class AttendanceStatus(BaseModel):
    on_time: StatusEntry
    late: StatusEntry
    leave: StatusEntry
    absent: StatusEntry


class GenderEntry(BaseModel):
    count: int
    percent: float


class GenderDistribution(BaseModel):
    female: GenderEntry
    male: GenderEntry


class StreamEntry(BaseModel):
    count: int
    percent: float


class StreamsBreakdown(BaseModel):
    science: StreamEntry
    social_science: StreamEntry


class SchoolDataResponse(BaseModel):
    summary: Summary
    grade_level_breakdown: List[GradeLevel]
    monthly_attendance_trend: List[MonthlyTrend]
    attendance_status: AttendanceStatus
    gender_distribution: GenderDistribution
    streams_breakdown: StreamsBreakdown