from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel, EmailStr

from app.enumfile import UserRole, Document_Status, Document_Process, MessageRole


# ---------- AUTH ----------

class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class ForgotPasswordRequest(BaseModel):
    email: EmailStr


class VerifyOTPRequest(BaseModel):
    email: EmailStr
    otp_code: str


class ResetPasswordRequest(BaseModel):
    email: EmailStr
    otp_code: str
    new_password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"


# ---------- USER ----------

class UserResponse(BaseModel):
    id: int
    name: str
    email: str
    role: UserRole
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True


# ---------- INVITATION ----------

class InviteManagerRequest(BaseModel):
    email: EmailStr


class InviteEmployeeRequest(BaseModel):
    email: EmailStr


class AcceptInvitationRequest(BaseModel):
    token: str
    name: str
    password: str


# ---------- DOCUMENT ----------

class DocumentResponse(BaseModel):
    id: int
    filename: str
    uploaded_by: int
    uploaded_by_name: Optional[str] = None  # only populated for the owner's view
    visibility: Document_Status
    process_status: Document_Process
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class DocumentUpdateRequest(BaseModel):
    visibility: Optional[Document_Status] = None


# ---------- CHAT ----------

class AskQuestionRequest(BaseModel):
    question: str
    session_id: Optional[int] = None


class ChatMessageResponse(BaseModel):
    id: int
    role: MessageRole
    content: str
    created_at: datetime

    class Config:
        from_attributes = True


class ChatSessionResponse(BaseModel):
    id: int
    title: Optional[str]
    created_at: datetime
    messages: List[ChatMessageResponse] = []

    class Config:
        from_attributes = True


class AskQuestionResponse(BaseModel):
    answer: str
    session_id: int
    source_document_ids: List[int]


# ---------- ANALYTICS ----------

class DocumentAnalytics(BaseModel):
    total_documents: int
    public_documents: int
    restricted_documents: int


class TopQuestion(BaseModel):
    question_cluster: str
    times_asked: int


class OwnerAnalyticsResponse(BaseModel):
    document_stats: DocumentAnalytics
    top_questions: List[TopQuestion]
class ManagerListItem(BaseModel):
    id: int
    name: str
    email: str

    class Config:
        from_attributes = True


class RequestChangeRequest(BaseModel):
    manager_id: int
    document_id: Optional[int] = None
    message: str