from typing import List
from sqlmodel import col
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete

from app.model import DocumentChunk, Document
from app.enumfile import Document_Status, Document_Process


async def create_chunk(
    session: AsyncSession,
    document_id: int,
    chunk_index: int,
    chunk_text: str,
    embedding: List[float],
) -> DocumentChunk:
    chunk = DocumentChunk(
        document_id=document_id,
        chunk_index=chunk_index,
        chunk_text=chunk_text,
        embedding=embedding,
    )
    session.add(chunk)
    await session.commit()
    await session.refresh(chunk)
    return chunk


async def similarity_search(
    session: AsyncSession,
    query_embedding: List[float],
    top_k: int = 5,
) -> List[DocumentChunk]:
    query = (
        select(DocumentChunk)
        .join(Document, col(DocumentChunk.document_id) == col(Document.id))
        .where(col(Document.visibility) == Document_Status.PUBLIC)
        .where(col(Document.process_status) == Document_Process.READY)
        .order_by(col(DocumentChunk.embedding).cosine_distance(query_embedding))  # type: ignore[attr-defined]
        .limit(top_k)
    )

    result = await session.execute(query)
    return list(result.scalars().all())


async def delete_chunks_for_document(session: AsyncSession, document_id: int) -> None:
    await session.execute(
        delete(DocumentChunk).where(col(DocumentChunk.document_id) == document_id)
    )
    await session.commit()