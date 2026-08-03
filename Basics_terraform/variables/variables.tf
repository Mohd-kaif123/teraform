variable "aws_instance_type" {
  default = "t2.micro"
  type = string
}

variable "sg_name" {
    default = "my-app-sg"
    type = string
    description = "This is name of security group"
}

variable "ec2_ami_id" {
    default = "ami-004f790b835b26145"
    type = string
}

variable "ingress_ports" {
  description = "List of ports to allow inbound"
  type        = list(number)
  default     = [22, 80]
}

variable "allowed_cidr" {
    default = [ "0.0.0.0/0" ]
    type = list(string)
    description = "give the cidr in inbound rule"
}

variable "engress_ports" {
    default = 0
    type = number
}

variable "cidr_engress" {
    default = [ "0.0.0.0/0" ]
    type = list(string)
}

variable "volume_size" {
    default = 15
    type = number
}

variable "volume_type" {
    default = "gp3"
    type = string
}
