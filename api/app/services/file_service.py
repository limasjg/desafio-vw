import shutil
from fastapi import UploadFile
from ..config import settings
import os
from uuid import uuid4

def save_upload_file(file: UploadFile) -> str:
    try:
        file_extension = os.path.splitext(file.filename)[1]
        unique_filename = f"{uuid4()}{file_extension}"
        file_path = f"static/images/{unique_filename}"
        
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
            
        return f"{settings.API_BASE_URL}/{file_path}"
    except Exception as e:
        raise Exception(f"Erro durante o salvamento do arquivo local: {e}")