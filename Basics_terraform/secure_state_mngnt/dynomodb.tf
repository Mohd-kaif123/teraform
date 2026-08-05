resource "aws_dynamodb_table" "basic-aws_dynamodb_table" {
  name         = "tws-state-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    Name = "tws-state-table"
  }

}