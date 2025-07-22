from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import Optional

class Settings(BaseSettings):
    DATABASE_URL: str
    STORAGE_MODE: str # "local" or "s3"
    
    # Variáveis para o modo local
    API_BASE_URL: Optional[str] = None
    
    # Variáveis para o modo S3 (agora opcionais)
    S3_BUCKET_NAME: Optional[str] = None
    AWS_REGION: Optional[str] = None

    model_config = SettingsConfigDict(env_file=".env")

settings = Settings()