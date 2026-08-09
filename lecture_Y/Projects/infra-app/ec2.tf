# key pair (login)

resource "aws_key_pair" "my_key_new" {
  key_name = "${var.env}-infra-app-key"
  public_key = file(var.public_key_path)

  tags = {
    Environment = var.env
  }
}

# VPC & Security Group
resource "aws_default_vpc" "default" {
  
}

resource "aws_security_group" "my_security_group" {
  name = "${var.env}-infra-app-sg"
  vpc_id = aws_default_vpc.default.id

  # Indbound rules
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH open"
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "HTTP open"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-infra-app-sg"
  }
}

# ec2 Instance

resource "aws_instance" "my_instance" {
  count = var.instance_count

  depends_on = [ aws_security_group.my_security_group, aws_key_pair.my_key_new ]

  key_name = aws_key_pair.my_key_new.key_name
  security_groups = [ aws_security_group.my_security_group.name ]
  ami = var.ec2_ami_id
  instance_type = var.instance_type

  root_block_device {
    volume_size = var.env == "prd" ? 20 : 10
    volume_type = "gp3"
  }
  tags = {
    Name = "${var.env}-infra-app-ec2"
    Environment = var.env
  }
}