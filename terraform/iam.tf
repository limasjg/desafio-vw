# Cria a Role do instância EC2.
resource "aws_iam_role" "ec2_role" {
  name = "role-ec2-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = "role-ec2-${var.env}"
    }
  )
}

# Anexa a política gerenciada para acesso via AWS Systems Manager (boa prática).
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# --- POLÍTICA CUSTOMIZADA PARA ACESSO AO S3 ---
# Cria uma política específica que só permite ações no nosso bucket.
resource "aws_iam_policy" "s3_app_policy" {
  name        = "policy-s3-app-rw-${var.env}"
  description = "Permite leitura e escrita no bucket de imagens da aplicação"

  # Política JSON que define as permissões exatas
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowListBucket"
        Effect = "Allow"
        Action = "s3:ListBucket"
        # Permissão para listar os objetos do bucket
        Resource = aws_s3_bucket.main.arn
      },
      {
        Sid    = "AllowReadWriteDeleteObjects"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:PutObjectAcl", # Necessário se a API precisar definir imagens como públicas
          "s3:DeleteObject"
        ]
        # Permissão para manipular os OBJETOS DENTRO do bucket
        Resource = "${aws_s3_bucket.main.arn}/*" # IMPORTANTE: O "/*" no final se refere aos objetos
      }
    ]
  })
}

# Anexa a nossa nova política customizada para o S3 à Role do EC2
resource "aws_iam_role_policy_attachment" "s3_app_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_app_policy.arn
}

# Cria o "Instance Profile" que passa a Role para a instância EC2.
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "profile-ec2-${var.env}"
  role = aws_iam_role.ec2_role.name

  tags = merge(
    local.common_tags,
    {
      Name = "profile-ec2-${var.env}"
    }
  )
}