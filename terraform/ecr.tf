resource "aws_ecr_repository" "api" {
  name                 = "ecr-desafio-vw-${var.env}"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration { scan_on_push = true }
  tags                 = local.common_tags
}
# Endpoint de Interface para a API do ECR
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids         = [for subnet in aws_subnet.private : subnet.id]
  security_group_ids = [aws_security_group.vpc_endpoints_sg.id]

  tags = merge(local.common_tags, { Name = "vpce-ecr-api-${var.env}" })
}

# Endpoint de Interface para o DKR do ECR
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids         = [for subnet in aws_subnet.private : subnet.id]
  security_group_ids = [aws_security_group.vpc_endpoints_sg.id]

  tags = merge(local.common_tags, { Name = "vpce-ecr-dkr-${var.env}" })
}