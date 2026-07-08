from langchain_groq import ChatGroq
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser

from app.core.config import Settings

# Built ONCE at import time — same "build once, reuse many times" principle
# as your database engine and embedding model. Creating this per-request
# would be wasteful and slower.
_llm = ChatGroq(
    api_key=Settings.GROQ_API_KEY,#type:ignore
    model="llama-3.3-70b-versatile",
    temperature=0.2,
)

_prompt = ChatPromptTemplate.from_messages([
    ("system",
     "You are a helpful assistant answering employee questions using ONLY the "
     "company documents provided below. If the answer is not contained in the "
     "provided context, say clearly that you don't have that information — "
     "do not make anything up.\n\nContext:\n{context}"),
    ("human", "{question}"),
])

_chain = _prompt | _llm | StrOutputParser()


async def generate_answer(question: str, context_chunks: list[str]) -> str:
    """
    Takes a question and a list of retrieved chunk texts, and returns
    the LLM's final natural-language answer, grounded in that context.
    """
    context = "\n\n---\n\n".join(context_chunks)
    answer = await _chain.ainvoke({"context": context, "question": question})
    return answer