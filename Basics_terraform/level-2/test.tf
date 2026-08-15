resource "aws_iam_role" "my_iam_role" {
    name = "iam_role"
    assume_role_policy =jsonencode({
        Version = "2012-10-17"
        Statement=[{
            Effect ="Allow"
            Principal = {
                Service = "ec2.amazonaws.com"
            }
            Action = "sts:AssumeRole"
        }]
    })
}
resource "aws_iam_role_policy_attachment" "iam_role_attachment" {
    for_each = toset ([
        "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
        "arn:aws:iam::aws:policy/AdministratorAccess"
    ])
    role = aws_iam_role.my_iam_role.name
    policy_arn = each.value
}

resource "aws_iam_instance_profile" "my_profile" {
    name ="my_instance_profile"
    role = aws_iam_role.my_iam_role.name
}

