from datetime import datetime, timezone
from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import (
    hash_password,
    verify_password,
    create_access_token,
    generate_otp,
    otp_expiry,
    generate_invite_token,
    invite_expiry,
)
from app.enumfile import UserRole, Invitation_Role, Invitation_Status
from app.repositories import user_repo
from app.schemas import (
    LoginRequest,
    TokenResponse,
    ForgotPasswordRequest,
    VerifyOTPRequest,
    ResetPasswordRequest,
    InviteManagerRequest,
    InviteEmployeeRequest,
    AcceptInvitationRequest,
    UserResponse,
)
from app.services import email_service


# ---------- LOGIN ----------

async def login(session: AsyncSession, data: LoginRequest) -> TokenResponse:
    user = await user_repo.get_by_email(session, data.email)

    if not user or not verify_password(data.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
        )

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="This account has been deactivated",
        )

    token = create_access_token(user_id=user.id, role=user.role.value)
    return TokenResponse(access_token=token)


# ---------- FORGOT PASSWORD ----------

async def forgot_password(session: AsyncSession, data: ForgotPasswordRequest) -> dict:
    user = await user_repo.get_by_email(session, data.email)

    # Always return the same response whether the email exists or not —
    # this prevents attackers from using this endpoint to discover which emails are registered.
    if user:
        otp = generate_otp()
        expires = otp_expiry()
        await user_repo.set_otp(session, user, otp, expires)
        await email_service.send_otp_email(to_email=user.email, otp_code=otp)

    return {"message": "If that email is registered, an OTP has been sent."}


# ---------- VERIFY OTP ----------

async def verify_otp(session: AsyncSession, data: VerifyOTPRequest) -> dict:
    user = await user_repo.get_by_email(session, data.email)

    if not user or not user.otp_code or user.otp_code != data.otp_code:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid OTP")

    if user.otp_expires_at and user.otp_expires_at < datetime.now(timezone.utc):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="OTP has expired")

    return {"message": "OTP verified"}


# ---------- RESET PASSWORD ----------

async def reset_password(session: AsyncSession, data: ResetPasswordRequest) -> dict:
    user = await user_repo.get_by_email(session, data.email)

    if not user or not user.otp_code or user.otp_code != data.otp_code:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid OTP")

    if user.otp_expires_at and user.otp_expires_at < datetime.now(timezone.utc):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="OTP has expired")

    new_hash = hash_password(data.new_password)
    await user_repo.update_password(session, user, new_hash)

    return {"message": "Password reset successful"}


# ---------- INVITE MANAGER (owner only) ----------

async def invite_manager(session: AsyncSession, data: InviteManagerRequest, invited_by: int) -> dict:
    existing = await user_repo.get_by_email(session, data.email)
    if existing:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="This email is already registered")

    token = generate_invite_token()
    expires = invite_expiry()

    await user_repo.create_invitation(
        session,
        email=data.email,
        role=Invitation_Role.MANAGER,
        token=token,
        invited_by=invited_by,
        expires_at=expires,
    )

    await email_service.send_invite_email(to_email=data.email, token=token, role="manager")
    return {"message": f"Invitation sent to {data.email}"}


# ---------- INVITE EMPLOYEE (owner or manager) ----------

async def invite_employee(session: AsyncSession, data: InviteEmployeeRequest, invited_by: int) -> dict:
    existing = await user_repo.get_by_email(session, data.email)
    if existing:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="This email is already registered")

    token = generate_invite_token()
    expires = invite_expiry()

    await user_repo.create_invitation(
        session,
        email=data.email,
        role=Invitation_Role.EMPLOYEE,
        token=token,
        invited_by=invited_by,
        expires_at=expires,
    )

    await email_service.send_invite_email(to_email=data.email, token=token, role="employee")
    return {"message": f"Invitation sent to {data.email}"}


# ---------- ACCEPT INVITATION ----------

async def accept_invitation(session: AsyncSession, data: AcceptInvitationRequest) -> UserResponse:
    invitation = await user_repo.get_invitation_by_token(session, data.token)

    if not invitation or invitation.status != Invitation_Status.PENDING:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid or already used invitation")

    if invitation.expires_at < datetime.now(timezone.utc):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="This invitation has expired")

    password_hash = hash_password(data.password)

    role = UserRole.MANAGER if invitation.role == Invitation_Role.MANAGER else UserRole.EMPLOYEE

    user = await user_repo.create_user(
        session,
        name=data.name,
        email=invitation.email,
        password_hash=password_hash,
        role=role,
    )

    await user_repo.mark_invitation_accepted(session, invitation)

    return UserResponse.model_validate(user)