########################################
# PROVIDER — Terraform ko batata hai kis cloud se baat karni hai
########################################
provider "aws" {
  region = "us-east-1"
}

########################################
# 1. VPC — humara private network
# (Manual step: "Create VPC" console pe)
########################################
resource "aws_vpc" "devops_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "devops-vpc"
  }
}

########################################
# 2. SUBNETS — VPC ke andar 2 alag AZ me
# (Manual step: "Create subnet" x2)
########################################
resource "aws_subnet" "subnet_1" {
  vpc_id                  = aws_vpc.devops_vpc.id
  cidr_block               = "10.0.0.0/20"
  availability_zone        = "us-east-1a"
  map_public_ip_on_launch  = true   # EC2 launch hote hi public IP mile

  tags = {
    Name = "subnet-1"
  }
}

resource "aws_subnet" "subnet_2" {
  vpc_id                  = aws_vpc.devops_vpc.id
  cidr_block               = "10.0.16.0/20"
  availability_zone        = "us-east-1b"
  map_public_ip_on_launch  = true

  tags = {
    Name = "subnet-2"
  }
}

########################################
# 3. INTERNET GATEWAY — VPC ka internet ka darwaza
# (Manual step: "Create Internet Gateway" + "Attach to VPC")
########################################
resource "aws_internet_gateway" "devops_igw" {
  vpc_id = aws_vpc.devops_vpc.id

  tags = {
    Name = "devops-igw"
  }
}

########################################
# 4. ROUTE TABLE — traffic ka rule book
# (Manual step: "Create Route Table" + "Add route 0.0.0.0/0 -> IGW")
########################################
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.devops_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devops_igw.id
  }

  tags = {
    Name = "Public-route-table"
  }
}

# Route table ko dono subnets se associate karna
# (Manual step: "Associate route table with subnets")
resource "aws_route_table_association" "rta_subnet_1" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "rta_subnet_2" {
  subnet_id      = aws_subnet.subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

########################################
# 5. SECURITY GROUPS — EC2 ka firewall aur ALB ka firewall
# (Manual step: "Create ec2-sg" + "Create alb-sg")
########################################
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg"
  description = "Allow HTTP from ALB and SSH from my IP"
  vpc_id      = aws_vpc.devops_vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # Lab ke liye; production me apna IP daalo
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-sg"
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP from internet to ALB"
  vpc_id      = aws_vpc.devops_vpc.id

  ingress {
    description = "HTTP"
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

  tags = {
    Name = "alb-sg"
  }
}

########################################
# 6. AMI DATA SOURCE — latest Amazon Linux 2023 dhundhna
# (Manual step: "AMI: Amazon Linux" dropdown se select karna)
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
# 7. EC2 INSTANCES — dono web servers
# (Manual step: "Launch Instance" x2)
########################################
resource "aws_instance" "web_server_1" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type           = "t2.micro"
  subnet_id                = aws_subnet.subnet_1.id
  vpc_security_group_ids   = [aws_security_group.ec2_sg.id]

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

resource "aws_instance" "web_server_2" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type           = "t2.micro"
  subnet_id                = aws_subnet.subnet_2.id
  vpc_security_group_ids   = [aws_security_group.ec2_sg.id]

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
# 8. TARGET GROUP — healthy EC2 ki live directory
# (Manual step: "Create Target Group" + "Register EC2 Instances")
########################################
resource "aws_lb_target_group" "web_tg" {
  name     = "web-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.devops_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
  }

  tags = {
    Name = "web-target-group"
  }
}

# EC2 instances ko target group se register karna
resource "aws_lb_target_group_attachment" "attach_1" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web_server_1.id
  port              = 80
}

resource "aws_lb_target_group_attachment" "attach_2" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web_server_2.id
  port              = 80
}

########################################
# 9. APPLICATION LOAD BALANCER — reception desk
# (Manual step: "Create Load Balancer")
########################################
resource "aws_lb" "devops_alb" {
  name               = "devops-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]

  tags = {
    Name = "devops-alb"
  }
}

# Listener — ALB ko batata hai "port 80 pe aane wali request kaha forward karo"
# (Manual step: "Listener HTTP:80 -> Forward to web-target-group")
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.devops_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}
