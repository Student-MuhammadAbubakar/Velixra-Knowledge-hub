from typing import List
from fastapi import HTTPException, status

from sqlalchemy.ext.asyncio import AsyncSession

from app.repositories import chat_repo, chunk_repo, analytic_repo
from app.ai.embedding import embed_text
from app.ai.rag_pipeline import generate_answer
from app.enumfile import MessageRole
from app.schemas import AskQuestionRequest, AskQuestionResponse, ChatSessionResponse


async def ask_question(
    session: AsyncSession,
    data: AskQuestionRequest,
    employee_id: int,
) -> AskQuestionResponse:
    # Step 1: figure out which conversation this belongs to
    if data.session_id is None:
        title = data.question[:50] + ("..." if len(data.question) > 50 else "")
        chat_session = await chat_repo.create_session(session, employee_id=employee_id, title=title)
    else:
        fetched_session = await chat_repo.get_session_by_id(session, data.session_id)
        if not fetched_session:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Chat session not found")
        if fetched_session.employee_id != employee_id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="This chat session does not belong to you")
        chat_session = fetched_session

    assert chat_session.id is not None

    # Step 2: retrieve relevant document chunks
    query_vector = embed_text(data.question)
    matched_chunks = await chunk_repo.similarity_search(session, query_vector, top_k=5)

    if not matched_chunks:
        answer_text = "I don't have any relevant information in the available documents to answer that."
        source_ids: List[int] = []
    else:
        chunk_texts = [chunk.chunk_text for chunk in matched_chunks]
        answer_text = await generate_answer(data.question, chunk_texts)
        source_ids = list({chunk.document_id for chunk in matched_chunks})

    # Step 3: persist both sides of the conversation
    await chat_repo.add_message(session, chat_session.id, MessageRole.USER, data.question)
    await chat_repo.add_message(session, chat_session.id, MessageRole.ASSISTANT, answer_text)

    # Step 4: log this question for owner analytics (most-asked-questions clustering)
    matched_ids_str = ",".join(str(c.document_id) for c in matched_chunks) if matched_chunks else ""
    await analytic_repo.log_query(
        session,
        employee_id=employee_id,
        question=data.question,
        question_embedding=query_vector,
        matched_chunk_ids=matched_ids_str,
    )

    return AskQuestionResponse(
        answer=answer_text,
        session_id=chat_session.id,
        source_document_ids=source_ids,
    )


async def list_sessions(session: AsyncSession, employee_id: int) -> List[ChatSessionResponse]:
    sessions = await chat_repo.get_sessions_for_employee(session, employee_id)
    return [ChatSessionResponse.model_validate(s) for s in sessions]


async def get_session(session: AsyncSession, session_id: int, employee_id: int) -> ChatSessionResponse:
    chat_session = await chat_repo.get_session_by_id(session, session_id)
    if not chat_session:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Chat session not found")
    if chat_session.employee_id != employee_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="This chat session does not belong to you")
    return ChatSessionResponse.model_validate(chat_session)