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