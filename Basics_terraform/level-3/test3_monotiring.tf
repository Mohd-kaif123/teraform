terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>6.0"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "my_vpc" {
  default = true
}

data "aws_subnets" "my_vpc" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.my_vpc.id]
  }
}

resource "aws_security_group" "my_sg" {
  name   = var.my_sg_name
  vpc_id = data.aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["103.116.239.174/32"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web_instance" {
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  ami                    = var.aws_ami
  
  # FIX: Data resource name 'my_vpc' karke first index [0] pick kiya hai
  subnet_id              = tolist(data.aws_subnets.my_vpc.ids)[0]
  
  #iam_instance_profile   = aws_iam_instance_profile.my_profile.name
#======================================================
# THis is part of level-3
#=====================================================
  user_data = <<-EOF
    #!/bin/bash
    echo "server started at $(date)" > /home/ubuntu/test.txt
  EOF
#======================================================

  tags = {
    Name = var.instance_name
  }
}

# kaif_dev user par direct EC2 permission attach karna
/*
resource "aws_iam_user_policy_attachment" "kaif_dev_ec2_access" {
  user       = "kaif_dev"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}
*/
resource "aws_cloudwatch_log_group" "practise" {
  name = "/myApp/logs"
  retention_in_days = 3
}

resource "aws_cloudwatch_log_metric_filter" "pract" {
  name = "my_Test_filter"
  log_group_name = aws_cloudwatch_log_group.practise
  pattern = "ERROR"

  metric_transformation {
    name = "my_Test_count"
    namespace = "practiseApp"
    value = 1
    default_value = 0
  }
}