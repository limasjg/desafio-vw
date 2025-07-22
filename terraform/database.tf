# Grupo de subnets para o RDS.
# O RDS usa este grupo para saber em quais subnets privadas ele pode ser colocado
# para garantir alta disponibilidade.
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "sng-rds-${var.env}"
  subnet_ids = [for subnet in aws_subnet.private : subnet.id]

  tags = merge(
    local.common_tags,
    {
      Name = "sng-rds-${var.env}"
    }
  )
}

# Instância do banco de dados PostgreSQL
resource "aws_db_instance" "postgres" {

  identifier = "rds-postgres-desafio-vw-${var.env}"

  engine               = "postgres"
  engine_version       = "16.9"
  instance_class       = var.db_instance_class
  allocated_storage    = var.db_allocated_storage
  
  db_name              = "desafio_db_${var.env}" # Nome do banco de dados inicial
  username             = var.db_username
  password             = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  multi_az               = true # Habilita alta disponibilidade, criando um standby em outra AZ
  skip_final_snapshot    = true # Em 'dev' pode ser true. Em 'prd', mude para 'false'.
  
  # Habilita a proteção contra exclusão acidental. Importante para produção.
  deletion_protection    = false # Em 'prd', mude para 'true'.

  tags = merge(
    local.common_tags,
    {
      Name = "rds-postgres-desafio-vw-${var.env}"
    }
  )
}