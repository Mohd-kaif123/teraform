output "instance_public_ip" {
  description = "The public Ip address of the EC2 instance"
  value = aws_instance.web_server.public_ip 
}
output "instance_id" {
  description = "The ID of the EC2 instance"
  value = aws_instance.web_server.id
}