from sqlalchemy import (
    Column, Integer, String, Float, ForeignKey, TIMESTAMP, func
)
from sqlalchemy.orm import relationship

from database import Base


class Snapshot(Base):
    __tablename__ = "snapshots"

    id = Column(Integer, primary_key=True)
    recorded_at = Column(TIMESTAMP, server_default=func.now(), nullable=False)

    total_students = Column(Integer, nullable=False)
    change_from_last_month_percent = Column(Float, nullable=False)
    normal_attendance_count = Column(Integer, nullable=False)
    normal_attendance_percent = Column(Float, nullable=False)
    abnormal_attendance_count = Column(Integer, nullable=False)
    abnormal_attendance_percent = Column(Float, nullable=False)

    grade_levels = relationship(
        "GradeLevelBreakdown", back_populates="snapshot", cascade="all, delete-orphan"
    )
    monthly_trends = relationship(
        "MonthlyAttendanceTrend", back_populates="snapshot", cascade="all, delete-orphan"
    )
    attendance_status = relationship(
        "AttendanceStatus", back_populates="snapshot", uselist=False, cascade="all, delete-orphan"
    )
    gender_distribution = relationship(
        "GenderDistribution", back_populates="snapshot", uselist=False, cascade="all, delete-orphan"
    )
    streams_breakdown = relationship(
        "StreamsBreakdown", back_populates="snapshot", uselist=False, cascade="all, delete-orphan"
    )


class GradeLevelBreakdown(Base):
    __tablename__ = "grade_level_breakdown"

    id = Column(Integer, primary_key=True)
    snapshot_id = Column(Integer, ForeignKey("snapshots.id", ondelete="CASCADE"), nullable=False, index=True)

    grade = Column(String(10), nullable=False)   
    total = Column(Integer, nullable=False)
    normal = Column(Integer, nullable=False)

    snapshot = relationship("Snapshot", back_populates="grade_levels")


class MonthlyAttendanceTrend(Base):
    __tablename__ = "monthly_attendance_trend"

    id = Column(Integer, primary_key=True)
    snapshot_id = Column(Integer, ForeignKey("snapshots.id", ondelete="CASCADE"), nullable=False, index=True)

    month = Column(String(20), nullable=False)
    attendance_percent = Column(Float, nullable=False)
 
    snapshot = relationship("Snapshot", back_populates="monthly_trends")


class AttendanceStatus(Base):
    __tablename__ = "attendance_status"

    id = Column(Integer, primary_key=True)
    snapshot_id = Column(
        Integer, ForeignKey("snapshots.id", ondelete="CASCADE"), nullable=False, unique=True, index=True
    )

    on_time_count = Column(Float, nullable=False)
    late_count = Column(Float, nullable=False)
    leave_count = Column(Float, nullable=False)
    absent_count = Column(Float, nullable=False)


    snapshot = relationship("Snapshot", back_populates="attendance_status")


class GenderDistribution(Base):
    __tablename__ = "gender_distribution"

    id = Column(Integer, primary_key=True)
    snapshot_id = Column(
        Integer, ForeignKey("snapshots.id", ondelete="CASCADE"), nullable=False, unique=True, index=True
    )

    female_count = Column(Integer, nullable=False)
    male_count = Column(Integer, nullable=False)
  
    snapshot = relationship("Snapshot", back_populates="gender_distribution")


class StreamsBreakdown(Base):
    __tablename__ = "streams_breakdown"

    id = Column(Integer, primary_key=True)
    snapshot_id = Column(
        Integer, ForeignKey("snapshots.id", ondelete="CASCADE"), nullable=False, unique=True, index=True
    )

    science_count = Column(Integer, nullable=False)
    social_science_count = Column(Integer, nullable=False)

    snapshot = relationship("Snapshot", back_populates="streams_breakdown")