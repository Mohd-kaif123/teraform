output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web.public_ip
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for CPU alerts"
  value       = aws_sns_topic.cpu_alarm.arn
}