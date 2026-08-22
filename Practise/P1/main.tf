#===========================================
# Create a VPC and 2 subnets
#===========================================
resource "aws_vpc" "my_vpc" {
    cidr_block = "10.0.0.0/16"

    tags = {
        Name = "devops-vpc"
    }
}

resource "aws_subnet" "my_subnet" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.0.0/20"
    availability_zone = "us-east-1a"

    tags = {
      Name = "subnet-1"
    }
}

resource "aws_subnet" "subnet" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.16.0/20"
  availability_zone = "us-east-1b"

  tags = {
    Name = "subnet-2"
  }
}

########################################
# 3. INTERNET GATEWAY
# Hint: sirf vpc_id chahiye, aur kuch nahi
########################################
resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "devops-igw"
  }
}

########################################
# 4. ROUTE TABLE + Route (0.0.0.0/0 -> IGW)
# Hint: route block ke andar cidr_block aur gateway_id
########################################
resource "aws_route_table" "my_rtb" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw
  }

  tags = {
    Name = "Public-route-table"
  }
}

# Route table ko Subnet-1 se jodna
resource "aws_route_table_association" "with_subnet-1" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_rtb.id
}

# Route table ko Subnet-2 se jodna
resource "aws_route_table_association" "with_subnet-2" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.my_rtb.id
}

########################################
# 5. SECURITY GROUP — ec2-sg
# Hint: ingress block x2 (HTTP 80, SSH 22), egress block x1
########################################
resource "aws_security_group" "my_sg" {
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
resource "aws_security_group" "my_alb_sg" {
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
resource "aws_instance" "my_ec2" {
  ami                    = ami-0150ccaf51ab55a51
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.my_subnet.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]

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
resource "aws_instance" "ec2" {
  ami                    = ami-0150ccaf51ab55a51
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]

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
resource "aws_lb_target_group" "alb_rg" {
  name     = "web-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    path     = "/"
    healthy_threshold = 2
    unhealthy_threshold = 2 
    protocol = "HTTP"
    interval = 30
  }
}

# EC2-1 ko target group me register karna
resource "aws_lb_target_group_attachment" "alb_ec2_1" {
  target_group_arn = aws_instance.my_ec2
  target_id        = aws_instance.my_ec2.id
  port             = 80
}

# EC2-2 ko target group me register karna
resource "aws_lb_target_group_attachment" "alb_ec2_2" {
  target_group_arn = aws_instance.ec2
  target_id        = aws_instance.ec2.id
  port             = 80
}

########################################
# 9. APPLICATION LOAD BALANCER
# Hint: subnets list me dono subnet ka reference, security_groups list me alb-sg
########################################
resource "aws_lb" "my_alb" {
  name               = "devops-alb"
  internal           = 
  load_balancer_type = "___________"
  security_groups    = [___________________]
  subnets            = [___________________, ___________________]
}

########################################
# 9b. LISTENER — ALB ko batata hai kaha forward karna hai
# Hint: default_action ke andar type aur target_group_arn
########################################
resource "aws_lb_listener" "___________" {
  load_balancer_arn = ___________________
  port              = ___________
  protocol          = "___________"

  default_action {
    type             = "___________"
    target_group_arn = ___________________
  }
}
