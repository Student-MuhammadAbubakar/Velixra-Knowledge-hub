from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_session
from app.services import auth_service
from app.schemas import (
    LoginRequest,
    TokenResponse,
    ForgotPasswordRequest,
    VerifyOTPRequest,
    ResetPasswordRequest,
)
from app.core.dependencies import get_current_user
from app.model import User
from app.schemas import UserResponse
router = APIRouter(prefix="/auth", tags=["Auth"])


@router.post("/login", response_model=TokenResponse)
async def login(data: LoginRequest, session: AsyncSession = Depends(get_session)):
    return await auth_service.login(session, data)


@router.post("/forgot-password")
async def forgot_password(data: ForgotPasswordRequest, session: AsyncSession = Depends(get_session)):
    return await auth_service.forgot_password(session, data)


@router.post("/verify-otp")
async def verify_otp(data: VerifyOTPRequest, session: AsyncSession = Depends(get_session)):
    return await auth_service.verify_otp(session, data)


@router.post("/reset-password")
async def reset_password(data: ResetPasswordRequest, session: AsyncSession = Depends(get_session)):
    return await auth_service.reset_password(session, data)
# ... existing router code ...

@router.get("/me", response_model=UserResponse)
async def get_me(current_user: User = Depends(get_current_user)):
    return current_user