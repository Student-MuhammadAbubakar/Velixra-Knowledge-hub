from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_session
from app.core.dependencies import get_current_owner
from app.services import analytics_services
from app.schemas import OwnerAnalyticsResponse
from app.model import User

router = APIRouter(prefix="/analytics", tags=["Analytics"])


@router.get("", response_model=OwnerAnalyticsResponse)
async def get_owner_analytics(
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_owner),
):
    return await analytics_services.get_owner_analytics(session)