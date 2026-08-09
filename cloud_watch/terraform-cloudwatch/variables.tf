variable "aws_region" {
  description = "Aws Region"
  type = string
  default = "us-east-1"
}

variable "ami_id" {
  description = "Ubuntu AMI ID"
  type = string
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type = string
  default = "t2.micro"
}

variable "key_name" {
  description = "EC2 key name"
  type = string
}

variable "email" {
  description = "This is my email"
  type = string
}
