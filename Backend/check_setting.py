# Backend/test_email.py
import asyncio
from app.services.email_service import send_otp_email

asyncio.run(send_otp_email("ranabrand6985@gmail.com", "123456"))