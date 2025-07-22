# Como rodar a API localmente

## Requisitos

Antes de começar, certifique-se de que você tem os seguintes itens instalados na sua máquina:

- [Git](https://git-scm.com/)
- Um editor de código, como [Visual Studio Code](https://code.visualstudio.com/) ou [IntelliJ](https://www.jetbrains.com/pt-br/idea/)
- [Docker](https://www.docker.com/) em funcionamento

## Passos para rodar a aplicação

1. No diretório onde você guarda seus projetos, clone o repositório:

   ```bash
   git clone https://github.com/limasjg/desafio-vw.git

2. Acesse a pasta da API:
    ```bash
    cd api

3. Suba os containers com o Docker Compose::
    ```bash
    docker compose up

4. Após o Docker terminar de subir os serviços, acesse no navegador:
    ```bash
    http://localhost:80/docs