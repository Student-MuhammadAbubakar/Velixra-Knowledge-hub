from typing import Optional
from datetime import datetime
from sqlmodel import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.enumfile import Invitation_Status
from model import User, Invitation



async def get_by_email(session: AsyncSession, email: str) -> Optional[User]:
    result = await session.execute(select(User).where(User.email == email))
    return result.scalars().first()


async def get_by_id(session: AsyncSession, user_id: int) -> Optional[User]:
    return await session.get(User, user_id)


async def create_user(
    session: AsyncSession,
    name: str,
    email: str,
    password_hash: str,
    role: str,
) -> User:
    user = User(
        name=name,
        email=email,
        password_hash=password_hash,
        role=role,
    )
    session.add(user)
    await session.commit()
    await session.refresh(user)
    return user


async def update_password(session: AsyncSession, user: User, new_password_hash: str) -> User:
    user.password_hash = new_password_hash
    user.otp_code = None
    user.otp_expires_at = None
    session.add(user)
    await session.commit()
    await session.refresh(user)
    return user


async def set_otp(session: AsyncSession, user: User, otp_code: str, expires_at: datetime) -> User:
    user.otp_code = otp_code
    user.otp_expires_at = expires_at
    session.add(user)
    await session.commit()
    await session.refresh(user)
    return user
async def create_invitation(
    session: AsyncSession,
    email: str,
    role: str,
    token: str,
    invited_by: int,
    expires_at: datetime,
) -> Invitation:
    invitation = Invitation(
        email=email,
        role=role,
        token=token,
        invited_by=invited_by,
        expires_at=expires_at,
    )
    session.add(invitation)
    await session.commit()
    await session.refresh(invitation)
    return invitation


async def get_invitation_by_token(session: AsyncSession, token: str) -> Optional[Invitation]:
    result = await session.execute(select(Invitation).where(Invitation.token == token))
    return result.scalars().first()


async def mark_invitation_accepted(session: AsyncSession, invitation: Invitation) -> Invitation:
    invitation.status = Invitation_Status.ACCEPTED
    session.add(invitation)
    await session.commit()
    await session.refresh(invitation)
    return invitation