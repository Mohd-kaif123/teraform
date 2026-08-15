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
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "my_profile" {
  name = "my_instance_profile"
  role = aws_iam_role.my_iam_role.name
}
  
# Aur agar bahut sari policy add karni hai tu "For each" ka use kar sakte hai.
resource "aws_iam_role_policy_attachment" "iam_role_attachment" {
  role = aws_iam_role.my_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "iam_role_attachment" {
  role = aws_iam_role.my_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}