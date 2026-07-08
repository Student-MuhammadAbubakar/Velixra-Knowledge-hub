import os
import uuid
from pathlib import Path
from fastapi import UploadFile, HTTPException, status

# Folder where all uploaded documents are physically stored.
# This should NOT be inside your Postgres database — just plain disk storage.
UPLOAD_DIR = Path("uploads")
ALLOWED_EXTENSIONS = {".pdf", ".docx", ".txt"}
MAX_FILE_SIZE_MB = 20


def _ensure_upload_dir_exists() -> None:
    UPLOAD_DIR.mkdir(parents=True, exist_ok=True)


def _validate_extension(filename: str) -> str:
    ext = Path(filename).suffix.lower()
    if ext not in ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Unsupported file type '{ext}'. Allowed: {', '.join(ALLOWED_EXTENSIONS)}",
        )
    return ext


async def save_upload_file(file: UploadFile) -> str:
    _ensure_upload_dir_exists()
    ext = _validate_extension(file.filename or "")

    # Generate a unique filename so two uploads with the same original name
    # never overwrite each other on disk.
    unique_name = f"{uuid.uuid4().hex}{ext}"
    destination = UPLOAD_DIR / unique_name

    contents = await file.read()

    size_mb = len(contents) / (1024 * 1024)
    if size_mb > MAX_FILE_SIZE_MB:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"File too large ({size_mb:.1f}MB). Max allowed is {MAX_FILE_SIZE_MB}MB.",
        )

    with open(destination, "wb") as f:
        f.write(contents)

    return str(destination)


def delete_file_from_disk(file_path: str) -> None:
    try:
        os.remove(file_path)
    except FileNotFoundError:
        # File already missing — not a real error for our purposes,
        # since the end goal (file no longer existing) is already true.
        pass