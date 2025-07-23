# Em tests/test_s3_utils.py

import sys
import os

# --- CORREÇÃO 1: Adicionar a pasta raiz ao path ---
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

import pytest
import boto3
from fastapi import UploadFile
import io
from moto import mock_aws
from app.services.s3_service import upload_file_to_s3, create_presigned_url
from app import config

@pytest.fixture
def aws_credentials():
    os.environ["AWS_ACCESS_KEY_ID"] = "testing"
    os.environ["AWS_SECRET_ACCESS_KEY"] = "testing"
    os.environ["AWS_SECURITY_TOKEN"] = "testing"
    os.environ["AWS_SESSION_TOKEN"] = "testing"
    # A região agora será definida pelo monkeypatch em cada teste

@mock_aws
def test_upload_file_to_s3_success(aws_credentials, monkeypatch):
    """ Testa se a função de upload funciona corretamente. """
    # --- CORREÇÃO 2: Definir as configurações para o teste ---
    monkeypatch.setattr(config.settings, "S3_BUCKET_NAME", "mock-bucket-teste")
    monkeypatch.setattr(config.settings, "AWS_REGION", "sa-east-1")

    # Arrange
    s3_client = boto3.client("s3", region_name=config.settings.AWS_REGION)
    s3_client.create_bucket(
        Bucket=config.settings.S3_BUCKET_NAME,
        CreateBucketConfiguration={'LocationConstraint': config.settings.AWS_REGION}
    )
    fake_file_content = b"arquivo de teste"
    mock_upload_file = UploadFile(filename="teste.png", file=io.BytesIO(fake_file_content))

    # Act
    object_key = upload_file_to_s3(mock_upload_file)

    # Assert
    assert object_key is not None

@mock_aws
def test_create_presigned_url(aws_credentials, monkeypatch):
    """ Testa a geração de URL pré-assinada. """
    # --- CORREÇÃO 2: Definir as configurações para o teste ---
    monkeypatch.setattr(config.settings, "S3_BUCKET_NAME", "mock-bucket-teste")
    monkeypatch.setattr(config.settings, "AWS_REGION", "sa-east-1")

    # Arrange
    s3_client = boto3.client("s3", region_name=config.settings.AWS_REGION)
    s3_client.create_bucket(
        Bucket=config.settings.S3_BUCKET_NAME,
        CreateBucketConfiguration={'LocationConstraint': config.settings.AWS_REGION}
    )
    test_key = "vehicles/imagem_teste.png"
    s3_client.put_object(Bucket=config.settings.S3_BUCKET_NAME, Key=test_key, Body=b"conteudo")

    # Act
    url = create_presigned_url(test_key)

    # Assert
    assert url is not None