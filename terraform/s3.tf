
resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name
}

# Define que o dono do bucket pode gerenciar ACLs nos objetos
resource "aws_s3_bucket_ownership_controls" "main" {
  bucket = aws_s3_bucket.main.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Habilita o uso de ACLs
resource "aws_s3_bucket_acl" "main" {
  depends_on = [aws_s3_bucket_ownership_controls.main]

  bucket = aws_s3_bucket.main.id
  acl    = "private"
}

# Permite que os objetos se tornem públicos (necessário para o ACL 'public-read')
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
# resource "aws_vpc_endpoint" "s3" {
#   vpc_id            = aws_vpc.main.id
#   service_name      = "com.amazonaws.${var.aws_region}.s3"
#   vpc_endpoint_type = "Gateway"

#   # Associa o endpoint às tabelas de rota.
#   route_table_ids   = [aws_route_table.private.id, aws_route_table.public.id]

#   tags = merge(
#     local.common_tags,
#     {
#       Name = "vpce-s3-${var.env}"
#     }
#   )
# }