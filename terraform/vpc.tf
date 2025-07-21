# Cria a VPC principal
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    local.common_tags,
    {
      Name = "vpc-desafio-vw-${var.env}"
    }
  )
}

# Cria as Subnets Públicas (uma em cada zona de disponibilidade para alta disponibilidade)
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets_cidr)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets_cidr[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true # Importante para subnets públicas

  tags = merge(
    local.common_tags,
    {
      Name = "subnet-public-${count.index + 1}-${var.env}"
    }
  )
}

# Cria as Subnets Privadas
resource "aws_subnet" "private" {
  count             = length(var.private_subnets_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets_cidr[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    local.common_tags,
    {
      Name = "subnet-private-${count.index + 1}-${var.env}"
    }
  )
}

# Data source para obter as AZs disponíveis na região
data "aws_availability_zones" "available" {
  state = "available"
}