terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
        source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners = [ "137112412989" ]

  filter {
    name = "name"   # Pehla name Terraform/AWS filter field hai. 
                    # Dusra "name" AWS AMI ka actual attribute hai.
    values = [ "al2023-ami-*-x86_64" ]   # Ye batata hai ki AMI ka naam kis pattern se match hona chahiye.
  }

  filter {
    name = "state"    # state = available
    values = ["available"]    # Sirf woh AMI select karo jo currently available hai.
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "default" {
  filter {
    name = "vpc-id"
    values = [ data.aws_vpc.default.id ]
  }
}

resource "aws_iam_role" "ec2_cloudwatch" {
  name = "${var.project_name}-EC2-CloudWatch-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cloudWatch_agent" {
  role = aws_iam_role.ec2_cloudwatch.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchServicePolicy"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.project_name}-instance-profile"
  role = aws_iam_role.ec2_cloudwatch
}

resource "aws_security_group" "ec2" {
  name = "${var.project_name}-sg"
  description = "Security group for CloudWatch log monitoring EC2"
  vpc_id = data.aws_vpc.default.id
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  egress {
    description = "Allow outbound access for package installation and CloudWatch"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

resource "aws_cloudwatch_log_group" "myapp" {
  name = "/demo/ec2/myapp"
  retention_in_days = var.log_retention_days

  tags = {
    Project = var.project_name
  }
}

resource "aws_instance" "log_monitor" {
  ami = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  subnet_id = data.aws_subnet.default.ids[0]
  vpc_security_group_ids = [ aws_security_group.ec2.id ]
  iam_instance_profile = aws_iam_instance_profile.ec2.name
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    log_group_name = aws_cloudwatch_log_group.myapp.name
  })

  user_data_replace_on_change = true

  tags = {
    Name = "${var.project_name}-EC2"
    Project = var.project_name
  }

  depends_on = [
    aws_iam_role_policy_attachment.cloudWatch_agent,
    aws_cloudwatch_log_group.myapp
   ]

}