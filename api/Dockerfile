# Estágio de build para instalar dependências
FROM python:3.9-slim as builder
WORKDIR /code
RUN pip install --no-cache-dir --upgrade pip
# Copia o requirements.txt de dentro da pasta app
COPY ./app/requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

FROM python:3.9-slim
# Define o diretório de trabalho principal
WORKDIR /code

# Copia as dependências instaladas
COPY --from=builder /root/.local /root/.local

# Copia o código da sua aplicação para DENTRO de uma pasta 'app'
COPY ./app /code/app

# Adiciona o diretório de binários do usuário ao PATH do sistema
ENV PATH=/root/.local/bin:$PATH

EXPOSE 80


CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "80"]