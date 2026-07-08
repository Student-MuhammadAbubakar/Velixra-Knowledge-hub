from typing import List
from sqlmodel import col
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func

from app.model import Document, QueryLog
from app.enumfile import Document_Status


async def get_document_stats(session: AsyncSession) -> dict:
    total = await session.scalar(select(func.count()).select_from(Document))
    public = await session.scalar(
        select(func.count()).select_from(Document).where(col(Document.visibility) == Document_Status.PUBLIC)
    )
    restricted = await session.scalar(
        select(func.count()).select_from(Document).where(col(Document.visibility) == Document_Status.RESTRICTED)
    )
    return {
        "total_documents": total or 0,
        "public_documents": public or 0,
        "restricted_documents": restricted or 0,
    }


async def get_recent_query_logs(session: AsyncSession, limit: int = 500) -> List[QueryLog]:
    query = (
        select(QueryLog)
        .order_by(col(QueryLog.created_at).desc())
        .limit(limit)
    )
    result = await session.execute(query)
    return list(result.scalars().all())


async def log_query(
    session: AsyncSession,
    employee_id: int,
    question: str,
    question_embedding: List[float],
    matched_chunk_ids: str,
) -> QueryLog:
    entry = QueryLog(
        employee_id=employee_id,
        question=question,
        question_embedding=question_embedding,
        matched_chunk_ids=matched_chunk_ids,
    )
    session.add(entry)
    await session.commit()
    await session.refresh(entry)
    return entry