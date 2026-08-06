# Remote Backend

- Remote backend kyu aaeya wo dekho

## Local State ki Problems
> Problem 1
Sirf ek laptop me state hoti hai.

> Problem 2
Laptop crash ho gaya.
State gayi.

> Problem 3
Team share nahi kar sakti.

> Problem 4
Multiple log apply karenge
Duplicate resources ban sakte hain.

- Production me ye acceptable nahi hai.

## Solution
- State ko laptop me mat rakho.
- State ko kisi common jagah rakho.
- Us common jagah ko kehte hain "Remote Backend"

## Remote Backend
Yani

Laptop
↓
Internet
↓
Common Storage
↓
State File

- Ab sab log wahi state use karenge.

## Backend kya hota hai?
> Backend matlab
- Terraform apni state kahan store karega.

> Default
Local:
terraform.tfstate

> Production
AWS S3
Azure Storage
Terraform Cloud
GCS
Consul

## AWS me kya use hota hai?
- 99% companies S3 use karti hain.
- Aur state locking ke liye DynamoDB

> Flow:
Kaif Laptop
          │
          │
Rahul Laptop
          │
          ▼
AWS S3 Bucket
          │
terraform.tfstate

Sab ek hi state use karenge.

## Backend Configuration
- Ye block Terraform ko batata hai State Local me nahi S3 me rakho.
terraform {
  backend "s3" {

  }
}

> Example
terraform {
  backend "s3" {

    bucket = "kaif-terraform-state"  #yeha per wahi name aaega jo hamne bucket banate time diya tha

    key = "dev/terraform.tfstate"

    region = "ap-south-1"  # hamne bucket jo region me banaeya tha, wahi region backend me bhi aaega

  }
}

### bucket
bucket = "kaif-terraform-state"

- Ye actual AWS S3 Bucket ka naam hai.
Example:
AWS Console
kaif-terraform-state

- Ye bucket pehle se exist honi chahiye.

- Terraform backend configure karte waqt bucket create nahi karta.

- Important: Backend initialize hone se pehle bucket already bani honi chahiye.

### key
- Sabse jyada confusion isi me hota hai.
    key = "dev/terraform.tfstate"

- Ye bucket ka naam nahi hai.
- Ye folder bhi nahi hai.
- Ye sirf S3 ke andar state file ka path hai.

> Example
Bucket:
kaif-terraform-state

- Uske andar
    dev/
    terraform.tfstate

- Actually S3 me real folders nahi hote. Ye object key hoti hai.
- Isliye sirf prefix hote hain.
dev/
prod/
test/

- Tum aise bhi likh sakte ho
    key = "terraform.tfstate"
ya
    key = "production/main.tfstate"
ya
    key = "env/dev/state.tfstate"
- Sab valid hai.


## region
region = "ap-south-1"

- Jis region me bucket bani hai.
Bucket Mumbai me hai
↓
Region bhi Mumbai hi likhna padega.


## Backend initialize kaise hota hai?
- hum jab karenge "terraform init" Terraform puchta hai Backend S3 hai?
- fir bucket connect karega aur fir state upload karega
- Agar pehle local state thi "Terraform bolega"
- Do you want to copy existing state to the new backend?
- yes/no puchega agar ham yes karenge.
- State file S3 me chali jayegi.

