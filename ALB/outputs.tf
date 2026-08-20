# Apply hone ke baad terminal me ALB ka DNS name print hoga
# taaki console me jaake dhoondhna na pade

output "alb_dns_name" {
  description = "Load balancer ka DNS — isse browser me test karna"
  value       = aws_lb.devops_alb.dns_name
}

output "vpc_id" {
  description = "VPC ID — reference ke liye"
  value       = aws_vpc.devops_vpc.id
}
