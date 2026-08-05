resource "aws_s3_bucket" "remote_s3" {
  bucket = "tws-state-bucket"

  tags = {
    Name = "tws-state-bucket"
  }
}