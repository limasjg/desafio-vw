# Desafio VW

Este repositório contém o código-fonte e a infraestrutura como código para a [breve descrição do projeto]. A solução foi projetada para ser escalável, resiliente e segura, utilizando as melhores práticas de desenvolvimento e DevOps na nuvem AWS.

## 🚀 Acesso Rápido

* **URL Base da API:** `alb-app-dev-2045516234.sa-east-1.elb.amazonaws.com`
* **Documentação Interativa (Swagger):** `alb-app-dev-2045516234.sa-east-1.elb.amazonaws.com/docs`

## 📖 Índice

* [Requisitos](#-requisitos)
* [Instruções de Deploy](#-instruções-de-deploy)
    * [Deploy Local com Docker](#-deploy-local-com-docker)
    * [Deploy da Infraestrutura na AWS com Terraform](#-deploy-da-infraestrutura-na-aws-com-terraform)
* [Arquitetura da Solução](#-arquitetura-da-solução)
    * [Pilares da Arquitetura](#pilares-da-arquitetura)
    * [Infraestrutura como Código (IaC)](#infraestrutura-como-código-iac)
    * [Segurança](#-segurança)
* [Pipeline de CI/CD (GitHub Actions)](#-pipeline-de-cicd-github-actions)
    * [Pipeline da Aplicação](#pipeline-da-aplicação)
    * [Pipeline da Infraestrutura (Terraform)](#pipeline-da-infraestrutura-terraform)
* [Como Executar os Testes](#-como-executar-os-testes)

## 🔧 Requisitos

Antes de começar, certifique-se de que você tem os seguintes pré-requisitos instalados e configurados em sua máquina:

* [Git](https://git-scm.com/)
* Um editor de código, como [Visual Studio Code](https://code.visualstudio.com/) ou [IntelliJ IDEA](https://www.jetbrains.com/idea/)
* [Docker](https://www.docker.com/) e [Docker Compose](https://docs.docker.com/compose/install/) em funcionamento
* [Terraform CLI](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) (v1.0 ou superior)
* [AWS CLI](https://aws.amazon.com/cli/) configurado com as credenciais de acesso à sua conta AWS.

## 🚀 Instruções de Deploy

Siga os passos abaixo para executar a aplicação localmente ou para provisionar a infraestrutura completa na AWS.

### 🐳 Deploy Local com Docker

1.  No diretório de sua preferência, clone o repositório:
    ```bash
    git clone [https://github.com/limasjg/desafio-vw.git](https://github.com/limasjg/desafio-vw.git)
    cd desafio-vw
    ```

2.  Acesse a pasta da API:
    ```bash
    cd api
    ```

3.  Construa e suba os contêineres com o Docker Compose:
    ```bash
    docker compose up --build
    ```

4.  Após a conclusão, a API estará disponível e você poderá acessar a documentação interativa (Swagger UI) no seu navegador:
    ```
    http://localhost:80/docs
    ```

### ☁️ Deploy da Infraestrutura na AWS com Terraform

O Terraform provisionará todos os recursos necessários na nuvem AWS.

1.  Navegue até o diretório da infraestrutura:
    ```bash
    cd terraform # ou o nome da pasta que contém seus arquivos .tf
    ```

2.  Inicialize o Terraform. Este comando fará o download dos providers necessários e configurará o backend remoto (se aplicável).
    ```bash
    terraform init
    ```

3.  **(Opcional, mas recomendado)** Crie um arquivo `terraform.tfvars` para definir suas variáveis (ex: `aws_region`, `project_name`, etc.) ou exporte-as como variáveis de ambiente.

4.  Gere um plano de execução para revisar os recursos que serão criados:
    ```bash
    terraform plan
    ```

5.  Após revisar o plano e confirmar que as alterações estão corretas, aplique a configuração:
    ```bash
    terraform apply
    ```
    Digite `yes` quando solicitado para confirmar a criação dos recursos.

## 🏛️ Arquitetura da Solução

A arquitetura foi desenhada para atender aos seguintes pilares:

* **Alta Disponibilidade**: Evitar pontos únicos de falha.
* **Escalabilidade Automática**: Adaptar-se dinamicamente à carga de trabalho.
* **Banco de Dados Relacional**: Persistência de dados estruturados de forma confiável.
* **Armazenamento de Arquivos**: Guardar objetos (como imagens) de forma segura e desacoplada.
* **Monitoramento**: Observabilidade completa da aplicação e infraestrutura.
* **Segurança**: Proteger os dados e o acesso em todas as camadas.

### Pilares da Arquitetura

* **Alta Disponibilidade**: A arquitetura utiliza múltiplas Zonas de Disponibilidade (Multi-AZ) para o Application Load Balancer (ALB), o serviço ECS e as Redes (Subnets). O serviço ECS é configurado para rodar com múltiplas tarefas (`desired_count` e `min_capacity`), garantindo resiliência.
* **Escalabilidade Automática**: O `aws_appautoscaling_target` e `aws_appautoscaling_policy` permitem que o serviço ECS escale horizontalmente (adicionando ou removendo tarefas) com base no uso de CPU e memória.
* **Banco de Dados Relacional**: Utiliza o Amazon RDS for PostgreSQL, um serviço gerenciado que cuida de backups, patching e alta disponibilidade (se configurado com Multi-AZ).
* **Armazenamento de Arquivos**: Um bucket Amazon S3 privado é usado para armazenar imagens de forma segura. O acesso é controlado via IAM e a API gera URLs pré-assinadas para uploads e downloads, garantindo que os arquivos não fiquem publicamente expostos.
* **Monitoramento Básico**: Os logs da aplicação são centralizados no Amazon CloudWatch, permitindo a análise e a criação de dashboards e alarmes.

### Infraestrutura como Código (IaC)

* **Provisionamento com Terraform**: Todo o ambiente é definido como código usando Terraform, de forma modular e organizada (`vpc.tf`, `security.tf`, `ecs.tf`, etc.). Isso garante consistência, reprodutibilidade e controle de versão da infraestrutura.
* **VPC com Subnets Públicas e Privadas**: A base da segurança de rede. O ALB reside na camada pública para receber tráfego da internet, enquanto os serviços críticos como ECS e RDS estão isolados na camada privada, sem acesso direto do exterior.

### 🛡️ Segurança

* **Security Groups e IAM Roles**: Aplica-se o **Princípio do Menor Privilégio**. Foram criados Security Groups específicos para cada camada (ALB, Aplicação, RDS), liberando apenas o tráfego estritamente necessário. As IAM Roles são granulares, com uma `Task Role` (permissões da aplicação, ex: acesso ao S3) separada da `Execution Role` (permissões para o ECS gerenciar a tarefa).

## ⚙️ Pipeline de CI/CD (GitHub Actions)

O projeto possui um pipeline de integração e entrega contínua que automatiza os processos de teste e deploy, tanto para a aplicação quanto para a infraestrutura.

### Pipeline da Aplicação

* **Gatilho**: O pipeline é acionado automaticamente quando uma tag no formato `v*` (ex: `v1.0.1`) é criada no repositório.
* **Processo**:
    1.  **Testes**: Executa os testes unitários com `pytest` e `moto` (para simular o S3), garantindo a qualidade do código.
    2.  **Build**: Constrói uma imagem Docker otimizada a partir de um `Dockerfile` multi-stage.
    3.  **Push**: Se os testes passarem, a imagem é enviada para o Amazon ECR (Elastic Container Registry).
    4.  **Deploy**: O workflow atualiza o serviço ECS para utilizar a nova imagem, realizando o deploy de forma automática e sem downtime (rolling update).

 * **IMPORTANTE**: Adicione as secrets no repositório.   

### Pipeline da Infraestrutura (Terraform)

* **Gatilho**: Acionado por tags no formato `v*infra` (ex: `v1.0.0-infra`).
* **Template Reutilizável**: Utiliza um workflow reutilizável, uma prática que permite padronizar o deploy de infraestrutura em múltiplos ambientes ou projetos.
* **Prevenção de Conflitos**: Implementa um sistema de lock de estado com Amazon DynamoDB, evitando que execuções concorrentes do pipeline corrompam o estado do Terraform.
* **Processo**: O pipeline executa `terraform init`, `terraform plan` e `terraform apply` de forma automatizada e segura.

 * **IMPORTANTE**: Adicione as secrets no repositório. 

## 🧪 Como Executar os Testes

Para validar o código localmente, siga os passos abaixo para rodar a suíte de testes unitários.

1.  A partir da raiz do projeto, navegue para a pasta da API:
    ```bash
    cd api
    ```

2.  É uma boa prática criar um ambiente virtual:
    ```bash
    python -m venv venv
    source venv/bin/activate  # No Windows: venv\Scripts\activate
    ```

3.  Instale as dependências de desenvolvimento:
    ```bash
    pip install -r requirements-dev.txt # ou o nome do seu arquivo de dependências de teste
    ```

4.  Execute o Pytest:
    ```bash
    pytest
    ```
    O comando encontrará e executará todos os testes definidos na pasta `tests`.
