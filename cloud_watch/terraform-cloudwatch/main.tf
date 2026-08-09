# ============================================================
# 1. Security Group
# ============================================================

data "aws_vpc" "default" {
  default = true
}

# Us VPC ke andar ke saare subnets fetch karo
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "watch_sg" {
  name = "cloud-watch-sg"
  vpc_id = data.aws_vpc.default.id
  
  # SSh
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  # HTTP
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  # Outbound
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ] 
  }
}

# ============================================================
# 2. EC2 Instance
# ============================================================
# Default VPC ko lookup karo

resource "aws_instance" "web" {
    ami = var.ami_id
    instance_type = var.instance_type
    key_name = var.key_name
    subnet_id              = data.aws_subnets.default.ids[0]
    vpc_security_group_ids = [ aws_security_group.watch_sg.id ]

    # Detailed monitoring
    monitoring = true

    # Install stress-ng automatically
    user_data = <<-EOF
                #!/bin/bash

                apt-get update -y

                apt-get install -y stress-ng

                echo "CloudWatch Demo Ready" > /tmp/demo.txt
                EOF

    tags = {
        Name = "cloud_watch-demo"
    }
}

# ============================================================
# 3. SNS Topic
# ============================================================
resource "aws_sns_topic" "cpu_alarm" {
  name = "ec2-high-cpu-alert"
}

# ============================================================
# 4. Email Subscription
# ============================================================
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.cpu_alarm.arn 
  protocol = "email"
  endpoint = var.email
}

# ============================================================
# 5. CloudWatch CPU Alarm
# ============================================================

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name = "EC2-High-CPU-alarm"
  alarm_description = "Alarm when EC2 CPU exceeds 70%"
  comparison_operator = "GreaterThanThreshold"
  threshold = 70
  evaluation_periods = 2
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = 60
  statistic           = "Average"

  dimensions = {
    InstanceId = aws_instance.web.id
  }

  alarm_actions = [ 
    aws_sns_topic.cpu_alarm.arn
   ]
   
   ok_actions = [
    aws_sns_topic.cpu_alarm.arn
   ]

   treat_missing_data = "notBreaching"
}
 