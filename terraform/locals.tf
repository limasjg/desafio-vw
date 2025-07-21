locals {
  # Tags padrão que serão aplicadas em TODOS os recursos
  # Isso garante consistência e facilita o rastreamento de custos e recursos.
  common_tags = {
    Environment = var.env
    ManagedBy   = "Terraform"
    Project     = "Desafio-VW"
  }
}