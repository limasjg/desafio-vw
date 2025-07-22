# Estágio de build para instalar dependências de forma mais eficiente
FROM python:3.9-slim as builder
WORKDIR /app
RUN pip install --no-cache-dir --upgrade pip
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir --user -r requirements.txt

# Estágio final, mais enxuto, para produção
FROM python:3.9-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY . .
# Adiciona os pacotes instalados ao PATH do sistema
ENV PATH=/root/.local/bin:$PATH

# Expõe a porta que a aplicação vai usar
EXPOSE 80

# Comando para rodar a aplicação com Uvicorn
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]