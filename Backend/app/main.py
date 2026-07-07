from fastapi import FastAPI
from app.router import auth

app = FastAPI(title="Velixra Knowledge Hub")

app.include_router(auth.router)