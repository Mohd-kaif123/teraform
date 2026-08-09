# Ham 3 environement banaenge:
|
|--- Dev --> Isme banaenge --> one Ec2, one s3, t2.micro, Dynomodb, security group, vpc, key-pair.
|        
|--- stg --> Isme banaenge --> one Ec2, s3, t2.small, Dynomodb.
|
|--- prd --> Isme banaenge --> two EC2, S3, t2.medium, Dynomodb.
|

- Aur ham aesa terraform ka code likhenege ki ek hi baar me ye sara ban jaae.

- ham pahale ek folder banaenge
- infra-app --> folder name
    |
    |-- dynomodb.tf
    |-- ec2.tf
    |-- s3.tf
    |-- variable.tf

- abhi ham ye file ek template jaisa banenge taki alag name se bucket, instance key bana sake different different log.

- uske baad hamne file banai hai infra-app folder ke bahar
|-- main.tf
|-- provider.tf
|-- terraform.tf

- ham main.tf file me jake module banaenge.

- jaise hamne ek environment banaeya waise hi ham isii code me change karke other env bhi bana sakte hai 

# Devlopment infrastructure
    module "dev-infra" {
      source = "./infra-app"
      env = "dev"
      bucket_name = "infra-app-bucket"
      instance_count = 1
      instance_type = "t2.micro"
      ec2_ami_id = "ami-0b6d9d3d33ba97d99"  # ubuntu machine
      hash_key = "studentID"
    }

# production infrastructure
    module "prd-infra" {
      source = "./infra-app"
      env = "prd"
      bucket_name = "infra-app-bucket"
      instance_count = 2
      instance_type = "t2.medium"  # instance type bhi kuch bhi le sakte hai
      ec2_ami_id = "ami-0b6d9d3d33ba97d99"  # ubuntu machine ham dusra AMI bhi le sakte like, Amazon,redhat, centos, window,etc
      hash_key = "studentID"
    }

# staging infrastructure
    module "stg-infra" {
      source = "./infra-app"
      env = "stg"
      bucket_name = "infra-app-bucket"
      instance_count = 1
      instance_type = "t2.small"
      ec2_ami_id = "ami-0b6d9d3d33ba97d99"  # ubuntu machine
      hash_key = "studentID"
    }

