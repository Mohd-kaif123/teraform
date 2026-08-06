|--- provider.tf (isme provider dete hai jaise aws)
|--- s3.tf (isme s3 bucket create karte hai)
|--- terraform.tf ( isme ham provider aur specific version dete hai 
                    jo hame chaiye hota hai fir hame terraform init karne per wahi version milta hai)
|
|--- dynomodb.tf (yehi file se hamara LOCK ID banta hai)
|

--> fir ye charo file banane ke baad wahi porane cmd run karne hai
     - terraform init
     - terraform plan
     - terraform apply

- Fir ye apply karne ke baad
AWS me S3 Bucket "kaif-terraform-state-20260806"

Aur

DynamoDB me "terraform-lock-table"

ban jayega.

# Ab Bootstrap Project ka kaam khatam
- Ye project dobara kabhi use nahi karte.
- Ye sirf backend resources create karne ke liye tha.

# Ab Real Project Banega
- Ab doosra folder banao.
>terraform-project/
     - provider.tf
     - terraform.tf
     - backend.tf
     - ec2.tf

- Is project me EC2, VPC, IAM, S3 ya jo bhi resources manage karne hain wo rahenge.

## Backend Configuration
backend.tf

terraform {

  backend "s3" {

    bucket = "kaif-terraform-state-20260806"

    key = "dev/terraform.tfstate"

    region = "ap-south-1"

    dynamodb_table = "terraform-lock-table"

    encrypt = true
  }
}

- Ab bucket aur table already exist karte hain, isliye:

terraform init

successfully backend initialize karega.

## Sabse pehle ye yaad rakho
> s3.tf:
resource "aws_s3_bucket" "terraform_state" {

  bucket = "kaif-terraform-state-20260806"

}
- Yahan AWS me actual bucket bani.
- Uska naam tha: kaif-terraform-state-20260806

- Ab ye bucket AWS Console me bhi dikhegi.

AWS Console
      │
      ▼
      S3
      │
      ▼
  Buckets
      │
      ▼
kaif-terraform-state-20260806

- Ab backend me hum wahi naam likhte hain.
bucket = "kaif-terraform-state-20260806"

Yani

"Terraform, meri state is bucket me rakhna."

> Refion:
- Jo region me hamne bucket banai thi, wahi region ham backend me bhi denge

> DynamoDB Table
- Jo naam hamne dynomodb.tf file me diya tha wahi naam idhar bhi denge
- Backend me hum wahi naam likhte hain.

"Locking ke liye ye table use karna."

> key = "dev/terraform.tfstate"
Iska S3 Bucket se koi lena dena nahi hai.

Ye DynamoDB ka naam bhi nahi hai.

Ye sirf batata hai

State file bucket ke andar kis naam se save hogi.

> Encrypt
encrypt = true

- Iska matlab State file ko S3 me Encrypted store karo.
- AWS automatically encryption laga deta hai.
- Production me almost hamesha encrypt = true likhte hain.

# Ye sari values kaha se aayi?
> manlo ek project folder hai
project_folder
|
|--- s3.tf (Bucket create, Bucket Name)
|--- DynomoDB.tf (dynomodb create, terraform-lock-table)
|--- provider.tf (region, aws)

--> Hamne Sari values lii hai in teeno files se "Remote Backend" le liye.

> Ab ham agar dusra terminal open karenge aur waha se agar ham chaenge instance ya kuch bhi create karne ke liye tu ham nahi kar paenge.
> Kyu ki state lock hai isliye, hamne dynomodb table per lock lagaeya hai isliye.
> jab tak wo pahaela wala user kaam complete nahi kar leta tab tak dusra user kuch nahi kar sakta.