provider "aws" {
  region = "us-east-1"
}

resource "aws_dynamodb_table" "employee" {
  name = "emplyee-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "EmpID"

  attribute {
    name = "EmpID"
    type = "S"
  }
}