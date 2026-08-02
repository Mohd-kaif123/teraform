provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "web_server" {
  ami =var.ami_id
  instance_type =var.instance_type
  key_name =var.key_name
  vpc_security_group_ids =[aws_security_group.web_sg.id]

  tags = {
    Name = "WebServer"
  }
}

resource "aws_security_group" "web_sg" {
  name ="web_sg"
  description = "Allow HTTP and SSH traffic"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}