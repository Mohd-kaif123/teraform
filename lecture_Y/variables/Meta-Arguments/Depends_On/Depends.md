--> depends on batata hai jo aapka resource Block hai wo kisper depend karta hai
--> jaise agar ham depends ke andar kuch dal dete hai tu uske bina instance nahi banega

resource "aws_s3_bucket" "logs" {
  bucket = "my-log-bucket"
}

resource "aws_instance" "app" {
  ami           = "ami-0abcdef1234567890"
  instance_type = "t2.micro"

  depends_on = [aws_s3_bucket.logs]
}

- Purpose: Normally Terraform automatically dependency graph banata hai (agar ek resource dusre ko reference karta hai). Lekin kabhi-kabhi explicit dependency chahiye hoti hai jab koi direct reference nahi hai code me, par real-world me order matter karta hai (jaise IAM role pehle banna chahiye, EC2 baad me, even though code me reference nahi diya).

- Effect of removing: Terraform dono resources ko parallel create kar sakta hai, jo kabhi-kabhi race condition create kar deta hai (jaise EC2 boot hone se pehle S3 bucket exist hi nahi karta agar app usse directly access kare).