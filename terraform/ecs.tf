resource "aws_ecs_cluster" "main" {
  name = "cluster-desafio-${var.env}"
  tags = local.common_tags
}

resource "aws_ecs_task_definition" "api" {
  family                   = "api-task-${var.env}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
    name      = "api-container"
    image     = "${aws_ecr_repository.api.repository_url}:latest"
    cpu       = 256
    memory    = 512
    essential = true
    portMappings = [{
      containerPort = 80
      hostPort      = 80
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/api-task-${var.env}"
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
      }
    }
    environment = [
      { name = "STORAGE_MODE", value = "s3" },
      { name = "S3_BUCKET_NAME", value = var.bucket_name },
      { name = "AWS_REGION", value = var.aws_region },
      { 
        name = "DATABASE_URL", 
        value = "postgresql://${var.db_username}:${var.db_password}@${aws_db_instance.postgres.address}:${aws_db_instance.postgres.port}/${aws_db_instance.postgres.db_name}?sslmode=require" 
      }
    ]
  }])
  
  tags = local.common_tags
}

resource "aws_cloudwatch_log_group" "api_logs" {
  name = "/ecs/api-task-${var.env}"
  tags = local.common_tags
}

resource "aws_ecs_service" "main" {
  name                 = "service-api-${var.env}"
  cluster              = aws_ecs_cluster.main.id
  task_definition      = aws_ecs_task_definition.api.arn
  desired_count        = 2
  launch_type          = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets          = [for subnet in aws_subnet.private : subnet.id]
    security_groups  = [aws_security_group.ec2_sg.id]
    assign_public_ip = false 
  }
  
  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = "api-container"
    container_port   = 80
  }
  
  depends_on = [aws_lb_listener.http]
  tags       = local.common_tags
}

# Define o "alvo" do auto scaling, que é o número de tarefas do seu serviço ECS
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 4  # Defina o número máximo de tarefas que o serviço pode ter
  min_capacity       = 2  # Defina o número mínimo de tarefas que o serviço deve ter
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Define a política/regra para escalar o serviço com base no uso de CPU
resource "aws_appautoscaling_policy" "ecs_cpu_scaling_policy" {
  name               = "cpu-scaling-policy-${var.env}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    # Tenta manter a utilização média de CPU do serviço em 75%
    target_value       = 75.0
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    # Tempo de espera (em segundos) antes de iniciar outra atividade de scale-out (aumentar)
    scale_out_cooldown = 60
    # Tempo de espera (em segundos) antes de iniciar outra atividade de scale-in (diminuir)
    scale_in_cooldown  = 300
  }
}