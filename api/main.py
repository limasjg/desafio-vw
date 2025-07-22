from fastapi import FastAPI
from .database import engine
from . import models
from .routers import vehicles

# Cria as tabelas no banco de dados (se não existirem)
models.Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Desafio VW - API de Catálogo de Veículos",
    description="API para gerenciar o catálogo de veículos Volkswagen.",
    version="1.0.0"
)

# Inclui as rotas do nosso arquivo de veículos
app.include_router(vehicles.router)

@app.get("/", tags=["Root"])
def read_root():
    return {"message": "Bem-vindo à API do Catálogo de Veículos VW!"}