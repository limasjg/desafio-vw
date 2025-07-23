resource "aws_sns_topic" "alarms_topic" {
  name = "alarms-topic-${var.env}"
  tags = local.common_tags
}
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.alarms_topic.arn
  protocol  = "email"
  # ** Meu email para testes, porém idealmente o contato do time de sustentação **
  endpoint  = "joaoguilhermelima7@gmail.com"
}
# Alarme de CPU
resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name          = "High-CPU-Utilization-ECS-${var.env}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 120
  statistic           = "Average"
  threshold           = 75
  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.main.name
  }
  alarm_actions = [aws_sns_topic.alarms_topic.arn]
  ok_actions    = [aws_sns_topic.alarms_topic.arn]
  tags          = local.common_tags
}

# Alarme de Memória
resource "aws_cloudwatch_metric_alarm" "high_memory_alarm" {
  alarm_name          = "High-Memory-Utilization-ECS-${var.env}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization" # Métrica para memória
  namespace           = "AWS/ECS"
  period              = 120
  statistic           = "Average"
  threshold           = 80 # Alarma se a Memória ficar acima de 80% por 4 minutos (2 períodos de 120s)
  
  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.main.name
  }

  alarm_actions = [aws_sns_topic.alarms_topic.arn]
  ok_actions    = [aws_sns_topic.alarms_topic.arn]
  tags          = local.common_tags
}

# Endpoint de Interface para o CloudWatch Logs
resource "aws_vpc_endpoint" "logs" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  # Associa o endpoint às mesmas sub-redes privadas e ao mesmo security group dos outros endpoints
  subnet_ids         = [for subnet in aws_subnet.private : subnet.id]
  security_group_ids = [aws_security_group.vpc_endpoints_sg.id]

  tags = merge(local.common_tags, { Name = "vpce-logs-${var.env}" })
}