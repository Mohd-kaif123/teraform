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
  
  iam_instance_profile   = aws_iam_instance_profile.my_profile.name

  tags = {
    Name = var.instance_name
  }
}

# kaif_dev user par direct EC2 permission attach karna
resource "aws_iam_user_policy_attachment" "kaif_dev_ec2_access" {
  user       = "kaif_dev"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}