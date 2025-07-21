resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name
  # Adicione outras configurações do bucket se necessário
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  # Associa o endpoint às tabelas de rota.
  route_table_ids   = [aws_route_table.private.id, aws_route_table.public.id]

  tags = merge(
    local.common_tags,
    {
      Name = "vpce-s3-${var.env}"
    }
  )
}