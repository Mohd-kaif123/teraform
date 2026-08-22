########################################
# 3. INTERNET GATEWAY
# Hint: sirf vpc_id chahiye, aur kuch nahi
########################################
resource "aws_internet_gateway" "___________" {
  vpc_id = ___________________

  tags = {
    Name = "devops-igw"
  }
}

########################################
# 4. ROUTE TABLE + Route (0.0.0.0/0 -> IGW)
# Hint: route block ke andar cidr_block aur gateway_id
########################################
resource "aws_route_table" "___________" {
  vpc_id = ___________________

  route {
    cidr_block = "___________"
    gateway_id = ___________________
  }

  tags = {
    Name = "Public-route-table"
  }
}

# Route table ko Subnet-1 se jodna
resource "aws_route_table_association" "___________" {
  subnet_id      = ___________________
  route_table_id = ___________________
}

# Route table ko Subnet-2 se jodna
resource "aws_route_table_association" "___________" {
  subnet_id      = ___________________
  route_table_id = ___________________
}

########################################
# 5. SECURITY GROUP — ec2-sg
# Hint: ingress block x2 (HTTP 80, SSH 22), egress block x1
########################################
resource "aws_security_group" "___________" {
  name        = "ec2-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = ___________________

  ingress {
    from_port   = ___________
    to_port     = ___________
    protocol    = "___________"
    cidr_blocks = ["___________"]
  }

  ingress {
    from_port   = ___________
    to_port     = ___________
    protocol    = "___________"
    cidr_blocks = ["___________"]
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
resource "aws_security_group" "___________" {
  name        = "alb-sg"
  description = "Allow HTTP from internet"
  vpc_id      = ___________________

  ingress {
    from_port   = ___________
    to_port     = ___________
    protocol    = "___________"
    cidr_blocks = ["___________"]
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
resource "aws_instance" "___________" {
  ami                    = ___________________
  instance_type          = "___________"
  subnet_id              = ___________________
  vpc_security_group_ids = [___________________]

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
resource "aws_instance" "___________" {
  ami                    = ___________________
  instance_type          = "___________"
  subnet_id              = ___________________
  vpc_security_group_ids = [___________________]

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
resource "aws_lb_target_group" "___________" {
  name     = "web-target-group"
  port     = ___________
  protocol = "___________"
  vpc_id   = ___________________

  health_check {
    path     = "___________"
    protocol = "___________"
  }
}

# EC2-1 ko target group me register karna
resource "aws_lb_target_group_attachment" "___________" {
  target_group_arn = ___________________
  target_id        = ___________________
  port             = ___________
}

# EC2-2 ko target group me register karna
resource "aws_lb_target_group_attachment" "___________" {
  target_group_arn = ___________________
  target_id        = ___________________
  port             = ___________
}

########################################
# 9. APPLICATION LOAD BALANCER
# Hint: subnets list me dono subnet ka reference, security_groups list me alb-sg
########################################
resource "aws_lb" "___________" {
  name               = "devops-alb"
  internal           = ___________
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
