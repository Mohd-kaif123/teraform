provider "aws" {
  region = "us-east-1"
}

# 1) key pair
resource "aws_key_pair" "my_key" {
    key_name = "terra-key-ec2"
    public_key = file("terra-key-ec2.pub")  #  --> yeha file name diye, sidha public key bhi paste kar sakte the
   # --> lekin hamne yeha file diya hai tu hame key file bhi isi folder me rakhna padega 
}

# 2) VPC & Security Group

resource "aws_default_vpc" "default" {
}

resource "aws_security_group" "my_security_group" {
    name = var.sg_name
    description = "This will add terraform generated security group"
    vpc_id = aws_default_vpc.default.id  # isko bolte hai "interpolation" matlba hame isme value ham inherite karke late hai.

    # inbound rule
    ingress {
        from_port = var.ingress_ports[0]
        to_port = var.ingress_ports[0]
        protocol = "tcp"
        cidr_blocks = var.allowed_cidr
        description = "ssh open"
    }

    ingress {
        from_port = var.ingress_ports[1]
        to_port = var.ingress_ports[1]
        protocol = "tcp"
        cidr_blocks = var.allowed_cidr
        description = "HTTP open"
    }

    egress {
        from_port = var.engress_ports
        to_port = var.engress_ports
        protocol = "-1"
        cidr_blocks = var.cidr_engress
        description = "all access outbond"
    }
}

# 3) ec2 Instance:-

resource "aws_instance" "my_instance" {
    key_name = aws_key_pair.my_key.key_name
    security_groups = [ aws_security_group.my_security_group.name ]
    instance_type = var.aws_instance_type
    ami = var.ec2_ami_id
    user_data = file("install_nginx.sh")

    root_block_device {  # --> jo ham ec2 launch karte time last storage dekhte hai na usko bhi apne hisab se storage le sakte hai
        volume_size = var.volume_size
        volume_type = var.volume_type # (gernal purpose --> gp )
    }

    tags = {
        Name = "kaif-automate" 
    }
}