#==========================================
# Aws provider
#==========================================

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

#===========================================
# Create a VPC and 2 subnets
#===========================================

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true 

  tags = {
    Name = "devops-vpc"
  }
}

resource "aws_subnet" "my_subnet-1" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.0.0/20"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true 

  tags = {
    Name = "subnet-1"
  }
}

resource "aws_subnet" "my_subnet-2" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.16.0/20"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true 

  tags = {
    Name = "subnet-2"
  }

}

########################################
# 3. INTERNET GATEWAY
# Hint: sirf vpc_id chahiye, aur kuch nahi
########################################
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "devops-igw"
  }
}

########################################
# 4. ROUTE TABLE + Route (0.0.0.0/0 -> IGW)
# Hint: route block ke andar cidr_block aur gateway_id
########################################
resource "aws_route_table" "my_rt" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "Public-route-table"
  }
}

# Route table ko Subnet-1 se jodna
resource "aws_route_table_association" "subnet1_ass" {
  subnet_id      = aws_subnet.my_subnet-1.id
  route_table_id = aws_route_table.my_rt.id
}

# Route table ko Subnet-2 se jodna
resource "aws_route_table_association" "subnet2_ass" {
  subnet_id      = aws_subnet.my_subnet-2.id
  route_table_id = aws_route_table.my_rt.id
}

########################################
# 5. SECURITY GROUP — ec2-sg
# Hint: ingress block x2 (HTTP 80, SSH 22), egress block x1
########################################
resource "aws_security_group" "my_ec2_sg" {
  name        = "ec2-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

########################################
# 5b. SECURITY GROUP — alb-sg
# Hint: sirf HTTP 80 ingress chahiye
########################################
resource "aws_security_group" "alb-sg" {
  name        = "alb-sg"
  description = "Allow HTTP from internet"
  vpc_id      = aws_vpc.my_vpc.id

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

########################################
# 6. AMI DATA SOURCE (isse copy kar sakte ho, ye tricky hai)
########################################
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

########################################
# 7. EC2 INSTANCE — web-server-1
# Hint: ami data source ka reference, subnet_id, security_group_ids (list me)
########################################
resource "aws_instance" "my_web1" {
  ami                    = data.aws_ami.amazon_linux
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.my_subnet-1
  vpc_security_group_ids = [aws_security_group.my_ec2_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum install -y httpd
              echo "Hello From Server 1" > /var/www/html/index.html
              systemctl start httpd
              systemctl enable httpd
              EOF

  tags = {
    Name = "web-server-1"
  }
}

########################################
# 7b. EC2 INSTANCE — web-server-2
# Hint: same as above, lekin subnet-2 aur "Server 2" text
########################################
resource "aws_instance" "my_web2" {
  ami                    = data.aws_ami.amazon_linux
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.my_subnet-2
  vpc_security_group_ids = [aws_vpc.my_vpc.id]

  user_data = <<-EOF
              #!/bin/bash
              yum install -y httpd
              echo "Hello From Server 2" > /var/www/html/index.html
              systemctl start httpd
              systemctl enable httpd
              EOF

  tags = {
    Name = "web-server-2"
  }
}

########################################
# 8. TARGET GROUP
# Hint: health_check block ke andar path, protocol
########################################
resource "aws_lb_target_group" "my_tg" {
  name     = "web-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    path     = "/"
    protocol = "HTTP"
    healthy_threshold = 2
    unhealthy_threshold = 2 
    interval = 30
  }
}

# EC2-1 ko target group me register karna
resource "aws_lb_target_group_attachment" "ec2-rg1" {
  target_group_arn = aws_lb_target_group.my_tg.arn
  target_id        = aws_instance.my_web1
  port             = 80
}

# EC2-2 ko target group me register karna
resource "aws_lb_target_group_attachment" "ec2-sg2" {
  target_group_arn = aws_lb_target_group.my_tg.arn
  target_id        = aws_instance.my_web2
  port             = 80
}

########################################
# 9. APPLICATION LOAD BALANCER
# Hint: subnets list me dono subnet ka reference, security_groups list me alb-sg
########################################
resource "aws_lb" "my_alb" {
  name               = "devops-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg]
  subnets            = [aws_subnet.my_subnet-1, aws_subnet.my_subnet-2]
}

########################################
# 9b. LISTENER — ALB ko batata hai kaha forward karna hai
# Hint: default_action ke andar type aur target_group_arn
########################################
resource "aws_lb_listener" "my_listner" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_tg.arn
  }
}
