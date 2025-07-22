# security.tf

# Security Group para as instâncias EC2 (ou Load Balancer)
# Permite acesso público nas portas HTTP (80) e HTTPS (443)
resource "aws_security_group" "ec2_sg" {
  name        = "sec-gp-ec2-${var.env}"
  description = "Permite trafego web de entrada para o EC2"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Permite todo o tráfego de saída
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "sg-ec2-${var.env}"
    }
  )
}

# Security Group para o banco de dados RDS
# Permite acesso na porta do PostgreSQL (5432) APENAS a partir do Security Group do EC2
resource "aws_security_group" "rds_sg" {
  name        = "sec-gp-rds-${var.env}"
  description = "Permite acesso ao RDS a partir do SG do EC2"
  vpc_id      = aws_vpc.main.id

  # Regra de entrada (ingress)
  ingress {
    description     = "PostgreSQL from EC2 SG"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    # A origem do tráfego é o outro security group. Esta é a configuração segura.
    security_groups = [aws_security_group.ec2_sg.id]
  }

  # Regra de saída (egress) - geralmente permite tudo para a internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "sg-rds-${var.env}"
    }
  )
}

# Regra temporária para permitir acesso ao RDS a partir do seu IP local para desenvolvimento (Ideal é adicionar a VPN)
resource "aws_security_group_rule" "local_dev_access_to_rds" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  
  # SUBSTITUA O IP ABAIXO PELO SEU IP PÚBLICO
  # Não se esqueça de adicionar o /32 no final.
  cidr_blocks       = ["177.1.32.127/32"] 
  
  security_group_id = aws_security_group.rds_sg.id
  description       = "Permite acesso do IP do desenvolvedor para o RDS"
}