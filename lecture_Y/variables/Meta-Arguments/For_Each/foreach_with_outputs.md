########
output "ec2_public_ip" {
  value = [
    for key in aws_instance.my_instance : key.public_ip
  ]
}
--> ham "key" ke andar daal rahe "aws_instance.my_instance" ko 
--> tabhi ham sort form me use kar paenge na aur yeha per loop chal raha hai
--> hame "public_ip" chaiye tha tu ham kardiye "key.public_ip"
--> jaise ham other progaming language me likhte hai for i in range(ya kuch bhi) waise hi idhar samjho

# Aur aese hi ham private IP aur DNS bhi nikal sakte hai
1) output "ec2_public_dns" {
     value = [
        for key in aws_instance.my_instance : key.public_dns
      ]
}
2) output "ec2_private_ip" {
     value = [
        for key in aws_instance.my_instance : key.private_ip
      ]
}

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


# 3. Sirf List Chahiye
output "bucket_list" {
  value = [
    for bucket in aws_s3_bucket.bucket :
    bucket.bucket
  ]
}

Output:

bucket_list = [
  "dev-bucket-123",
  "prod-bucket-123"
]

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

# 5. IP Address Output
output "public_ips" {
  value = {
    for key, instance in aws_instance.server :
    key => instance.public_ip
  }
}

Output:

public_ips = {
  web = "54.123.10.5"
  db  = "18.222.11.7"
}

# Interview Point (Bahut Important)

Agar resource for_each se bana hai:

❌ Galat:

aws_instance.server.id

Kyunki multiple instances hain.

✅ Sahi:

aws_instance.server["web"].id

ya

{
  for key, instance in aws_instance.server :
  key => instance.id
}


# Rule yaad rakho
- Ek specific resource ka output → resource_name["key"].attribute
- Sabhi resources ka output (map) → for key, value in resource_name : key => value.attribute
- Sirf list chahiye → for value in resource_name : value.attribute