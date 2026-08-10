# variable structure 
- type → Data type enforce karta hai (string/number/list/map). Galat type doge to terraform plan pe hi error aa jayega.

- default → Agar koi value nahi di gayi to ye fallback use hoga


# variable values:-
- aws_region aur instance_type mein default hai → optional (na bhi do to chalega)
- key_name aur email mein default nahi hai → ye mandatory hain. Agar tfvars mein na do, Terraform terminal pe interactively pooch lega.

# Values kaha se aati hain? (Priority Order — VERY IMPORTANT for interview)

1) -var command line flag (highest priority)
2) -var-file flag
3) terraform.tfvars file (auto-loaded — yahi tera case hai)
4) *.auto.tfvars files
5) Environment variables (TF_VAR_key_name)
6) default value in variable.tf (lowest priority)

- Memory trick: "CLI > File > Auto > Env > Default" — jitna zyada explicit, utni zyada priority.

- Effect of removing type: Terraform apne aap infer kar lega, lekin best practice hai explicit type dena — galat data pass hone se bachne ke liye.