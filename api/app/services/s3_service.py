import boto3
from botocore.exceptions import NoCredentialsError, ClientError
from fastapi import UploadFile
from ..config import settings
import os
from uuid import uuid4
import logging

# Crie o cliente S3 uma vez para reutilização, se possível
s3_client = boto3.client("s3", region_name=settings.AWS_REGION)

# --- FUNÇÃO DE UPLOAD ATUALIZADA ---
def upload_file_to_s3(file: UploadFile) -> str:
    """
    Faz o upload de um arquivo para o S3 e retorna a chave do objeto (nome do arquivo).
    O objeto é salvo como privado por padrão.
    """
    file_extension = os.path.splitext(file.filename)[1]
    # A chave do objeto é o caminho completo do arquivo no bucket
    object_key = f"vehicles/{uuid4()}{file_extension}"

    try:
        # Removido o ExtraArgs que tentava definir a ACL como 'public-read'
        s3_client.upload_fileobj(
            file.file,
            settings.S3_BUCKET_NAME,
            object_key
        )
        # A função agora retorna apenas a chave do objeto para ser salva no banco de dados
        return object_key
    except NoCredentialsError:
        logging.error("Credenciais da AWS não encontradas.")
        raise Exception("Credenciais da AWS não encontradas.")
    except Exception as e:
        logging.error(f"Erro durante o upload para o S3: {e}")
        raise Exception(f"Erro durante o upload para o S3: {e}")


# --- NOVA FUNÇÃO PARA GERAR URLS DE ACESSO ---
def create_presigned_url(object_key: str, expiration: int = 3600) -> str:
    """
    Gera uma URL pré-assinada para permitir o acesso temporário a um objeto privado no S3.
    """
    try:
        url = s3_client.generate_presigned_url(
            'get_object',
            Params={'Bucket': settings.S3_BUCKET_NAME, 'Key': object_key},
            ExpiresIn=expiration  # Tempo em segundos que a URL será válida (1 hora por padrão)
        )
        return url
    except ClientError as e:
        logging.error(f"Erro ao gerar URL pré-assinada: {e}")
        return None