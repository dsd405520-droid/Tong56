from fastapi import Depends, HTTPException, status, Request
from fastapi.security import APIKeyCookie
from sqlalchemy.orm import Session
import jwt

from database import get_db
from models.auth_models import User
from utils.auth_utils import decode_access_token

# auto_error=False so a missing cookie doesn't raise Swagger's generic 403 --
# we raise our own clearer 401 below instead. This also registers a cookie-based
# security scheme so Swagger shows the lock icon + Authorize button again.
cookie_scheme = APIKeyCookie(name="access_token", auto_error=False)


async def get_current_user(
    request: Request,
    token: str | None = Depends(cookie_scheme),
    db: Session = Depends(get_db),
) -> User:
    if not token:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Not authenticated")

    try:
        payload = decode_access_token(token)
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token expired")
    except jwt.PyJWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")

    user_id = payload.get("sub")
    user = db.query(User).filter(User.id == int(user_id)).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found")

    return user