variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type = string
  default = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID for the EC2 amazon instance"
  type = string
  default = "ami-004f790b835b26145"
}

variable "instance_type" {
  description = "The type of instance to use for the Ec2 instance"
  type = string
  default = "t3.micro"
}

variable "key_name" {
  description = "The name of the key pair to use for the EC2 instance"
  type = string
  default = "My_Ansible"
}