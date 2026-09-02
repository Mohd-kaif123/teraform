# 🎯 Terraform Sikhne Ka Structured Practice System
### Level 1 (Basic) se Level 8 (Advanced) — Har Level mein 4 Tasks

> **Rule:** Kisi bhi level ka task tab tak next level pe mat jao jab tak:
> 1. Tumne **bina copy-paste** khud type na kiya ho
> 2. `terraform plan` chala ke dekha na ho (error aaye to khud fix karne ki koshish karo)
> 3. Har line ke saamne khud se comment likh ke justify kiya ho "ye kyu likha"

---

## 🟢 LEVEL 1 — Foundation (Provider + Variable + Simplest Resource)
**Goal:** Samajhna ki `.tf` files ka basic skeleton kaisa hota hai aur ek single resource kaise banta hai.

**Task 1.1 — `provider.tf` khud se likho**
AWS provider set karo, region `ap-south-1` (Mumbai) rakho, aur `required_version >= 1.5.0` lagao. Docs mat dekho pehle attempt mein — jitna yaad hai utna likho, phir check karo.

**Task 1.2 — `variable.tf` mein 3 variables banao**
`aws_region` (default ke saath), `bucket_name` (mandatory, no default), `environment` (default = "dev"). Har variable mein `description` aur `type` zaroor likho.

**Task 1.3 — `terraform.tfvars` banao**
Upar wale mandatory variable (`bucket_name`) ki value do. Socho — kya `aws_region` ki value yaha dena zaroori hai agar default pehle se hai?

**Task 1.4 — Ek simple S3 bucket resource banao**
`main.tf` mein sirf ek `aws_s3_bucket` resource likho jo `var.bucket_name` use kare. `terraform init` aur `terraform plan` chalao — koi error aaye to khud padhke samjho error message kya keh raha hai.

✅ **Level 1 pass karne ka signal:** `terraform plan` clean chal jaye, koi hardcoded value na ho (sab variable se aaye).

---

## 🟡 LEVEL 2 — Networking + Multiple Resources
**Goal:** Ek resource dusre resource ko reference kaise karta hai (dependency chain) samajhna.

**Task 2.1 — Default VPC ko data source se fetch karo**
`data "aws_vpc" "default"` likho. Fir socho: iska `.id` attribute kis kaam aayega aage?

**Task 2.2 — Security Group banao**
Ek `aws_security_group` banao jisme SSH (22) sirf apne IP se allow ho (`0.0.0.0/0` NAHI — apna IP `curl ifconfig.me` se nikaalo), aur HTTP (80) sab ke liye open ho. Egress bhi likho.

**Task 2.3 — EC2 instance banao jo is Security Group ko use kare**
`aws_instance` resource banao, `vpc_security_group_ids` mein Task 2.2 wale SG ka reference do. AMI ke liye `data "aws_ami"` block use karo (Ubuntu ya Amazon Linux, `most_recent = true` ke saath) — hardcode mat karo.

**Task 2.4 — `output.tf` banao**
Instance ka `public_ip` aur `id` output karo. `terraform apply` chalao aur real IP pe `curl` karke check karo instance up hai.

✅ **Level 2 pass:** Tumhe resource ke beech reference (`resource_type.name.attribute`) likhna aa jana chahiye bina dekhe.

---

## 🟡➡️🟠 LEVEL 2.5 — IAM Bridge (Console se Code tak)
**Goal:** Console mein click karke jo karte ho, wahi cheez CODE mein kaise likhte hain — sirf syntax aur JSON structure samajhna, koi bada project nahi.

> Console mein tum "Attach Policy" button click karte ho. Code mein wahi kaam 2 cheezein karke hota hai: (1) JSON likhna "kaun/kya allowed hai", (2) usko `jsonencode()` ke andar daalna. Bas itni si baat hai — neeche step-by-step dekho.

**Task 2.5.1 — Sirf `jsonencode()` samjho (chhota standalone test)**
Ek naya file `test.tf` banao (koi AWS resource nahi, sirf practice). Ye likho aur `terraform console` mein run karke dekho ye kya output deta hai:
```hcl
output "test" {
  value = jsonencode({
    naam = "kaif"
    age  = 25
  })
}
```
Command: `terraform apply` ya `terraform console` mein `jsonencode({naam="kaif"})` type karo. Dekhо HCL object kaise JSON string ban jata hai — bas yehi cheez IAM policy mein hoti hai.

**Task 2.5.2 — "Trust Policy" ka structure ratto (fill-in-the-blank style)**
Ye template hai — sirf `_____` waali jagah bhar ke complete karo (dekhe bina samajhne ki koshish karo har field ka matlab):
```hcl
assume_role_policy = jsonencode({
  Version = "2012-10-17"
  Statement = [
    {
      Effect    = "_____"           # Allow ya Deny?
      Principal = { Service = "_____.amazonaws.com" }   # kaunsi service (ec2/lambda) role use karegi?
      Action    = "sts:_____"        # ye action fixed hota hai role assume karne ke liye
    }
  ]
})
```
Iske baad Task 3.1 mein yehi template use karke poora role banaoge — ab tumhe pata hoga har blank kya matlab rakhta hai.

**Task 2.5.3 — Policy ARN dhundhna seekho (console ki tarah code mein bhi)**
AWS console mein jab tum "Attach Policy" pe click karte ho to ek list dikhti hai (jaise `AmazonS3ReadOnlyAccess`). Code mein ye policies ke fixed ARN hote hain format mein:
```
arn:aws:iam::aws:policy/<PolicyName>
```
AWS console mein IAM → Policies mein jaake `AmazonS3ReadOnlyAccess` aur `CloudWatchAgentServerPolicy` dono ka ARN copy karo (top pe likha hota hai). Ek notepad mein dono ARN likh lo — Task 3.2 mein ye use hoga.

**Task 2.5.4 — Chhota practical: EC2 ko manually console se role attach karke dekho (baseline)**
Console mein: EC2 → apna instance select → Actions → Security → Modify IAM Role → koi bhi existing role attach karo. Ab socho: "Terraform mein ye same kaam karne ke liye mujhe kitne resource blocks likhne padenge?" (Answer: 3 — Role, Policy Attachment, Instance Profile). Yehi comparison samajhna is task ka goal hai — console ka 1 click = code ke 3 blocks, kyunki code mein har cheez explicit likhni padti hai.

✅ **Level 2.5 pass:** Bina kisi resource ke, sirf `jsonencode()` aur trust policy ka structure bina dekhe likh sako — chahe wo galat bhi ho, structure yaad hona chahiye.

---

## 🟠 LEVEL 3 — IAM, Permissions aur Data Sources
**Goal:** "Kaun kya kar sakta hai" wala concept — IAM Role, Policy, Instance Profile ki chain samajhna.

**Task 3.1 — IAM Role banao (trust policy ke saath)**
`aws_iam_role` banao jisme `assume_role_policy` mein sirf `ec2.amazonaws.com` ko allow karo `sts:AssumeRole` action ke liye. `jsonencode()` use karna mat bhoolna.

**Task 3.2 — Managed policy attach karo**
`aws_iam_role_policy_attachment` se `AmazonS3ReadOnlyAccess` (ya koi bhi managed policy) attach karo apne role pe. Socho: ye role ko S3 buckets ke saath kya karne dega?

**Task 3.3 — Instance Profile banao aur EC2 se link karo**
`aws_iam_instance_profile` banao, use apne Level 2 wale EC2 instance mein `iam_instance_profile` field mein daalo. Apply karke AWS console mein instance ke "IAM Role" tab mein confirm karo ki role attach hua ya nahi.

**Task 3.4 — Data source se existing IAM policy padho**
`data "aws_iam_policy_document"` ya `data "aws_iam_policy"` use karke ek existing AWS managed policy ka ARN nikaalo bina hardcode kiye. (Hint: `data "aws_iam_policy" "example" { name = "AmazonS3ReadOnlyAccess" }`)

✅ **Level 3 pass:** Tumhe explain karna aana chahiye — bina notes dekhe — ki Role, Policy, aur Instance Profile teeno alag kyu hain aur kaise connected hain.

---

## 🟠➡️🔴 LEVEL 3.5 — Monitoring Bridge (Bash script se CloudWatch Alarm tak)
**Goal:** Level 4 mein 4 alag-alag naye concepts ek saath aate hain (`user_data` script, Log Group, Metric Filter, Alarm) — yaha unko ek-ek karke, chhota-chhota tod ke practice karenge. Koi bhi task poora "monitoring pipeline" nahi hai — sirf ek-ek piece hai.

> Socho aisa: Level 4 = ek machine jisme 4 parts hain (engine, wire, sensor, bell). Yaha hum har part ALAG se test drive karenge, phir Level 4 mein sab jodenge.

**Task 3.5.1 — `user_data` sirf heredoc syntax practice (bina AWS ke)**
Apne local terminal (WSL/Ubuntu) mein ek `.sh` file banao aur ye heredoc syntax practice karo (ye Terraform ke andar bhi bilkul waise hi likha jayega):
```bash
cat <<-EOF
  echo "Hello Kaif"
  echo "Ye multi-line block hai"
EOF
```
Run karke dekho output kya aata hai. Fir `-` hata ke (`<<EOF` bina dash ke) dubara run karo aur farak dekho (indentation wala). Ye samajhna hai — `<<-EOF ... EOF` sirf ek "yaha se multi-line text shuru, yaha khatam" marker hai, kuch magic nahi.

**Task 3.5.2 — `main.tf` mein sirf EC2 pe test `user_data` lagao (chhota version)**
Apne Level 2 wale EC2 instance mein `user_data` field add karo — sirf itna:
```hcl
user_data = <<-EOF
  #!/bin/bash
  echo "Server started at $(date)" > /home/ubuntu/test.txt
EOF
```
Apply karo, instance mein SSH karke (ya console se) check karo `/home/ubuntu/test.txt` bani ya nahi. **Sirf itna** — abhi Jenkins/Java kuch mat install karo, sirf ye confirm karo ki user_data chal raha hai.

**Task 3.5.3 — CloudWatch Log Group akela banao (fill-in-the-blank)**
Koi EC2 se link mat karo abhi, sirf standalone resource:
```hcl
resource "aws_cloudwatch_log_group" "practice" {
  name              = "/_____/_____"      # convention: /service-naam/purpose, jaise /myapp/logs
  retention_in_days = _____                # kitne din baad auto-delete ho? (socho: training ke liye kam rakho)
}
```
Apply karo, AWS Console → CloudWatch → Log Groups mein jaake confirm karo bani ya nahi. Isse dikh jayega ki resource banana aur usme actual logs bhejna do alag steps hain.

**Task 3.5.4 — Metric Filter ka structure samjho (sirf concept, chhota example)**
Ye template bhar ke socho ye kya karega — dobara, apply karne ki zarurat nahi, sirf likh ke samjho:
```hcl
resource "aws_cloudwatch_log_metric_filter" "practice" {
  name            = "MyTestFilter"
  log_group_name  = aws_cloudwatch_log_group.practice.name   # Task 3.5.3 wale ko reference karo
  pattern         = "_____"          # kaunsa word/text dhundhna hai logs mein? (jaise "FAIL" ya "ERROR")

  metric_transformation {
    name          = "MyTestCount"
    namespace     = "PracticeApp"
    value         = "1"               # har match pe kitna add karna hai counter mein
    default_value = 0                 # agar koi match na ho to value kya rahegi
  }
}
```
**Sawaal khud se poocho:** Agar `pattern = "ERROR"` hai aur log mein "error" (small letter) aaya, kya match hoga? (Answer: nahi — CloudWatch metric filter case-sensitive hota hai by default)

✅ **Level 3.5 pass:** Tumhe ye 4 pieces alag-alag bina dekhe likhne aane chahiye — `user_data` heredoc, Log Group, aur Metric Filter ka basic skeleton. Alarm aur SNS abhi mat chhuo — wo Level 4 mein directly aayenge jab tumhe piece-by-piece confidence aa jaye.

---

## 🔴 LEVEL 4 — Monitoring, Alerting aur `user_data`
**Goal:** Ek "living" infrastructure banana jo khud logs bheje aur alert kare — jo tumne Jenkins project mein dekha, ab khud banao.

**Task 4.1 — CloudWatch Log Group banao**
`aws_cloudwatch_log_group` banao apne app ke liye, `retention_in_days = 14` rakho. Socho: agar ye field na do to kya hoga?

**Task 4.2 — EC2 mein `user_data` likho (heredoc syntax se)**
Apne EC2 instance mein ek chhota bash script likho jo: nginx install kare, start kare, aur ek custom `index.html` file bana ke usme apna naam likh de. `<<-EOF ... EOF` syntax use karo.

**Task 4.3 — Metric Filter + Alarm banao**
`aws_cloudwatch_log_metric_filter` banao jo kisi specific word (jaise "FATAL") dhundhe logs mein, aur ek `aws_cloudwatch_metric_alarm` banao jo threshold cross hone pe trigger ho. Namespace aur metric_name dono jagah match karna zaroori hai — ye check khud karo.

**Task 4.4 — SNS Topic + Email Subscription banao**
Alarm ko SNS se connect karo apne email pe. Apply karne ke baad email confirm karna mat bhoolna — warna alert nahi aayega (ye common real-world mistake hai).

✅ **Level 4 pass:** Poore monitoring pipeline ka flow diagram khud bana ke explain kar sako (log → filter → metric → alarm → SNS → email) bina kisi cheat sheet ke.

---

## 🟣 LEVEL 5 — Modules (Code Ko Reusable Banana)
**Goal:** Samajhna ki bada code chhote, reusable "packets" mein kaise todte hain — jaise programming mein functions banate ho.

> **Pehle chhota mental model:** Module = ek folder jisme apna `main.tf`, `variables.tf`, `outputs.tf` hote hain — bilkul ek chhota independent Terraform project jaisa. Root project usko "call" karta hai jaise function ko call karte hain.

**Task 5.1 — Sabse simple module banao (1 resource se)**
Ek folder banao `modules/simple-bucket/` aur usme sirf itna likho:
```hcl
# modules/simple-bucket/main.tf
resource "aws_s3_bucket" "this" {
  bucket_prefix = var.prefix
}
```
```hcl
# modules/simple-bucket/variables.tf
variable "prefix" {
  type = string
}
```
Bas itna — koi EC2, IAM kuch nahi, sirf module ka SHAPE samajhna hai.

**Task 5.2 — Root se module ko call karo**
Apni root `main.tf` mein likho:
```hcl
module "logs_bucket" {
  source = "./modules/simple-bucket"
  prefix = "my-app-logs-"
}
```
`terraform init` chalao (naya module hai to init dobara chalana padta hai) — dekho terraform kya download/setup karta hai.

**Task 5.3 — Module se output nikalna seekho**
Module ke andar `outputs.tf` banao jo bucket ka naam return kare:
```hcl
# modules/simple-bucket/outputs.tf
output "bucket_name" {
  value = aws_s3_bucket.this.bucket
}
```
Ab root `output.tf` mein `module.logs_bucket.bucket_name` likh ke print karo. Isse samjhoge module ke andar se value bahar kaise aati hai.

**Task 5.4 — Ab apna Level 2 wala EC2+SG code module banao**
Jo tumne Level 2 mein EC2 + Security Group bina module ke banaya tha, usko `modules/ec2-server/` mein move karo (3 files ke saath). Root se call karo. Ye thoda mushkil lagega — agar atko to bas EC2 wala part pehle module karo, SG baad mein.

✅ **Level 5 pass:** Tumhe pata hona chahiye ki module "kya", "kyu", aur "kaise call hota hai" — bina ye kaha ki "confuse ho gaya".

---

## 🔵 LEVEL 6 — Multiple Environments (Dev/Prod Ka Concept)
**Goal:** Ek hi code se alag-alag environments (dev, staging, prod) manage karna seekhna — bina code duplicate kiye.

**Task 6.1 — Sirf 2 tfvars files banao (koi naya resource nahi)**
Apne existing Level 1 project mein `dev.tfvars` aur `prod.tfvars` banao — dono mein sirf `instance_type` different value do (dev = `t2.micro`, prod = `t2.medium`). Baaki variables same rakho.

**Task 6.2 — `-var-file` flag se apply karna practice karo**
```
terraform plan -var-file="dev.tfvars"
terraform plan -var-file="prod.tfvars"
```
Dono ka `plan` output compare karo — sirf instance_type ka farak dikhna chahiye, baaki sab same.

**Task 6.3 — Environment naam ko tags mein use karo**
Ek naya variable banao `environment` (dev.tfvars mein "dev", prod.tfvars mein "prod"), aur apne resource ke tags mein use karo: `tags = { Environment = var.environment }`. Apply karke AWS console mein tag check karo.

**Task 6.4 — Conditional logic try karo (chhota sa)**
`environment` variable ke basis pe instance_type khud decide karwao (bina tfvars mein likhe):
```hcl
instance_type = var.environment == "prod" ? "t2.medium" : "t2.micro"
```
Ye Terraform ka **ternary operator** hai (`condition ? true_value : false_value`) — dono environment ke liye test karo.

✅ **Level 6 pass:** Tumhe farak samajh aana chahiye — "variable file switch karna" vs "code ke andar logic likhna" — dono alag approach hain same problem ke.

---

## 🟤 LEVEL 7 — Remote State (Team Collaboration Setup)
**Goal:** Samajhna ki state file akele system pe kyu nahi rehni chahiye jab team mein kaam ho raha ho.

> **Pehle samjho PROBLEM kya hai:** Abhi tak tumhara `terraform.tfstate` tumhare computer pe hai. Agar tumhara colleague bhi same project pe kaam kare apne laptop se, uske paas ye state file nahi hogi — Terraform confuse ho jayega ki resources already bane hain ya nahi. Isiliye state ko ek **shared/remote jagah** rakhte hain.

**Task 7.1 — Ek chhota standalone S3 bucket banao (state ke liye)**
Naya, alag chhota project banao jisme sirf ek `aws_s3_bucket` ho jiska naam ho jaise `my-terraform-state-bucket-<tumhara-naam>`. Versioning bhi enable karo (`aws_s3_bucket_versioning` resource se) — taaki purani state files bhi safe rahein.

**Task 7.2 — DynamoDB table banao (locking ke liye)**
```hcl
resource "aws_dynamodb_table" "terraform_lock" {
  name         = "terraform-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
```
Socho: "lock" ka matlab kya hai — agar 2 log same waqt `terraform apply` chalayein to kya hoga agar lock na ho?

**Task 7.3 — Apne Level 1 project ka state migrate karo**
Apne Level 1 wale project mein `provider.tf` ke andar backend block add karo:
```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-<tumhara-naam>"
    key            = "level1/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-lock"
  }
}
```
`terraform init` chalao — Terraform khud poochega "local state ko S3 mein migrate karu?" — Yes karo. Ab apna local `.tfstate` file dekho (khaali ho jayegi).

**Task 7.4 — S3 console mein jaake dekho**
AWS console mein S3 bucket kholo aur apni `terraform.tfstate` file waha dekho. Ise download karke JSON format padhne ki koshish karo — ye wahi cheez hai jo tum shuru mein `terraform.tfstate` file mein dekh chuke ho.

✅ **Level 7 pass:** Tumhe explain karna aana chahiye ki state file akele system pe kyu risky hai, aur S3+DynamoDB combo kya-kya solve karta hai (storage + locking).

---

## ⚫ LEVEL 8 — Loops (Ek Code Se Multiple Resources)
**Goal:** Baar-baar copy-paste kiye bina, ek hi block se multiple similar resources banana.

**Task 8.1 — `count` se sabse simple loop try karo**
```hcl
resource "aws_s3_bucket" "multi" {
  count         = 3
  bucket_prefix = "my-bucket-${count.index}-"
}
```
Apply karo — dekho 3 buckets ban gaye. `count.index` kya hai (0,1,2) samajhna is task ka goal hai.

**Task 8.2 — `count` ke saath list use karo**
```hcl
variable "bucket_names" {
  default = ["logs", "backup", "archive"]
}
resource "aws_s3_bucket" "named" {
  count         = length(var.bucket_names)
  bucket_prefix = "${var.bucket_names[count.index]}-"
}
```
`length()` function kya karta hai socho, aur `var.bucket_names[count.index]` kaise har baar list ka agla item uthata hai.

**Task 8.3 — Ab `for_each` try karo (count se better hai kai jagah)**
```hcl
variable "bucket_names" {
  default = ["logs", "backup", "archive"]
}
resource "aws_s3_bucket" "named2" {
  for_each      = toset(var.bucket_names)
  bucket_prefix = "${each.value}-"
}
```
Same result Task 8.2 jaisa, lekin `each.value` use hua `count.index` ki jagah. Docs mein padho `count` vs `for_each` mein kab kaunsa use karna chahiye (hint: agar list mein se koi item beech mein hataoge, `count` sab resources reshuffle kar deta hai, `for_each` nahi).

**Task 8.4 — `dynamic` block try karo (advanced — agar time ho)**
Apne Security Group mein multiple ports (22, 80, 443, 8080) ko ek `dynamic "ingress"` block se generate karo, har port ke liye alag `ingress {}` likhne ki jagah:
```hcl
variable "ports" {
  default = [22, 80, 443, 8080]
}
dynamic "ingress" {
  for_each = var.ports
  content {
    from_port   = ingress.value
    to_port     = ingress.value
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

✅ **Level 8 pass:** Tumhe pata hona chahiye kab `count`, kab `for_each`, aur kab `dynamic` use karna hai — teeno ka use-case alag hai, ye interview mein bhi pucha jata hai.

---

## 📌 Extra Tips (Maine Apni Taraf Se Add Kiye)

- **Har level ke baad `terraform destroy` zaroor chalao** — free tier/cost bachane ke liye, aur destroy dekhna bhi seekhne ka hissa hai (dependency reverse order mein kaise delete hoti hai).
- **Error aana normal hai** — jab error aaye, message ko poora padho (Terraform errors kaafi descriptive hote hain), Google karne se pehle khud 2 minute soch ke dekho.
- **Har task ke baad ek line "why" likho** apne notes mein (jaisa tum already Hinglish deep-dive notes banate ho) — "maine X isliye kiya kyunki Y" — isse concept permanently yaad rehta hai.
- **Level 3 ke baad se `terraform fmt` aur `terraform validate` habit bana lo** — professional workflow ka hissa hai.
- Chaho to har level complete hone pe mujhe bata dena — main tumhara code review karke feedback dunga, jaise real code review hota hai.

---

**Ab shuru karo Level 1, Task 1.1 se. Jab ready ho, apna `provider.tf` mujhe dikhana — main check karunga aur agla step guide karunga.**