"""
6-digit verification code generation + hashing, and email sending via SMTP.

Reads config from environment variables (set these in .env):
  SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASSWORD, EMAIL_FROM

For Gmail: use smtp.gmail.com, port 587, and an "App Password"
(not your regular Gmail password -- see myaccount.google.com/apppasswords).
"""

import hashlib
import os
import secrets
import smtplib
from email.message import EmailMessage

from dotenv import load_dotenv

load_dotenv()

SMTP_HOST = os.getenv("SMTP_HOST", "smtp.gmail.com")
SMTP_PORT = int(os.getenv("SMTP_PORT", "587"))
SMTP_USER = os.getenv("GMAIL_USER")
SMTP_PASSWORD = os.getenv("GMAIL_APP_PASSWORD")
EMAIL_FROM = os.getenv("EMAIL_FROM", SMTP_USER)

CODE_EXPIRE_MINUTES = 15


def generate_code() -> str:
    """Random 6-digit numeric code, e.g. '042817'."""
    return f"{secrets.randbelow(1_000_000):06d}"


def hash_code(code: str) -> str:
    return hashlib.sha256(code.encode("utf-8")).hexdigest()


def send_email(to_email: str, subject: str, body: str) -> None:
    """
    Sends a plain-text email via SMTP. If SMTP isn't configured (no .env
    values set), falls back to printing the email to the console -- handy
    for local dev/testing without needing real email credentials yet.
    """
    if not SMTP_HOST or not SMTP_USER or not SMTP_PASSWORD:
        print("=" * 60)
        print("SMTP not configured -- printing email instead of sending:")
        print(f"To: {to_email}")
        print(f"Subject: {subject}")
        print(body)
        print("=" * 60)
        return

    msg = EmailMessage()
    msg["From"] = EMAIL_FROM
    msg["To"] = to_email
    msg["Subject"] = subject
    msg.set_content(body)

    with smtplib.SMTP(SMTP_HOST, SMTP_PORT) as server:
        server.starttls()
        server.login(SMTP_USER, SMTP_PASSWORD)
        server.send_message(msg)


def send_verification_code_email(to_email: str, code: str) -> None:
    send_email(
        to_email=to_email,
        subject="Your verification code",
        body=(
            f"Your verification code is: {code}\n\n"
            f"This code expires in {CODE_EXPIRE_MINUTES} minutes.\n"
            f"If you didn't request this, you can ignore this email."
        ),
    )


def send_password_reset_email(to_email: str, code: str) -> None:
    send_email(
        to_email=to_email,
        subject="Your password reset code",
        body=(
            f"Your password reset code is: {code}\n\n"
            f"This code expires in {CODE_EXPIRE_MINUTES} minutes.\n"
            f"If you didn't request this, you can ignore this email -- "
            f"your password will not be changed."
        ),
    )