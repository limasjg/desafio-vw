# Role para a APLICAÇÃO (dentro do contêiner) ter permissões, como acesso ao S3
resource "aws_iam_role" "ecs_task_role" {
  name = "ecs-task-role-${var.env}"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
  tags = merge(local.common_tags, { Name = "ecs-task-role-${var.env}" })
}

# Anexa a política de acesso ao S3
resource "aws_iam_role_policy_attachment" "task_s3_policy" {
  role       = aws_iam_role.ecs_task_role.name
 
  policy_arn = aws_iam_policy.s3_app_policy.arn 
}

# Role para o AGENTE do ECS poder puxar imagens do ECR e enviar logs ao CloudWatch
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role-${var.env}"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
  tags = merge(local.common_tags, { Name = "ecs-task-execution-role-${var.env}" })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# A política de acesso ao S3.
resource "aws_iam_policy" "s3_app_policy" {
  name        = "policy-s3-app-rw-${var.env}"
  description = "Permite leitura e escrita no bucket de imagens da aplicação"
  policy      = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Sid      = "AllowListBucket",
        Effect   = "Allow",
        Action   = "s3:ListBucket",
        Resource = aws_s3_bucket.main.arn
      },
      {
        Sid      = "AllowReadWriteDeleteObjects",
        Effect   = "Allow",
        Action   = ["s3:GetObject", "s3:PutObject", "s3:PutObjectAcl", "s3:DeleteObject"],
        Resource = "${aws_s3_bucket.main.arn}/*"
      }
    ]
  })
}