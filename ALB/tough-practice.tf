########################################
# VARIABLES — pehle ye samjho, ye already sahi hai
########################################
variable "subnet_cidrs" {
  default = ["10.0.0.0/20", "10.0.16.0/20"]
}

variable "azs" {
  default = ["us-east-1a", "us-east-1b"]
}

########################################
# TOUGH EXERCISE — is ek block se DONO subnets banane hai
# Hint 1: count = 2 (ya better: length(var.subnet_cidrs))
# Hint 2: cidr_block ke liye var.subnet_cidrs[count.index] use karo
# Hint 3: availability_zone ke liye var.azs[count.index] use karo
# Hint 4: Name tag me "subnet-1", "subnet-2" chahiye — isliye
#         "subnet-${count.index + 1}" likhna hoga (+1 isliye kyunki index 0 se start hota hai)
########################################
resource "aws_subnet" "subnet" {
  count             = 2
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = "subnet-${count.index + 1 }"
  }
}

########################################
# BONUS TOUGH — route_table_association bhi count se banao
# Hint: subnet_id ke liye aws_subnet.subnet[count.index].id likhna hoga
#       (kyunki ab subnet khud count-based hai, isliye [] index chahiye)
########################################
resource "aws_route_table_association" "rta" {
  count          = 2
  subnet_id      = aws_subnet.subnet[count.index]
  route_table_id = aws_route_table.public_rt.id
}
