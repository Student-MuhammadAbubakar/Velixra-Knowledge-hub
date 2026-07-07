# Backend/create_tables.py — run once whenever your model.py schema changes
import asyncio
from app.core.database import engine
from sqlmodel import SQLModel

# These imports are required even though they look unused —
# they register every table class with SQLModel.metadata before create_all() runs.
from app.model import (
    User,
    Invitation,
    Document,
    DocumentChunk,
    ChatSession,
    ChatMessage,
    QueryLog,
)


async def create_all():
    async with engine.begin() as conn:
        await conn.run_sync(SQLModel.metadata.create_all)
    print("✅ All tables created successfully")


asyncio.run(create_all())