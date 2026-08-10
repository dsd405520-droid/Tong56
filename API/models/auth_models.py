"""
Auth-related tables: users and verification codes (used for both
signup email verification and forgot-password reset codes).
"""

import enum
from sqlalchemy import (
    Column, Integer, String, Boolean, DateTime, ForeignKey, Enum, func
)
from sqlalchemy.orm import relationship

from database import Base


class CodePurpose(str, enum.Enum):
    signup = "signup"
    password_reset = "password_reset"


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True)
    email = Column(String(255), nullable=False, unique=True, index=True)
    hashed_password = Column(String(255), nullable=False)
    is_verified = Column(Boolean, nullable=False, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    verification_codes = relationship(
        "VerificationCode", back_populates="user", cascade="all, delete-orphan"
    )


class VerificationCode(Base):
    __tablename__ = "verification_codes"

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)

    code_hash = Column(String(255), nullable=False)   # never store the raw code
    purpose = Column(Enum(CodePurpose), nullable=False)
    expires_at = Column(DateTime(timezone=True), nullable=False)
    used = Column(Boolean, nullable=False, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", back_populates="verification_codes")
