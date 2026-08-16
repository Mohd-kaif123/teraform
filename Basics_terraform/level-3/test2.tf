# data block matlab "kuch naya mat banao, jo already AWS mein exist karta hai usko sirf READ karo" 
/*
data "aws_iam_policy" "s3_readonly" {
  name = "AmazonS3ReadOnlyAccess"
}
resource "aws_iam_role" "my_iam_role" {
  name = "iam_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "iam_role_attachment" {
  role = aws_iam_role.my_iam_role.name
  policy_arn = data.aws_iam_policy.s3_readonly.arn
}
*/