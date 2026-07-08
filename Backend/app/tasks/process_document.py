# app/tasks/process_document.py
from app.core.database import engine
from sqlalchemy.ext.asyncio import async_sessionmaker

from app.repositories import document_repo, chunk_repo
from app.enumfile import Document_Process
from app.ai.document_process import extract_and_chunk_text
from app.ai.embedding import embed_text

# A background task runs outside the normal request/session lifecycle,
# so it needs its own session factory rather than reusing Depends(get_session).
_session_factory = async_sessionmaker(bind=engine, expire_on_commit=False)


async def process_document_task(document_id: int) -> None:
    async with _session_factory() as session:
        document = await document_repo.get_by_id(session, document_id)
        if not document:
            return

        assert document.id is not None  # narrows type from int | None to int for mypy

        try:
            await document_repo.update_process_status(session, document, Document_Process.PROCESSING)

            chunks = extract_and_chunk_text(document.file_path)

            for index, chunk_text in enumerate(chunks):
                vector = embed_text(chunk_text)
                await chunk_repo.create_chunk(
                    session,
                    document_id=document.id,
                    chunk_index=index,
                    chunk_text=chunk_text,
                    embedding=vector,
                )

            await document_repo.update_process_status(session, document, Document_Process.READY)

        except Exception as e:
            await document_repo.update_process_status(session, document, Document_Process.FAILED)
            print(f"❌ Document processing failed for document_id={document_id}: {e}")