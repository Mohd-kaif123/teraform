# Scenario:-
## Problem agar tfstate local me rakho
### Maan lo tumhare paas ye folder hai

terraform-project/

main.tf
variables.tf
terraform.tfstate
terraform.tfstate.backup

### Ab problem kya hai?

- Suppose Team me 3 log hain

Kaif
Rahul
Aman

- Sab EC2 create karte hain.

Kaif
terraform apply

- Local tfstate update ho gaya.

Ab Rahul bhi

terraform apply

Rahul ke paas purana tfstate hai.

Usne apply kar diya.

Ab Terraform confuse ho jayega.

Resource duplicate ban sakte hain.

Delete ho sakte hain.

Infrastructure corrupt ho sakta hai.

Isi problem ko solve karne ke liye

Remote Backend

use hota hai.

# problem 1: 
- ham .tfstate file ko commit nahi kar sakte github me

# problem 2:
- aur jaise 2 logo ke pass access mai 2 instance bana raha hu aur dusra banda 3 tu conflict hota hai isko bolte hai state conflict.

> isliye hame ek common secure state file banani hogi
- aur ye file ko duur ek secure locaion per rakhenge jisko bolte hai remote backend

# Remote Backend:-
Developer

↓

terraform apply

↓

Terraform

↓

S3 bucket

↓

terraform.tfstate update

- ye bolta hai aap apni ye file ko S3 bucket me rakho.
- lekin sirf bucket me rakhne se fayeda nahi hoga kyu koi bhi jiske pass hamara aws ka acces hai agar wo pahale acces kara s3 ko tu apne hisab se change kar sakta hai
- Isliye hamko karna hai padega state file locking use karenge dynomo Db ka 

## Lekin ek aur problem
- Suppose

> Kaif_user ne kiya :-
terraform apply

> Rahul bhi Same time kar raha hai:-
terraform apply

- Ab kya hoga?
- Dono ek hi tfstate edit karenge.

> Imagine Excel file

2 log same row edit kar rahe hain.

Conflict.

State corrupt.

Isi liye

Terraform Lock use karta hai.

# Dynomo DB
- Dynomo DB ek database hai aur table aur coloumn wala system nahi raheta sql jaisa, simple se key aur value wala system hota hai.

- DynamoDB secrets store nahi karta.
- DynamoDB ka kaam sirf state locking hai.
- Secrets ko store karne ke liye AWS Secrets Manager, AWS Systems Manager 
- Parameter Store, ya Vault use kiya jata hai. 

## State Locking
- Terraform apply start hote hi
- DynamoDB me ek lock create hota hai.
> Example

Terraform Apply
↓
Check DynamoDB
↓
Lock hai?
↓
YES
↓
Error
Another operation is running.

> Agar lock nahi hai
Terraform Apply
↓
Create Lock
↓
Apply Infrastructure
↓
Update tfstate
↓
Delete Lock

- Ye poora process automatic hota hai.

## DynamoDB kya store karta hai?
- Ye resources nahi rakhta.
- Ye state bhi nahi rakhta.
- Ye sirf lock rakhta hai.

> Example:-
- Table:
terraform-lock

- Column:
LockID

- Value:
terraform-state-prod

Bas.

