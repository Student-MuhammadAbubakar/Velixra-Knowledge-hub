from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine, async_sessionmaker #type:ignore
from app.core.config import Settings
from typing import Annotated
from fastapi import Depends

engine = create_async_engine(
    Settings.Postregres_URL(),
    echo=True,
)

# created once, reused across every request
async_session_factory = async_sessionmaker(
    bind=engine,
    expire_on_commit=False,
)

async def get_session():
    async with async_session_factory() as session:
        yield session

Session_dependency = Annotated[AsyncSession, Depends(get_session)]