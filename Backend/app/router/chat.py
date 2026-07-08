from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_session
from app.core.dependencies import get_current_employee
from app.services import chat_service
from app.schemas import AskQuestionRequest, AskQuestionResponse, ChatSessionResponse
from app.model import User

router = APIRouter(prefix="/chat", tags=["Chat"])


@router.post("/ask", response_model=AskQuestionResponse)
async def ask_question(
    data: AskQuestionRequest,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_employee),
):
    return await chat_service.ask_question(session, data, employee_id=current_user.id)


@router.get("/sessions", response_model=list[ChatSessionResponse])
async def list_sessions(
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_employee),
):
    return await chat_service.list_sessions(session, employee_id=current_user.id)


@router.get("/sessions/{session_id}", response_model=ChatSessionResponse)
async def get_session_detail(
    session_id: int,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_employee),
):
    return await chat_service.get_session(session, session_id, employee_id=current_user.id)