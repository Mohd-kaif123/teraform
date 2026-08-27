#==================================================
# Step 1-2: Jenkins Server + Log File
#==================================================

# -------------------------------------------------
# 1. Find the Default VPC
# -------------------------------------------------

data "aws_vpc" "default" {
  default    = true
}


# -------------------------------------------------
# 2. Create Subnet
# -------------------------------------------------

resource "aws_subnet" "subenet" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = var.availability_zone
  cidr_block        = "172.31.32.0/20"

  tags = {
    Name = "My-Subnet"
  }
}


# -------------------------------------------------
# 3. Security Group
# -------------------------------------------------

resource "aws_security_group" "my-sg" {
  name   = "my-log-sg"
  vpc_id = data.aws_vpc.default.id

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# -------------------------------------------------
# 4. CloudWatch Log Group
# -------------------------------------------------

resource "aws_cloudwatch_log_group" "practise" {
  name              = "/jenkins/logs"
  retention_in_days = 7
}


# -------------------------------------------------
# 5. Jenkins EC2 Server
# -------------------------------------------------

resource "aws_instance" "jenkins_server" {

  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  # Security Group ID
  vpc_security_group_ids = [
    aws_security_group.my-sg.id
  ]

  # Subnet
  subnet_id = aws_subnet.subenet.id

  user_data = <<-EOF
    #!/bin/bash

    # Create Jenkins log directory
    sudo mkdir -p /var/log/jenkins

    # Create Jenkins log file
    sudo touch /var/log/jenkins/jenkins.log

    # Give read/write permission
    sudo chmod 644 /var/log/jenkins/jenkins.log

    # Update packages
    sudo apt-get update -y

    # Install CloudWatch Agent
    sudo apt-get install -y amazon-cloudwatch-agent

    # Create CloudWatch Agent configuration
    sudo mkdir -p /opt/aws/amazon-cloudwatch-agent/bin

    sudo tee /opt/aws/amazon-cloudwatch-agent/bin/config.json > /dev/null <<'CONFIG'
    {
      "logs": {
        "logs_collected": {
          "files": {
            "collect_list": [
              {
                "file_path": "/var/log/jenkins/jenkins.log",
                "log_group_name": "/jenkins/logs",
                "log_stream_name": "{instance_id}"
              }
            ]
          }
        }
      }
    }
    CONFIG

    # Start CloudWatch Agent
    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
      -a fetch-config \
      -m ec2 \
      -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json \
      -s

  EOF

  # Make sure Log Group exists before EC2 starts
  depends_on = [
    aws_cloudwatch_log_group.practise
  ]
}


# -------------------------------------------------
# 6. CloudWatch Metric Filter
# -------------------------------------------------

resource "aws_cloudwatch_log_metric_filter" "pract" {

  name           = "JenkinsErrorFilter"
  log_group_name = aws_cloudwatch_log_group.practise.name

  # Search for ERROR in Jenkins logs
  pattern = "ERROR"

  metric_transformation {
    name          = "JenkinsErrorCount"
    namespace     = "JenkinsApp"
    value         = "1"
    default_value = 0
  }
}


# -------------------------------------------------
# 7. CloudWatch Alarm
# -------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "jenkins_error_alarm" {

  alarm_name = "Jenkins-Error-Alarm"

  namespace   = "JenkinsApp"
  metric_name = "JenkinsErrorCount"

  comparison_operator = "GreaterThanThreshold"

  # Alarm if ERROR count > 5
  threshold = 5

  evaluation_periods = 1

  # 60 seconds
  period = 60

  statistic = "Sum"

  # Send alarm to SNS
  alarm_actions = [
    aws_sns_topic.jenkins_alarm.arn
  ]
}


# -------------------------------------------------
# 8. SNS Topic
# -------------------------------------------------

resource "aws_sns_topic" "jenkins_alarm" {
  name = "jenkins-error-alert"
}


# -------------------------------------------------
# 9. SNS Email Subscription
# -------------------------------------------------

resource "aws_sns_topic_subscription" "jenkins_email" {

  topic_arn = aws_sns_topic.jenkins_alarm.arn

  protocol = "email"

  endpoint = var.email
}