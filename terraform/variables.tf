variable "bucket_name" {
  type = string
}
variable "aws_region" {
  description = "Região da AWS para deploy."
  type        = string
  default     = "us-east-1"
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