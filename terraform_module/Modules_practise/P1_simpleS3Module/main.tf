provider "aws" {
  region = "us-east-1"
}

module "logs_bucket" {
  source = "./modules/simple_bucket"

  prefix = "kaif-logs-"
}