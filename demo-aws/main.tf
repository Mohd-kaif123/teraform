provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "my_ec2" {
    count = 3
  ami           = "ami-004f790b835b26145"
  instance_type = "t2.micro"
  tags = {
    Name = "web-instance-${count.index+1}"
  }
}

# terraform init
# terraform plan
# terraform apply -auto-approve
# terraform destroy -auto-approve
# terraform init && terraform plan && terraform -auto-approve
