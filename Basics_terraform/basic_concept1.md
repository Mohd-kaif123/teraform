# Install Aws CLI
- agar hame aws provider ka use karna hai apne linux me tu pahale aws-cli install karna padega

## To install the AWS CLI, run the following command.
    - curl -fsSL https://awscli.amazonaws.com/v2/install.sh | bash
    - curl -fsSL https://awscli.amazonaws.com/v2/install.sh | sudo bash -s -- --system
    - curl -fsSL https://awscli.amazonaws.com/v2/install.sh | bash -s -- --help

> Install karne ke baad aws ko configure karna padega 
  uske liye hame lage access key, aur password

Step1:- go to aws account > IAM > if user not available then > creat user > give user name "terraform-admin" > give permissions > attach directly policy

step2:- Then go terraform-admin > security credentials > create access key > select use case "CLI" > next < create access key

step3:- copy the access key > go in linux cli > type "aws configure" > paste access key > Enter > then paste secret access key > Enter > json > enter > ab hogaeya

> aws s3 ls
- ye cmd se hamare jitni bhi bucket honge hamare aws account sab list hojaega


> Fir install karenge provider :
- abhi ham aws use karenge isliye ham install karenge aws
steps:- go to browser > search "terraform aws provider" > click firt link > uske andar kone me hoga "use provider usper click karna hai >
then wo cde ko copy karna hai > wo code ko ek terraform.tf ke file me paste kardo 

##################################################################################################################################################

# practise 1: Create EC2
- Ek ec2 bananae ke liye bahut si chiz chaiye jaise ki :-
    1) key pair     2) VPC & Security Group     3) ec2 instance

1) key pair
resource "aws_key_pair" "my_key" {
    key_name = "terra-key-ec2"
    public_key = file("terra-key-ec2.pub")  --> yeha file name diye, sidha public key bhi paste kar sakte the
    --> lekin hamne yeha file diya hai tu hame key file bhi isi folder me rakhna padega 
}

2) VPC & Security Group

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

3) ec2 Instance:-

resource "aws_instance" "my_instance" {
    key_name = "aws_key_pair.my_key.key_name
    security_groups = aws_security_group.my_security_group.name
    instance_type = "t2.micro"
    ami = "ami-0cb........."

    root_block_device {  --> jo ham ec2 launch karte time last storage dekhte hai na usko bhi apne hisab se storage le sakte hai
        volume_size = 15
        volume_type = "gp3"  (gernal purpose --> gp )
    }

    tags = {
        Name = "kaif-automate" 
    }
}

> Man lo agar hame baad me future me security group change karna hai ya ubuntu ki jagah amazon linux chaiye ya fir kuch karna hua

> tu ham banaenge ek variables file isse kya hoga ki hame sirf variables file me change karna hoga bass

> terraform destroy --target=<instance name jaisa main.tf me hai> eg: aws_instance.my_instance
---> ye cmd se hamara sirf instance delete hoga baki sab rahega jaise security group, key pai,vpc,etc
