"""
SQLAlchemy models for the school attendance dashboard.

Schema:
  grades              - reference table (ມ.1 ... ມ.7)
  streams             - reference table (science, social_science)
  students            - one row per student, linked to a grade and (optionally) a stream
  attendance_records  - one row per student per day, with a status
"""

from sqlalchemy import (
    Column, Integer, String, Date, ForeignKey, UniqueConstraint, CheckConstraint,
    TIMESTAMP, func
)
from sqlalchemy.orm import relationship

from database import Base


class Grade(Base):
    __tablename__ = "grades"

    id = Column(Integer, primary_key=True)
    name = Column(String(10), nullable=False, unique=True)  # e.g. 'ມ.1'

    students = relationship("Student", back_populates="grade")


class Stream(Base):
    __tablename__ = "streams"

    id = Column(Integer, primary_key=True)
    name = Column(String(20), nullable=False, unique=True)  # 'science' | 'social_science'

    students = relationship("Student", back_populates="stream")


class Student(Base):
    __tablename__ = "students"

    id = Column(Integer, primary_key=True)
    full_name = Column(String(100), nullable=False)
    gender = Column(String(10), nullable=False)
    grade_id = Column(Integer, ForeignKey("grades.id"), nullable=False, index=True)
    stream_id = Column(Integer, ForeignKey("streams.id"), nullable=True, index=True)
    created_at = Column(TIMESTAMP, server_default=func.now())

    grade = relationship("Grade", back_populates="students")
    stream = relationship("Stream", back_populates="students")
    attendance_records = relationship(
        "AttendanceRecord", back_populates="student", cascade="all, delete-orphan"
    )

    __table_args__ = (
        CheckConstraint("gender IN ('male', 'female')", name="ck_students_gender"),
    )


class AttendanceRecord(Base):
    __tablename__ = "attendance_records"

    id = Column(Integer, primary_key=True)
    student_id = Column(Integer, ForeignKey("students.id", ondelete="CASCADE"), nullable=False, index=True)
    date = Column(Date, nullable=False, index=True)
    status = Column(String(10), nullable=False)  # 'on_time' | 'late' | 'leave' | 'absent'

    student = relationship("Student", back_populates="attendance_records")

    __table_args__ = (
        UniqueConstraint("student_id", "date", name="uq_attendance_student_date"),
        CheckConstraint(
            "status IN ('on_time', 'late', 'leave', 'absent')",
            name="ck_attendance_status"
        ),
    )
