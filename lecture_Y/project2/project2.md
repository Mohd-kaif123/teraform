# Ab ham terraform ke through kubernetes ka cluster banaenge on EKS(Elastic kuberneter service)

- EKS ka cluster hoga jaha per teen EC2 ke nodes rahenge
- aur ye teen nodes ka kubernetes se cluster rahane wala hai, jo ham banaenge terraform ke through.
- k8s control plane (API server, etcd, shecduler, controller manager) ke through manage karta hai cluster ko
- Agar ye control plane, Aws manage kar raha hai tu ye contol plane aur uske andar nodes, pod, container ye sab EKS(elastic kubernetes service) ke through manage hota hai.

- ab alag alag node ke liye alag EC2 hoga tu wo duno enstance ek dusre se communicate bhi kar sake, isliye indono ke bich VPC bhi bana jarurui hai taki wo duno ec2 apass me baat kar sake.

- EKS ke case me EKS ka naam hota hai cloud Controller manager

- ab ye sara chiz hame terraform ke through karna hai.

- pahale banaenge ek folder "terraform-EKS"
        |
        |-- terraform.tf
        |-- provider.tf
        |-- variable.tf
        |-- vpc.tf
        |-- eks.tf


