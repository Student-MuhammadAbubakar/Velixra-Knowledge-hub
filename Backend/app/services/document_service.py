from typing import List
from fastapi import HTTPException, status, UploadFile, BackgroundTasks
from sqlalchemy.ext.asyncio import AsyncSession

from app.repositories import document_repo
from app.utils.file_utils import save_upload_file, delete_file_from_disk
from app.enumfile import Document_Status, UserRole
from app.model import  User
from app.schemas import DocumentResponse, DocumentUpdateRequest
from app.tasks.process_document import process_document_task


async def upload_document(
    session: AsyncSession,
    file: UploadFile,
    uploaded_by: int,
    visibility: Document_Status,
    background_tasks: BackgroundTasks,
) -> DocumentResponse:
    file_path = await save_upload_file(file)

    document = await document_repo.create_document(
        session,
        filename=file.filename or "untitled",
        file_path=file_path,
        uploaded_by=uploaded_by,
        visibility=visibility,
    )

    assert document.id is not None
    background_tasks.add_task(process_document_task, document.id)

    return DocumentResponse.model_validate(document)


async def list_documents(session: AsyncSession, current_user: User) -> List[DocumentResponse]:
    if current_user.role == UserRole.EMPLOYEE:
        # Employees see every public document, company-wide — regardless
        # of which manager uploaded it (this is intentional, see Problem 3).
        documents = await document_repo.get_all(session, only_public=True)
        return [DocumentResponse.model_validate(doc) for doc in documents]

    if current_user.role == UserRole.MANAGER:
        # A manager only manages documents they personally uploaded.
        documents = await document_repo.get_all(session, uploaded_by=current_user.id)
        return [DocumentResponse.model_validate(doc) for doc in documents]

    # OWNER — sees every document across every manager, with uploader attribution.
    rows = await document_repo.get_all_with_uploader_names(session)
    results = []
    for row in rows:
        response = DocumentResponse.model_validate(row["document"])
        response.uploaded_by_name = row["uploader_name"]
        results.append(response)
    return results


async def get_document(session: AsyncSession, document_id: int) -> DocumentResponse:
    document = await document_repo.get_by_id(session, document_id)
    if not document:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Document not found")
    return DocumentResponse.model_validate(document)


async def update_document(
    session: AsyncSession,
    document_id: int,
    data: DocumentUpdateRequest,
    current_user: User,
) -> DocumentResponse:
    document = await document_repo.get_by_id(session, document_id)
    if not document:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Document not found")

    # A manager may only edit documents they uploaded themselves; the
    # owner can act on anything (enforced via the "Request change" flow instead).
    if current_user.role == UserRole.MANAGER and document.uploaded_by != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="You can only edit documents you uploaded")

    if data.visibility is not None:
        document = await document_repo.update_visibility(session, document, data.visibility)

    return DocumentResponse.model_validate(document)


async def delete_document(session: AsyncSession, document_id: int, current_user: User) -> dict:
    document = await document_repo.get_by_id(session, document_id)
    if not document:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Document not found")

    if current_user.role == UserRole.MANAGER and document.uploaded_by != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="You can only delete documents you uploaded")

    delete_file_from_disk(document.file_path)
    await document_repo.delete(session, document)

    return {"message": "Document deleted successfully"}