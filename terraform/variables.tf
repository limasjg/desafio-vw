variable "env" {
  description = "O ambiente de deploy (ex: dev, prd)."
  type        = string
}
variable "bucket_name" {
  type = string
}
variable "aws_region" {
  description = "Região da AWS para deploy."
  type        = string
  default     = "sa-east-1"
}

variable "vpc_cidr" {
  description = "Bloco CIDR para a VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets_cidr" {
  description = "Lista de blocos CIDR para as subnets públicas."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets_cidr" {
  description = "Lista de blocos CIDR para as subnets privadas."
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

# Novas variáveis para o EC2
variable "instance_type" {
  description = "Tipo da instância EC2."
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "ID da AMI para as instâncias EC2 (Amazon Linux 2)."
  type        = string
  default     = "ami-0c55b159cbfafe1f0" # Exemplo para us-east-1, verifique a mais recente
}

# Novas variáveis para o RDS
variable "db_instance_class" {
  description = "Classe da instância do RDS."
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Armazenamento alocado para o RDS em GB."
  type        = number
  default     = 20
}

variable "db_username" {
  description = "Usuário master do banco de dados RDS."
  type        = string
  sensitive   = true # Marca como sensível para não exibir em logs
}

variable "db_password" {
  description = "Senha do usuário master do banco de dados RDS."
  type        = string
  sensitive   = true # Marca como sensível
}