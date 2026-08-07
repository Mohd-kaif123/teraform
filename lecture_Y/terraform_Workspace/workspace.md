# WORKSPACES
>Purpose:
- Same Terraform code se multiple environments (dev, staging, prod) manage karna, bina alag-alag folder/code duplicate kiye — har workspace ka apna alag state file hota hai.

## Basic Commands
terraform workspace list          # sab workspaces dikhao
terraform workspace new dev       # naya workspace banao
terraform workspace select prod   # switch karo
terraform workspace show          # current workspace dikhao

### Example Usage in Code
resource "aws_instance" "web" {
  ami           = "ami-0abcd1234"
  instance_type = terraform.workspace == "prod" ? "t3.large" : "t3.micro"

  tags = {
    Name = "web-${terraform.workspace}"
  }
}

### Line-by-Line Breakdown
- terraform.workspace → built-in variable jo current active workspace ka naam deta hai (string).

- Conditional (? :) use karke workspace ke hisaab se instance type change kiya — prod me bada instance, dev me chota.

- tags me workspace naam interpolate kiya — taaki AWS console me bhi pata chale kaunsa environment ka resource hai.

### Multiple Examples
> Example 2 — Workspace-specific variable files:
terraform workspace select dev
terraform apply -var-file="dev.tfvars"

terraform workspace select prod
terraform apply -var-file="prod.tfvars"

> Example 3 — Workspace-based instance count:
locals {
  instance_count = {
    dev     = 1
    staging = 2
    prod    = 5
  }
}

resource "aws_instance" "app" {
  count         = local.instance_count[terraform.workspace]
  ami           = "ami-0abcd1234"
  instance_type = "t3.micro"
}

> Why Written This Way
- Ek hi .tf codebase, but state file alag-alag ho jaata hai per workspace (terraform.tfstate.d/dev/terraform.tfstate, etc. — local backend me). Isse code duplication avoid hoti hai.

> Effect of Removing
- Agar workspace use hi nahi karoge (default workspace pe sab kaam karoge), to dev/prod ka state mix ho jayega — bahut dangerous, prod resources accidentally modify ho sakte hain.

> Execution Flow
- workspace new dev → naya isolated state namespace create hota hai.
- Jab tum apply karte ho, Terraform current selected workspace ka state use karta hai.
- terraform.workspace variable code me automatically available hota hai.

## Real-World DevOps Use Case

- Chhoti team/startup jaha dev, staging, prod similar infra hai (bas size/scale alag) — workspaces se ek hi codebase maintain hoti hai. 
- Bade enterprise projects me generally separate directories + separate backends prefer karte hain (workspaces ki limitation: IAM permissions same hote hain sab workspace ke liye, jo prod ke liye risky ho sakta hai).

> Industry Usage

- Mid-size projects, personal projects, quick multi-env testing. Large enterprises often avoid workspaces for prod isolation (security reasons), use separate state files/directories instead.

> Interview Questions
- Workspaces vs separate directories/backends — kab kaun use karoge?
- terraform.workspace variable kaise kaam karta hai?
- Workspace ka limitation kya hai security perspective se?
- Default workspace kya hota hai?

> Common Beginner Mistakes
- Workspace switch karna bhool jaana aur galat environment pe apply kar dena!
- Workspaces ko full environment-isolation samajh lena (IAM roles/credentials switch nahi hote automatically).
- Prod/dev ke liye same AWS account + workspace use karna (risky — better: separate accounts).

>  Best Practices
Prompt/terminal me current workspace dikhane ka setup karo (PS1 customization) taaki galti se wrong env pe apply na ho.
Critical prod infra ke liye workspace ki jagah separate state + separate AWS account better hai.
CI/CD pipeline me workspace ko explicitly set karo, kabhi assume mat karo.
Memory Trick

"Workspace = same ghar (code), alag kamre (state) each environment ke liye"

Simple vs Production Example
Simple: dev aur test workspace me ek chhota S3 bucket banana.
Production: Companies generally workspaces avoid karke Terragrunt ya separate root modules use karte hain per-environment for better isolation.