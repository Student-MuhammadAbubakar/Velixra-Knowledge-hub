from pathlib import Path
from typing import Optional
from pydantic_settings import BaseSettings, SettingsConfigDict
BASE_DIR = Path(__file__).resolve().parent.parent.parent
class Database_Settings(BaseSettings):
    POSTGRES_SERVER: Optional[str] = None
    POSTGRES_PORT: Optional[int] = None
    POSTGRES_USER: Optional[str] = None
    POSTGRES_PASSWORD: Optional[str] = None
    POSTGRES_DB: Optional[str] = None
    SECRET_KEY: Optional[str] = None
    SMTP_HOST: str
    SMTP_PORT: str
    SMTP_USERNAME: str
    SMTP_PASSWORD: str
    FROM_EMAIL: str
    model_config=SettingsConfigDict(
        env_file=BASE_DIR / ".env",
        env_ignore_empty=True,
        extra="ignore"
    )
    def Postregres_URL(self):
        return f"postgresql+asyncpg://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}@{self.POSTGRES_SERVER}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"

Settings = Database_Settings()# type: ignore[call-arg]
print(Settings.POSTGRES_USER)
print(Settings.POSTGRES_PASSWORD)
print(Settings.Postregres_URL())
