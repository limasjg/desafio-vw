import boto3
from botocore.exceptions import NoCredentialsError
from fastapi import UploadFile
from ..config import settings

def upload_file_to_s3(file: UploadFile, object_name: str = None) -> str:
    """Faz upload de um arquivo para um bucket S3 e retorna a URL"""
    
    if object_name is None:
        object_name = file.filename

    s3_client = boto3.client("s3", region_name=settings.AWS_REGION)
    try:
        # ExtraArgs para tornar o objeto público
        s3_client.upload_fileobj(
            file.file, 
            settings.S3_BUCKET_NAME, 
            object_name,
            ExtraArgs={'ACL': 'public-read'}
        )
        
        url = f"https://{settings.S3_BUCKET_NAME}.s3.{settings.AWS_REGION}.amazonaws.com/{object_name}"
        return url
    except NoCredentialsError:
        return "Credenciais não encontradas."
    except Exception as e:
        return f"Erro durante o upload: {e}"