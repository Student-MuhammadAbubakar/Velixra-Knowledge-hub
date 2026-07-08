from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_session
from app.core.dependencies import get_current_owner, get_current_manager_or_owner
from app.services import auth_service
from app.schemas import (
    InviteManagerRequest,
    InviteEmployeeRequest,
    AcceptInvitationRequest,
    UserResponse,
)
from app.model import User

router = APIRouter(prefix="/team", tags=["Team"])


@router.post("/invite-manager")
async def invite_manager(
    data: InviteManagerRequest,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_owner),   # owner ONLY
):
    return await auth_service.invite_manager(session, data, invited_by=current_user.id)


@router.post("/invite-employee")
async def invite_employee(
    data: InviteEmployeeRequest,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_manager_or_owner),   # owner OR manager
):
    return await auth_service.invite_employee(session, data, invited_by=current_user.id)


@router.post("/accept-invitation", response_model=UserResponse)
async def accept_invitation(
    data: AcceptInvitationRequest,
    session: AsyncSession = Depends(get_session),
):
    return await auth_service.accept_invitation(session, data)