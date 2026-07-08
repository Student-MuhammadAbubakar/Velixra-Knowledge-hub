from fastapi import APIRouter, Depends, UploadFile, File, Form, BackgroundTasks
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_session
from app.core.dependencies import (
    get_current_user,
    get_current_manager_or_owner,
)
from app.services import document_service
from app.schemas import DocumentResponse, DocumentUpdateRequest
from app.enumfile import Document_Status, UserRole
from app.model import User

router = APIRouter(prefix="/documents", tags=["Documents"])


@router.post("/upload", response_model=DocumentResponse)
async def upload_document(
    background_tasks: BackgroundTasks,
    file: UploadFile = File(...),
    visibility: Document_Status = Form(Document_Status.PUBLIC),
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_manager_or_owner),
):
    return await document_service.upload_document(
        session,
        file=file,
        uploaded_by=current_user.id,
        visibility=visibility,
        background_tasks=background_tasks,
    )


@router.get("", response_model=list[DocumentResponse])
async def list_documents(
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    # Employees only ever see PUBLIC documents; owner/manager see everything.
    only_public = current_user.role == UserRole.EMPLOYEE
    return await document_service.list_documents(session, only_public=only_public)


@router.get("/{document_id}", response_model=DocumentResponse)
async def get_document(
    document_id: int,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    return await document_service.get_document(session, document_id)


@router.patch("/{document_id}", response_model=DocumentResponse)
async def update_document(
    document_id: int,
    data: DocumentUpdateRequest,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_manager_or_owner),
):
    return await document_service.update_document(session, document_id, data)


@router.delete("/{document_id}")
async def delete_document(
    document_id: int,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_manager_or_owner),
):
    return await document_service.delete_document(session, document_id)