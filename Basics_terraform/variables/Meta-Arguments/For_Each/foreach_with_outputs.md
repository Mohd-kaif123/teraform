# 1. Single Resource Output
resource "aws_s3_bucket" "bucket" {
  for_each = {
    dev  = "dev-bucket-123"
    prod = "prod-bucket-123"
  }

  bucket = each.value
}

## Agar sirf dev bucket ka naam output karna hai:

output "dev_bucket_name" {
  value = aws_s3_bucket.bucket["dev"].bucket
}

Output:

dev_bucket_name = "dev-bucket-123"


# 2. Sabhi Resources ka Output (Map)
output "bucket_names" {
  value = {
    for key, bucket in aws_s3_bucket.bucket :
    key => bucket.bucket
  }
}

Output:

bucket_names = {
  dev  = "dev-bucket-123"
  prod = "prod-bucket-123"
}

# 4. EC2 Instance Example
resource "aws_instance" "server" {
  for_each = {
    web = "t2.micro"
    db  = "t2.small"
  }

  ami           = "ami-12345678"
  instance_type = each.value
}

Instance IDs output:

output "instance_ids" {
  value = {
    for key, instance in aws_instance.server :
    key => instance.id
  }
}

Output:

instance_ids = {
  web = "i-0123456789"
  db  = "i-0987654321"
}