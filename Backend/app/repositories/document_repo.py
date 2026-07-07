from typing import Optional, List
from sqlmodel import select, col
from sqlalchemy.ext.asyncio import AsyncSession

from app.model import Document
from app.enumfile import Document_Status, Document_Process


async def create_document(
    session: AsyncSession,
    filename: str,
    file_path: str,
    uploaded_by: int,
    visibility: Document_Status = Document_Status.PUBLIC,
) -> Document:
    document = Document(
        filename=filename,
        file_path=file_path,
        uploaded_by=uploaded_by,
        visibility=visibility,
        process_status=Document_Process.PENDING,
    )
    session.add(document)
    await session.commit()
    await session.refresh(document)
    return document


async def get_by_id(session: AsyncSession, document_id: int) -> Optional[Document]:
    return await session.get(Document, document_id)


async def get_all(
    session: AsyncSession,
    only_public: bool = False,
) -> List[Document]:
    query = select(Document)
    if only_public:
        query = query.where(Document.visibility == Document_Status.PUBLIC)
    query = query.order_by(col(Document.created_at).desc())

    result = await session.execute(query)
    return list(result.scalars().all())


async def update_visibility(
    session: AsyncSession,
    document: Document,
    visibility: Document_Status,
) -> Document:
    document.visibility = visibility
    session.add(document)
    await session.commit()
    await session.refresh(document)
    return document


async def update_process_status(
    session: AsyncSession,
    document: Document,
    status: Document_Process,
) -> Document:
    document.process_status = status
    session.add(document)
    await session.commit()
    await session.refresh(document)
    return document


async def delete(session: AsyncSession, document: Document) -> None:
    await session.delete(document)
    await session.commit()