# app/main.py
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlmodel import SQLModel

from app.core.database import engine
from app.router import auth, document, chat, analytics, team


@asynccontextmanager
async def lifespan(app: FastAPI):
    async with engine.begin() as conn:
        await conn.run_sync(SQLModel.metadata.create_all)
    print("✅ Database tables created / verified")
    yield
    await engine.dispose()
    print("✅ Server shutdown cleanly")


app = FastAPI(
    title="Velixra Knowledge Hub API",
    description="RAG-based document Q&A system for company knowledge",
    version="1.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],   # tighten to your actual Flutter app origin(s) before real deployment
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(document.router)
app.include_router(chat.router)
app.include_router(analytics.router)
app.include_router(team.router)


@app.get("/", tags=["Health"])
async def root():
    return {"status": "Velixra Knowledge Hub API running ✅", "docs": "/docs", "version": "1.0.0"}