terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "5.91.0"
    }
  }
}

# 1. terraform { }
terraform {
}

- Ye Terraform ka main configuration block hai.

- Iske andar Terraform ki settings likhi jaati hain.

## Example:
- Required providers
- Terraform version
- Backend configuration (S3 Remote State)
- Cloud configuration

- Yani ye AWS resources create nahi karta, sirf Terraform ko configure karta hai.

# 2. required_providers
required_providers {
}

## Iska matlab hai:
- "Mere project ko chalane ke liye ye provider chahiye."

# 3. source
source = "hashicorp/aws"

- Iska matlab:
AWS Provider kahan se download karna hai.

- hashicorp/aws--Yahan se karna hai download:
- hashicorp--Provider ka publisher hai.
- aws--Provider ka naam hai.

- Terraform Registry me ye officially available hota hai, Jab hum
"terraform init" chalate ho,

- Terraform internet par jaata hai aur HashiCorp Registry se AWS Provider download karta hai.

Flow:

terraform init
        │
        ▼
Terraform Registry
        │
        ▼
Download AWS Provider
        │
        ▼
.terraform/

# 4. version
version = "5.91.0"

- Iska matlab
    Sirf version 5.91.0 install karo.

- Terraform latest download nahi karega.

- Wahi version download karega jo tumne likha hai.

## Agar version na likho
version = ""

ya

version hata do

- To latest version aa sakta hai.

- Kabhi-kabhi latest version me changes hote hain jisse purana code break ho sakta hai.

- AZZZXIsliye production me version pin karna best practice hota hai.