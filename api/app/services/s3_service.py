import boto3
from botocore.exceptions import NoCredentialsError, ClientError
from fastapi import UploadFile
from ..config import settings
import os
from uuid import uuid4
import logging


def upload_file_to_s3(file: UploadFile) -> str:

    s3_client = boto3.client("s3", region_name=settings.AWS_REGION)


    file_extension = os.path.splitext(file.filename)[1]
    object_key = f"vehicles/{uuid4()}{file_extension}"

    try:
        s3_client.upload_fileobj(
            file.file,
            settings.S3_BUCKET_NAME,
            object_key
        )
        return object_key
    except NoCredentialsError:
        logging.error("Credenciais da AWS não encontradas.")
        raise Exception("Credenciais da AWS não encontradas.")
    except Exception as e:
        logging.error(f"Erro durante o upload para o S3: {e}")
        raise Exception(f"Erro durante o upload para o S3: {e}")


def create_presigned_url(object_key: str, expiration: int = 3600) -> str:

    s3_client = boto3.client("s3", region_name=settings.AWS_REGION)

    try:
        url = s3_client.generate_presigned_url(
            'get_object',
            Params={'Bucket': settings.S3_BUCKET_NAME, 'Key': object_key},
            ExpiresIn=expiration 
        )
        return url
    except ClientError as e:
        logging.error(f"Erro ao gerar URL pré-assinada: {e}")
        return None