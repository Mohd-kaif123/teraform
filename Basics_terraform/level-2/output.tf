output "my_public_ip" {
  value = data.aws_vpc.my_vpc.id
}

output "my_ami_id" {
  value = var.aws_ami
}