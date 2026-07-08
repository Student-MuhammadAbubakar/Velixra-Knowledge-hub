import asyncio
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

from app.core.config import Settings


def _send_email_sync(to_email: str, subject: str, html_body: str) -> None:
    message = MIMEMultipart("alternative")
    message["Subject"] = subject
    message["From"] = Settings.FROM_EMAIL #type:ignore
    message["To"] = to_email

    message.attach(MIMEText(html_body, "html"))

    with smtplib.SMTP(Settings.SMTP_HOST, Settings.SMTP_PORT) as server: #type:ignore
        server.starttls()
        server.login(Settings.SMTP_USERNAME, Settings.SMTP_PASSWORD)
        server.sendmail(Settings.FROM_EMAIL, to_email, message.as_string())


async def _send_email(to_email: str, subject: str, html_body: str) -> None:
    # smtplib is blocking (synchronous), so run it in a background thread
    # to avoid freezing your async FastAPI event loop while sending.
    await asyncio.to_thread(_send_email_sync, to_email, subject, html_body)


async def send_otp_email(to_email: str, otp_code: str) -> None:
    subject = "Your Velixra Knowledge Hub Password Reset Code"
    html_body = f"""
    <p>Hello,</p>
    <p>Your one-time password reset code is:</p>
    <h2>{otp_code}</h2>
    <p>This code will expire in 10 minutes. If you did not request this, please ignore this email.</p>
    """
    await _send_email(to_email, subject, html_body)


async def send_invite_email(to_email: str, token: str, role: str) -> None:
    # Deep link that opens the Velixra Flutter app directly to the
    # accept-invitation screen, with the token pre-filled.
    invite_link = f"velixra://accept-invite?token={token}"

    subject = f"You've been invited to join Velixra Knowledge Hub as a {role.title()}"
    html_body = f"""
    <p>Hello,</p>
    <p>You have been invited to join Velixra Knowledge Hub as a <strong>{role}</strong>.</p>
    <p>Open the Velixra app and tap the link below to set up your account:</p>
    <p><a href="{invite_link}">{invite_link}</a></p>
    <p>If tapping the link doesn't open the app, open Velixra manually and enter this code on the invitation screen:</p>
    <p><strong>{token}</strong></p>
    <p>This invitation will expire in 3 days.</p>
    """
    await _send_email(to_email, subject, html_body)