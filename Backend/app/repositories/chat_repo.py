from typing import Optional, List
from sqlmodel import col
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from sqlalchemy.orm import selectinload

from app.model import ChatSession, ChatMessage
from app.enumfile import MessageRole


async def create_session(
    session: AsyncSession,
    employee_id: int,
    title: str = "New Chat",
) -> ChatSession:
    chat_session = ChatSession(employee_id=employee_id, title=title)
    session.add(chat_session)
    await session.commit()
    await session.refresh(chat_session)
    return chat_session


async def get_session_by_id(
    session: AsyncSession,
    session_id: int,
) -> Optional[ChatSession]:
    query = (
        select(ChatSession)
        .where(col(ChatSession.id) == session_id)
        .options(selectinload(ChatSession.messages))  # type: ignore[arg-type]
    )
    result = await session.execute(query)
    return result.scalars().first()


async def get_sessions_for_employee(
    session: AsyncSession,
    employee_id: int,
) -> List[ChatSession]:
    query = (
        select(ChatSession)
        .where(col(ChatSession.employee_id) == employee_id)
        .order_by(col(ChatSession.created_at).desc())
        .options(selectinload(ChatSession.messages))  # type: ignore[arg-type]
    )
    result = await session.execute(query)
    return list(result.scalars().all())


async def add_message(
    session: AsyncSession,
    session_id: int,
    role: MessageRole,
    content: str,
) -> ChatMessage:
    message = ChatMessage(session_id=session_id, role=role, content=content)
    session.add(message)
    await session.commit()
    await session.refresh(message)
    return message