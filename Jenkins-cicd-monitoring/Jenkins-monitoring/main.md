# ============================================================
# DATA SOURCES: AMI ID
# ============================================================
# Latest Ubuntu 24.04 LTS AMI

- Ye kya hai: data block ka matlab hai — "kuch naya create mat karo, jo already exist karta hai usko sirf READ karo aur reference lo."

## AMI ID kaise mil raha hai (bahut smart trick):
- Canonical (Ubuntu banane wale) apne latest AMI IDs ko AWS Systems Manager (SSM) Parameter Store mein publish karte hain — ek fixed public path pe.
- /aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id — ye path humesha latest Ubuntu 24.04 AMI ka current ID return karta hai, region ke hisaab se.
- Isliye variable.tf mein comment likha hai: "AMI ID hardcode nahi kiya, Terraform automatically latest Ubuntu AMI dhundh lega"

# data.aws_vpc.default: 
- Tere account mein AWS jo default VPC deta hai (har region mein ek hota hai), usko reference kar raha hai — taaki naya VPC banane ki zarurat na pade (tera Security Group isi VPC ke andar banega).
- aage hsm security group me bhi yehi use karte hai.

# Real-world use case:
- Production mein hardcoded AMI ID use karna anti-pattern hai kyunki security patches ke saath AMI change hoti rehti hai. 
- SSM parameter use karna matlab har terraform apply pe automatically latest patched AMI milegi.

# Interview Q:
- data block vs resource block? → resource = create/manage karta hai, uska lifecycle Terraform control karta hai. 
- data = sirf read-only, kisi already-existing cheez ki info fetch karta hai, Terraform usko destroy nahi karta.

# Common mistake: 
- Log data.aws_ssm_parameter.ubuntu_ami likh ke seedha .id use kar lete hain — galat hoga, AMI ID .value mein hoti hai, .id mein parameter ka naam/ARN hota hai.


# ============================================================
# S3 BUCKET
# Optional storage for the demo
# ============================================================

# bucket_prefix vs bucket:

- bucket = "my-name" → exact naam deta hai, agar wo naam globally already liya hua hai (S3 bucket names globally unique hote hain), to error aayega.
- bucket_prefix = "jenkins-monitoring-" → Terraform is prefix ke aage random unique suffix khud add kar dega (jaise jenkins-monitoring-20240xyzabc). Isse naming conflict kabhi nahi hota — CI/CD pipelines mein isliye prefix zyada use hota hai.

# aws_s3_bucket_server_side_encryption_configuration
- Ye resource type hai.
- Iska matlab:
"Mujhe AWS S3 bucket ke liye server-side encryption configuration create/configure karni hai."

- Yaani ye naya S3 bucket nahi bana raha.
- Ye existing S3 bucket ke liye encryption setting configure kar raha hai.

# 1. apply_server_side_encryption_by_default
apply_server_side_encryption_by_default {

Iska matlab hai:
“Default encryption automatically enable kar do.”
Matlab tum S3 bucket mein koi file upload karo:

jenkins.log
backup.zip
error.log

to S3 us data ko server-side encryption ke saath store karega.

# 2. sse_algorithm = "AES256"

Ye actually kaunsi encryption technology/algorithm use hogi, wo batata hai.

sse_algorithm = "AES256"

Yahan:

sse = Server-Side Encryption
AES256 = encryption algorithm
AWS S3 data ko AES-256 encryption ke through encrypt karega.


# ============================================================
# IAM ROLE FOR EC2 (Optional: if already done from AWS)
# ============================================================

# Trust Policy (assume_role_policy)
-  → "KAUN ye role use kar sakta hai" — yaha Service = "ec2.amazonaws.com" likha hai matlab sirf EC2 service is role ko assume kar sakti hai, koi user/lambda nahi.

# jsonencode() function:
- HCL object ko valid JSON string mein convert karta hai kyunki AWS IAM policies JSON format mein hi accept karta hai.
- Agar jsonencode na lagao aur raw JSON string likho to syntax error aur maintainability dono kharab ho jaate hain.

# sts:AssumeRole: 
- AWS Security Token Service ka action — temporary credentials generate karta hai jab EC2 instance is role ko "assume" karta hai.
- Ye credentials automatically rotate hote hain (har kuch ghante mein) — isliye hardcoded keys se zyada secure hai.

# Version = "2012-10-17": 
- Ye IAM policy language ka version hai — hamesha yahi fixed date likha jata hai (AWS ka current stable policy schema version). 
- Isse mat ghabrao, ye ek constant hai jo har IAM policy mein aata hai.

# ============================================================
# CLOUDWATCH AGENT POLICY
# ============================================================

# 1. role kya hai?
role = aws_iam_role.jenkins_role.name
> role ka matlab hai:
    - Kis IAM Role ko permission deni hai?

> Tumhare code mein:
aws_iam_role.jenkins_role
    - ye tumhara IAM Role hai.

>Aur: .name
- us role ka naam nikal raha hai.

>Example agar tumne upar likha hai:
resource "aws_iam_role" "jenkins_role" {
  name = "jenkins-role"
}
to:
aws_iam_role.jenkins_role.name

>ka result hoga:
jenkins-role

# 2. policy_arn kya hai?
- Ye thoda important hai.
policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"

- Policy ka matlab hota hai:
Kis-kis kaam ki permission allowed hai?
Aur ARN ka matlab hai Amazon Resource Name.

arn : aws : iam :  : aws : policy
│     │     │     │    │     │
│     │     │     │    │     └── Resource  (Ye batata hai ki jis resource ko identify kiya ja raha hai, wo IAM policy hai.)
│     │     │     │    └──────── AWS-owned resource (Yahan aws AWS-owned account/resource context ko indicate karta hai.)
│     │     │     └───────────── Account ID (yahan empty)
│     │     └─────────────────── AWS IAM service (Ye batata hai ki resource IAM service se related hai.)
│     └───────────────────────── AWS partition  (Normal AWS resources ke liye generally)
└─────────────────────────────── ARN (YE siimple data batata hai)

# : :  -->
- IAM resources generally kisi particular region se tied nahi hote, isliye yahan region blank hai, Isliye tumhe: iam::aws dikh raha hai.

# arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy
ka matlab:
AWS IAM service ke andar AWS-managed CloudWatchAgentServerPolicy policy.

# ============================================================
# EC2 INSTANCE PROFILE
# ============================================================

# Confusion clear karta hu (bahut common interview trap): 
- IAM Role directly EC2 instance pe attach nahi hota — beech mein Instance Profile ek wrapper/container hota hai jo Role ko EC2 tak carry karta hai. 
- Console mein jab tum "IAM Role" select karte ho EC2 launch karte waqt, background mein AWS khud instance profile bana deta hai — Terraform mein tumhe manually banana padta hai.

# Memory trick: 
- "Role = permissions ka set, Instance Profile = wo container jisme role rakh ke EC2 ko diya jata hai" — jaise ID card (role) ko ek lanyard/holder (instance profile) mein daal ke gale mein pehnana.