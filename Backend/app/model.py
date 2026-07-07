from datetime import datetime
from typing import Optional, List
from sqlmodel import SQLModel, Field, Relationship, Column
from sqlalchemy import String
from pgvector.sqlalchemy import Vector  # type: ignore

from app.enumfile import (
    UserRole,
    Document_Process,
    Invitation_Status,
    Document_Status,
    Invitation_Role,
    MessageRole,
)

EMBEDDING_DIM = 384


class User(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str
    email: str = Field(unique=True, index=True)
    password_hash: str
    role: UserRole = Field(sa_column=Column(String))
    is_active: bool = Field(default=True)
    otp_code: Optional[str] = Field(default=None)
    otp_expires_at: Optional[datetime] = Field(default=None)
    created_at: datetime = Field(default_factory=datetime.utcnow)

    documents: List["Document"] = Relationship(back_populates="uploader")

    chat_sessions: List["ChatSession"] = Relationship(back_populates="employee")


class Invitation(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    email: str = Field(index=True)
    role: Invitation_Role = Field(sa_column=Column(String))
    status: Invitation_Status = Field(
        default=Invitation_Status.PENDING, sa_column=Column(String)
    )
    token: str = Field(unique=True, index=True)
    invited_by: int = Field(foreign_key="user.id")
    expires_at: datetime
    created_at: datetime = Field(default_factory=datetime.utcnow)


class Document(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    filename: str
    file_path: str
    uploaded_by: int = Field(foreign_key="user.id")
    visibility: Document_Status = Field(
        default=Document_Status.PUBLIC, sa_column=Column(String)
    )
    process_status: Document_Process = Field(
        default=Document_Process.PENDING, sa_column=Column(String)
    )
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    uploader: Optional["User"] = Relationship(back_populates="documents")

    chunks: List["DocumentChunk"] = Relationship(
        back_populates="document",
        sa_relationship_kwargs={"cascade": "all, delete-orphan"},
    )


class DocumentChunk(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    document_id: int = Field(foreign_key="document.id")
    chunk_index: int
    chunk_text: str
    embedding: list = Field(sa_column=Column(Vector(EMBEDDING_DIM)))
    created_at: datetime = Field(default_factory=datetime.utcnow)

    document: Optional["Document"] = Relationship(back_populates="chunks")


class ChatSession(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    employee_id: int = Field(foreign_key="user.id")  # many sessions -> one employee
    title: Optional[str] = Field(default="New Chat")
    created_at: datetime = Field(default_factory=datetime.utcnow)

    employee: Optional["User"] = Relationship(back_populates="chat_sessions")
    messages: List["ChatMessage"] = Relationship(
        back_populates="session",
        sa_relationship_kwargs={"cascade": "all, delete-orphan"},
    )


class ChatMessage(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    session_id: int = Field(foreign_key="chatsession.id")
    role: MessageRole = Field(sa_column=Column(String))
    content: str
    created_at: datetime = Field(default_factory=datetime.utcnow)

    session: Optional["ChatSession"] = Relationship(back_populates="messages")


class QueryLog(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    employee_id: int = Field(foreign_key="user.id")
    question: str
    matched_chunk_ids: Optional[str] = Field(default=None)
    created_at: datetime = Field(default_factory=datetime.utcnow)
