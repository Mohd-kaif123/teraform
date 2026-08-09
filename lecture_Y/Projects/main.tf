# Dev infrastructure
    module "dev-infra" {
      source = "./infra-app"
      env = "dev"
      bucket_name = "kaii-infra-app-bucket-9146"
      instance_count = 1
      instance_type = "t2.micro"
      ec2_ami_id = "ami-0b6d9d3d33ba97d99"  # ubuntu machine
      hash_key = "studentID"
      public_key_path = "${path.root}/terra-key-ec2.pub"
    }