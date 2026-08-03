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
    name = "automate-sg"
    description = "This will add terraform generated security group"
    vpc_id = aws_default_vpc.default.id  # isko bolte hai "interpolation" matlba hame isme value ham inherite karke late hai.

    # inbound rule
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
        description = "ssh open"
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
        description = "HTTP open"
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
        description = "all access outbond"
    }
}

# 3) ec2 Instance:-

resource "aws_instance" "my_instance" {
    key_name = "aws_key_pair.my_key.key_name"
    security_groups = aws_security_group.my_security_group.name
    instance_type = "t2.micro"
    ami = "ami-0cb........."

    root_block_device {  # --> jo ham ec2 launch karte time last storage dekhte hai na usko bhi apne hisab se storage le sakte hai
        volume_size = 15
        volume_type = "gp3" # (gernal purpose --> gp )
    }

    tags = {
        Name = "kaif-automate" 
    }
}