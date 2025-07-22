from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from .database import engine
from . import models
from .routers import vehicles
from .config import settings
import os

models.Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Desafio VW - API de Catálogo de Veículos",
    description="API para gerenciar o catálogo de veículos Volkswagen.",
    version="1.0.0"
)

if settings.STORAGE_MODE == "local":
    # Cria o diretório dentro do diretório de trabalho do main.py
    os.makedirs("static/images", exist_ok=True)
    app.mount("/static", StaticFiles(directory="static"), name="static")

app.include_router(vehicles.router)

@app.get("/", tags=["Root"])
def read_root():
    return {"message": f"Bem-vindo à API do Catálogo de Veículos VW! Modo de armazenamento: {settings.STORAGE_MODE}"}