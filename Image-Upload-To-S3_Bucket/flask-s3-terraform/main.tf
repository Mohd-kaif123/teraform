## terraform Configuration for deploying a Flask application to AWS S3
terraform {
  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

  }
}

provider "aws" {
  region = var.aws_region
}

# Create EC2 instance to host the Flask application
# Install Python, Flask, and other dependencies on the EC2 instance
# add User data in --> app.py
# Run the Application on the EC2 instance
# open the Ports  80, 5000

resource "aws_security_group" "aws_sg" {
  name = "ec2-sg"
  description = "Allow port 80 and 5000"
  vpc_id = "vpc-0ca1f92ea561a49d6"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    from_port = 5000
    to_port = 5000
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

resource "aws_instance" "my_ec2" {
  instance_type = "t2.micro"
  ami = "ami-004f790b835b26145"
  subnet_id = "subnet-027f44b03c5dc995a"
  associate_public_ip_address = true
  key_name = "secure_key"
  user_data = <<-EOF
  #!/bin/bash
  sudo apt update -y
  sudo apt install python3 -y
  sudo apt install python3 python3-flask python3-boto3

  # app.py file create kar rahe hai
  cat << 'APPFILE' > /home/ubuntu/app.py
  from flask import Flask
  import boto3

  app = Flask(__name__)

  @app.route('/')
  def home():
    return "Flask App Running on EC2 with Boto3!"
  
  if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
  APPFILE

  # Background me Flask App run karna
  nohup python3 /home/ubuntu/app.py > /home/ubuntu/app.log 2>&1 &
  EOF


  

}

# s3 bucket to host the Flask application
resource "aws_s3_bucket" "flask_app_bucket"{
  bucket = "kaif-s3-bucket-30082026"
  tags = {
    Name        = "FlaskAppBucket"
    Environment = "Development"
    project     = "FlaskApp"
  }
}

# s3 bucket policy s3:PutObject for the Flask application bucket
# s3 bucket plicy s3:GetObject for the Flask application bucket
resource "aws_s3_bucket_policy" "flask_app_bucket_policy" {

  bucket = aws_s3_bucket.flask_app_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowFlaskGetPut"
        Effect = "Allow"

        Principal = {
          AWS = "arn:aws:iam::748810634002:user/Nikunj"
        }

        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]

        Resource = "${aws_s3_bucket.flask_app_bucket.arn}/*"
      }
    ]
  })
}