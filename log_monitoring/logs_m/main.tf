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
  
}