provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "versioned_bucket" {
  bucket = "kaifm-9146"
}

resource "aws_s3_bucket_ownership_controls" "bucket_ownership" {
  bucket = aws_s3_bucket.versioned_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  depends_on = [ 
    aws_s3_bucket_ownership_controls.bucket_ownership
   ]

   bucket = aws_s3_bucket.versioned_bucket.id
   acl = "public-read"
}

resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.versioned_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_block" {
  bucket = aws_s3_bucket.versioned_bucket.id

  block_public_policy = false 
  block_public_acls = false 
  ignore_public_acls = false 
  restrict_public_buckets = false
}

# Exercise 2:-
# This policy will allow public read access to the objects in the S3 bucket.

resource "aws_s3_bucket_policy" "public_read_policy" {
  bucket = aws_s3_bucket.versioned_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Sid = "PublicReadGetObject"
            Effect = "Allow"
            Principal = "*"
            Action = "s3:GetObject"
            Resource = "${aws_s3_bucket.versioned_bucket.arn}/*"   
        }
    ]
  })
}