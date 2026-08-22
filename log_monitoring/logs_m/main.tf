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
    name = "name"
    values = [ "al2023-ami-*-x86_64" ]
  }

  filter {
    name = "state"
    values = ["available"]
  }
}

data "aws_vpc" "default" {
  default = true
}