resource "aws_iam_role" "my_policy" {
  name = "ec2_IAM_policy"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
        Effect = "Allow"
        Principal = { 
            service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
    }]
  })
}