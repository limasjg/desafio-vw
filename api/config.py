from pydantic_settings import BaseSettings, SettingsConfigDict
import os

# Define o caminho para a pasta 'api'
# api_dir = os.path.dirname(__file__)
# env_file_path = os.path.join(api_dir, '.env')

class Settings(BaseSettings):
    DATABASE_URL: str
    S3_BUCKET_NAME: str
    AWS_REGION: str

    # Diz ao Pydantic para procurar o arquivo .env dentro da pasta 'api'
    model_config = SettingsConfigDict(env_file="api/.env")

settings = Settings()