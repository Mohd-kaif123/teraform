Meta-arguments woh special arguments hain jo kisi bhi resource block ke andar use ho sakte hain, resource ka behavior control karne ke liye — kitne banane hain, kis order me banane hain, delete kaise handle karna hai.

# A) count

resource "aws_instance" "web" {
  count         = 3
  ami           = "ami-0abcdef1234567890"
  instance_type = "t2.micro"

  tags = {
    Name = "web-server-${count.index}"
  }
}

## Line-by-line:

- count = 3 → Terraform ko bolta hai yeh resource 3 baar banao
- count.index → 0, 1, 2 (loop jaisa index milta hai)
- "web-server-${count.index}" → String interpolation, output: web-server-0, web-server-1, web-server-2

- Access karna: aws_instance.web[0].id, aws_instance.web[1].id

- Remove karoge to: Sirf ek instance banega (default count = 1 hota hai agar resource me likha hi na ho)


# B) for_each

variable "instance_names" {
  default = ["web", "app", "db"]
}

resource "aws_instance" "servers" {
  for_each      = toset(var.instance_names)
  ami           = "ami-0abcdef1234567890"
  instance_type = "t2.micro"

  tags = {
    Name = each.value
  }
}

## Line-by-line:

- for_each = toset(var.instance_names) → List ko set me convert karke loop chalata hai (map bhi le sakta hai)
- each.value → Current item ki value
- each.key → Set ke case me key = value hoti hai; map ke case me key alag hoti hai

- Access karna: aws_instance.servers["web"].id

- Removing effect: Resource sirf ek baar banega static config ke sath.

# 🔑 count vs for_each — Interview Favorite!
Point	                count	                      for_each
Index type	          Number (0,1,2)	            String/key based
Resource identify	    Index se (position)	        Key/name se (stable)
Item remove karne     pe Sab resources reshuffle- Sirf woh specific item -
                      -ho sakte hain -               - delete/change hota hai
                      -(bhayanak issue!)	 
Best for	            Identical resources	         Named/unique resources


- ⚠️ Real Problem with count: Agar list ["web","app","db"] se "app" hata do, to index shift ho jata hai — Terraform db ko destroy karke naya bana sakta hai, kyunki index 2 se 1 ho gaya. Isliye production me for_each prefer karte hain jab resources unique/named hote hain.


# C) depends_on

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


# D) lifecycle
resource "aws_instance" "critical_db" {
  ami           = "ami-0abcdef1234567890"
  instance_type = "t3.large"

  lifecycle {
    prevent_destroy       = true
    create_before_destroy = true
    ignore_changes         = [tags]
  }
}

Line-by-line:

- prevent_destroy = true → terraform destroy chalane pe bhi yeh resource delete nahi hoga (accidental deletion se bachata hai — production databases ke liye critical!)

- create_before_destroy = true → Update ke time pehle NAYA resource banega, phir PURANA delete hoga (zero-downtime ke liye)

- ignore_changes = [tags] → Agar console se manually tags change kiye kisi ne, to Terraform usko "drift" na maane, ignore kar de

- Real DevOps use case: Production RDS/EC2 pe prevent_destroy = true lagana industry standard hai taaki galti se terraform destroy chalne pe bhi critical infra safe rahe.


# Interview Questions (Meta-Arguments)
1) count aur for_each me kya fundamental difference hai?
2) count.index ka use case batao
3) depends_on kab explicitly likhna padta hai?
4) prevent_destroy real project me kyu use karte ho?
5) create_before_destroy na ho to kya dikkat aa sakti hai?

> Quick Answers: 
(4) Production DB/critical resource accidental delete se bachane ke liye. 
(5) Downtime ho sakta hai kyunki pehle purana resource destroy hoga, phir naya banega — beech me service down rahegi.


# Common Mistakes

❌ count use karke named/unique resources banana (jaise different DB configs) — isse maintenance nightmare hota hai
❌ for_each me list directly dena bina toset()/tomap() ke — error aata hai kai versions me
❌ lifecycle block me galat combination (create_before_destroy + resource jiska naam unique constraint hai, jaise S3 bucket same naam se) — conflict error


# Memory Trick

"Count = Counting numbers, For_each = For named things" 🔢🏷️