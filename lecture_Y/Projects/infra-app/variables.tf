variable "env" {
  description = "This is the environment for my instance"
  type = string
}

variable "bucket_name" {
    description = "This is my bucket name"
    type = string
  
}

variable "instance_count" {
  description = "This is No. of instance"
  type = number
}

variable "instance_type" {
  description = "This is instance type"
  type = string
}

variable "ec2_ami_id" {
  description = "THis is AMI ID"
  type = string
}

variable "hash_key" {
    description = "THis hash key"
    type = string
}

variable "public_key_path" {
  type = string
}