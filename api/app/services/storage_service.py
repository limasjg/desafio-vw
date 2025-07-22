from fastapi import UploadFile
from ..config import settings
from . import file_service, s3_service

def save_file(file: UploadFile) -> str:
    if settings.STORAGE_MODE == "local":
        return file_service.save_upload_file(file)
    elif settings.STORAGE_MODE == "s3":
        if not all([settings.S3_BUCKET_NAME, settings.AWS_REGION]):
            raise ValueError("S3_BUCKET_NAME e AWS_REGION são necessários para o modo de armazenamento S3.")
        return s3_service.upload_file_to_s3(file)
    else:
        raise ValueError("Modo de armazenamento (STORAGE_MODE) inválido. Use 'local' ou 's3'.")