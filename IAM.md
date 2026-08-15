assume_role_policy = jsonencode({
  Version = "2012-10-17"
  Statement = [
    {
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }
  ]
})

# Ab isko English mein bolke samjho, jaise koi kahani padh rahe ho:

- Version = "2012-10-17"  ---> Ye ek fixed date hai, hamesha yehi likhna — ye IAM policy language ka version number hai.
  Isko yaad karne ki zarurat nahi, sirf copy-paste karo hamesha. Kabhi nahi badalta.

- Statement = [ ... ] --->	Ek list hai rules ki. [ ] bracket dikhata hai ki multiple rules bhi ho sakte hain (abhi ek hi hai).

- Effect = "Allow" --->	Sirf 2 options hote hain: "Allow" ya "Deny". Tum hamesha "Allow" likhoge jab kisi ko permission dena ho.

- Principal = { Service = "ec2.amazonaws.com" }	"KAUN" ye role use kar sakta hai — yaha bol rahe ho "EC2 service" (yani koi EC2 instance) is role ko use kar sakta hai.
  Agar Lambda ko permission deni hoti to yaha "lambda.amazonaws.com" likhte.

- Action = "sts:AssumeRole"	Ye hamesha fixed rehta hai jab bhi koi service kisi role ko "pehen" ne (assume karne) ki koshish karti hai. Ye ek technical AWS action hai, isko yaad rakho as-is.

> Bas itni si baat hai. Poori trust policy sirf ye keh rahi hai:
"Is role ko sirf EC2 service assume kar sakti hai, aur usse allow karo."


# Method 1: AWS Managed Policy Attach Karna (Recommended 🌟)
#1. Aapka IAM Role
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

#2. Pehli Policy Attach Karein (e.g., S3 Read Only Access)
resource "aws_iam_role_policy_attachment" "s3_read_only" {
  role       = aws_iam_role.my_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

#3. Dusri Policy Attach Karein (e.g., DynamoDB Read Only Access)
resource "aws_iam_role_policy_attachment" "dynamodb_read_only" {
  role       = aws_iam_role.my_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBReadOnlyAccess"
}