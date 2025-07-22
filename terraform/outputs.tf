output "api_url" {
  description = "URL publica da aplicacao (DNS do Application Load Balancer)"
  value       = "http://${aws_lb.app_lb.dns_name}"
}