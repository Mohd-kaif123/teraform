# If we Want to create a multiple instances:-
- agar ham bahut sare instance banana chate hai ek hi code se tum ham use karenge 
- count = n(number dena hai hame jitna instance chaiye)

> count lagate hai yeha :-
- jaha per ham instance banate hai, jaha per hamare instance ki detail hoti hai

    resource "aws_instance" "my_instance" {
    count = 3 (ab 3 instance banega)
    key_name = aws_key_pair.my_key.key_name
    security_groups = [ aws_security_group.my_security_group.name ]
    instance_type = var.aws_instance_type
    ami = var.ec2_ami_id
    }

> lekin hame kuch changes karne padega jaise ki:-
output "ec2_public_ip" {
    value = aws_instance.my_instance[*].public_ip
}                                    |
                                ye dena hoga
output "ec2_dns" {
    value = aws_instance.my_instance[*].public_dns
}

output "ec2_private_ip" {
    value = aws_instance.my_instance[*].private_ip
}
