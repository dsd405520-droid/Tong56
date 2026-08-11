from datetime import datetime, timedelta, timezone

from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import desc

from database import get_db
from models.auth_models import User, VerificationCode, CodePurpose
from models.auth_schema import (
    SignupRequest, VerifyEmailRequest, LoginRequest, TokenResponse, UserOut,
    ForgotPasswordRequest, ResetPasswordRequest, MessageResponse
)
from utils.auth_utils import hash_password, verify_password, create_access_token
from utils.email_utils import (
    generate_code, hash_code, send_verification_code_email, send_password_reset_email,
    CODE_EXPIRE_MINUTES
)


def _create_and_send_code(db: Session, user: User, purpose: CodePurpose) -> None:
    code = generate_code()
    record = VerificationCode(
        user_id=user.id,
        code_hash=hash_code(code),
        purpose=purpose,
        expires_at=datetime.now(timezone.utc) + timedelta(minutes=CODE_EXPIRE_MINUTES),
    )
    db.add(record)
    db.commit()

    if purpose == CodePurpose.signup:
        send_verification_code_email(user.email, code)
    else:
        send_password_reset_email(user.email, code)


def _verify_code(db: Session, user: User, submitted_code: str, purpose: CodePurpose) -> VerificationCode:
    record = (
        db.query(VerificationCode)
        .filter(
            VerificationCode.user_id == user.id,
            VerificationCode.purpose == purpose,
            VerificationCode.used.is_(False),
        )
        .order_by(desc(VerificationCode.created_at))
        .first()
    )
    if not record:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No active code found. Request a new one.")

    if record.expires_at < datetime.now(timezone.utc):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Code has expired. Request a new one.")

    if record.code_hash != hash_code(submitted_code):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid code")

    return record


# ---------- Signup ----------

async def signup(payload: SignupRequest, db: Session = Depends(get_db)):
    existing = db.query(User).filter(User.email == payload.email).first()
    if existing:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Email already registered")

    user = User(
        email=payload.email,
        hashed_password=hash_password(payload.password),
        is_verified=False,
        is_admin=False,
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    _create_and_send_code(db, user, CodePurpose.signup)

    return MessageResponse(msg="Signup successful. Check your email for a verification code.")


async def verify_email(payload: VerifyEmailRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == payload.email).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    if user.is_verified:
        return MessageResponse(msg="Email already verified")

    record = _verify_code(db, user, payload.code, CodePurpose.signup)

    record.used = True
    user.is_verified = True
    db.commit()

    return MessageResponse(msg="Email verified successfully. You can now log in.")


# ---------- Login ----------

async def login(payload: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == payload.email).first()
    if not user or not verify_password(payload.password, user.hashed_password):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Incorrect email or password")

    if not user.is_verified:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Email not verified. Check your inbox for a verification code."
        )

    from utils.auth_utils import JWT_EXPIRE_MINUTES
    token = create_access_token(user_id=user.id, email=user.email)

    return TokenResponse(
        access_token=token,
        expires_in_minutes=JWT_EXPIRE_MINUTES,
        user=UserOut(id=user.id, email=user.email, is_admin=user.is_admin),
    )


# ---------- Forgot / reset password ----------

async def forgot_password(payload: ForgotPasswordRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == payload.email).first()
    # Always return the same message whether or not the email exists,
    # so attackers can't use this endpoint to check which emails are registered.
    if user:
        _create_and_send_code(db, user, CodePurpose.password_reset)

    return MessageResponse(msg="If that email is registered, a reset code has been sent.")


async def reset_password(payload: ResetPasswordRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == payload.email).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid email or code")

    record = _verify_code(db, user, payload.code, CodePurpose.password_reset)

    record.used = True
    user.hashed_password = hash_password(payload.new_password)
    db.commit()

    return MessageResponse(msg="Password reset successfully. You can now log in with your new password.")