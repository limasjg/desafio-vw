import boto3
from botocore.exceptions import NoCredentialsError
from fastapi import UploadFile
from ..config import settings # <-- Correção aqui
import os
from uuid import uuid4

def upload_file_to_s3(file: UploadFile) -> str:
    file_extension = os.path.splitext(file.filename)[1]
    unique_filename = f"vehicles/{uuid4()}{file_extension}"

    s3_client = boto3.client("s3", region_name=settings.AWS_REGION)
    try:
        s3_client.upload_fileobj(
            file.file, 
            settings.S3_BUCKET_NAME, 
            unique_filename,
            ExtraArgs={'ACL': 'public-read'}
        )
        url = f"https://{settings.S3_BUCKET_NAME}.s3.{settings.AWS_REGION}.amazonaws.com/{unique_filename}"
        return url
    except NoCredentialsError:
        raise Exception("Credenciais da AWS não encontradas. Configure-as no ambiente.")
    except Exception as e:
        raise Exception(f"Erro durante o upload para o S3: {e}")