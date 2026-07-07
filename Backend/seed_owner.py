# Backend/seed_owner.py — run once, then delete or keep aside, never expose via API
import asyncio
from app.core.database import engine
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker
from app.model import User
from app.enumfile import UserRole
from app.core.security import hash_password


async def seed_owner():
    async_session = async_sessionmaker(bind=engine, expire_on_commit=False)
    async with async_session() as session:
        owner = User(
            name="Rana Abubakar",                              # change to your actual name
            email="ranabrand6985@gmail.com",           # change to your actual owner login email
            password_hash=hash_password("bakar1170"),  # change this
            role=UserRole.OWNER,
            is_active=True,
        )
        session.add(owner)
        await session.commit()
        await session.refresh(owner)
        print(f"✅ Owner created: id={owner.id}, email={owner.email}")


asyncio.run(seed_owner())