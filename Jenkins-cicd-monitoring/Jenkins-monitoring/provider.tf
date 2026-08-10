terraform {
  required_version = "~> 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"    # ye denge tabhi aws provider plugins download karega.
      version = "~> 6.0"
    }
  }
}
# Agar ye hata do: Terraform ko pata hi nahi chalega kaunsa provider plugin download karna hai → terraform init fail ho jayega.

provider "aws" {
  region = var.aws_region
}

# Interview Q: ~> vs >= mein farak? → ~> upper bound bhi lagata hai (safe upgrades only), >= unlimited upgrade allow karta hai (risky, breaking changes aa sakte hain).