resource "aws_ecr_repository" "api" {
  name                 = "ecr-desafio-vw-${var.env}"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration { scan_on_push = true }
  tags                 = local.common_tags
}