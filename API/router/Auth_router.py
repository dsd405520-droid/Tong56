from fastapi import APIRouter
from controllers.Auth_controller import (
    signup, verify_email, login, forgot_password, reset_password
)

router = APIRouter(prefix="/auth", tags=["Auth"])

router.post("/signup")(signup)
router.post("/verify-email")(verify_email)
router.post("/login")(login)
router.post("/forgot-password")(forgot_password)
router.post("/reset-password")(reset_password)
