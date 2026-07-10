from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_session
from app.core.dependencies import get_current_owner, get_current_manager_or_owner
from app.services import auth_service
from app.schemas import (
    InviteManagerRequest,
    InviteEmployeeRequest,
    AcceptInvitationRequest,
    ManagerListItem,
    UserResponse,
)
from app.model import User
from app.schemas import  RequestChangeRequest

router = APIRouter(prefix="/team", tags=["Team"])


@router.post("/invite-manager")
async def invite_manager(
    data: InviteManagerRequest,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_owner),   # owner ONLY
):
    assert current_user.id is not None
    return await auth_service.invite_manager(session, data, invited_by=current_user.id)


@router.post("/invite-employee")
async def invite_employee(
    data: InviteEmployeeRequest,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_manager_or_owner),   # owner OR manager
):
    assert current_user.id is not None
    return await auth_service.invite_employee(session, data, invited_by=current_user.id)


@router.post("/accept-invitation", response_model=UserResponse)
async def accept_invitation(
    data: AcceptInvitationRequest,
    session: AsyncSession = Depends(get_session),
):
    return await auth_service.accept_invitation(session, data)



@router.get("/managers", response_model=list[ManagerListItem])
async def list_managers(
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_owner),
):
    return await auth_service.list_managers(session)


@router.post("/request-change")
async def request_change(
    data: RequestChangeRequest,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_owner),
):
    return await auth_service.request_manager_change(session, data)