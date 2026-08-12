# ============================================================
# CLOUDWATCH LOG GROUP
# ============================================================

# Log Group kya hai: 
- CloudWatch Logs mein ek "container/folder" hota hai jaha related logs group hoke store hote hain. 
- Naming convention /service/purpose follow karta hai (jaise /jenkins/logs, /aws/lambda/function-name).

# retention_in_days = 7: 
- Kitne din tak logs store rahenge, uske baad AWS automatically delete kar deta hai (cost control ke liye). 
- Agar ye field na do to default = never expire (forever store hoga → cost badhta rahega).

# ============================================================
# EC2 INSTANCE
# ============================================================

# 1. iam_instance_profile
iam_instance_profile = aws_iam_instance_profile.jenkins_profile.name

Iska kaam hai:
- EC2 instance ko IAM Role dena, taaki EC2 AWS ki services ke saath permission ke according kaam kar sake.

# 2. associate_public_ip_address = true
associate_public_ip_address = true

Iska matlab:
- EC2 instance ko public IP address automatically assign karo.

# user_data: 
- Ye script hai jo EC2 instance pehli baar boot hote waqt automatically (root user ke through) run hoti hai. 
- Isko "bootstrapping" bolte hain — bina manually SSH karke commands chalaye, server apne aap configure ho jata hai.

# Java Install (Line by Line):
> apt-get update -y 
→ Ubuntu ke package repository index refresh karta hai (latest package versions ka pata chale)

> openjdk-21-jre 
→ Jenkins ko chalane ke liye Java Runtime chahiye (Jenkins JVM pe chalta hai, Java 21 is latest LTS-compatible version)

> fontconfig 
→ Jenkins UI ke kuch graphs/charts render karne ke liye font libraries chahiye hoti hain

> java -version 
→ sirf verification ke liye, install sahi hua ya nahi confirm karta hai (script fails silently nahi hota agar ye galat ho, bas output show hota hai)

> mkdir -p /etc/apt/keyrings 
→ Modern Debian/Ubuntu convention hai GPG keys yaha rakhne ki (purana tarika apt-key add tha, jo deprecated ho chuka hai)

> curl -fsSL <jenkins-key-url> | tee <path> 
→ Jenkins ki official GPG signing key download karke file mein save karta hai. 
- Ye key isliye zaruri hai kyunki jab hum third-party repo (Jenkins ka) add karte hain, Ubuntu verify karta hai ki package genuine hai ya tampered — signature match karke.

> echo "deb [signed-by=...] <repo-url> binary/" | tee /etc/apt/sources.list.d/jenkins.list 
→ Ye line Ubuntu ke package manager ko batati hai "yaha se bhi packages dhundo" — ek naya repository source add ho gaya

> apt-get update -y (dobara) 
→ Naya Jenkins repo add hone ke baad index phir se refresh karna zaruri hai, warna Jenkins package "not found" milega

> apt-get install -y jenkins 
→ Ab Jenkins actually install ho raha hai

> systemctl enable jenkins 
→ Boot pe automatically start ho, agar instance restart ho jaye

> systemctl start jenkins 
→ Abhi ke liye start karo

> Common mistake: 
- Log apt-get install jenkins pehle hi try kar dete hain repo add kiye bina — "package not found" error aata hai. 
- Sequence important hai: key → repo → update → install.

# "YML-type" Code (Actually ye JSON hai — CloudWatch Agent Config):

> amazon-cloudwatch-agent package install 
→ ye actual agent hai jo logs/metrics CloudWatch tak bhejta hai

## Config file structure:
> "agent" block 
→ agent ka general behavior 
    (metrics_collection_interval: 60 = har 60 second mein metrics collect karega)

> "logs.logs_collected.files.collect_list" 
→ KAUNSI files monitor karni hain ye list hai

> file_path 
→ local server pe log file ka path (/var/log/jenkins/jenkins.log)

> log_group_name 
→ CloudWatch mein kaunse Log Group mein bhejna hai — dekho, ye same naam hai jo humne Terraform mein aws_cloudwatch_log_group mein banaya (/jenkins/logs) — dono match hone chahiye!

> log_stream_name = "{instance_id}" 
→ Ek Log Group ke andar multiple "streams" ho sakte hain (agar multiple instances hon), {instance_id} ek dynamic placeholder hai jo agent khud actual instance ID se replace karta hai

> amazon-cloudwatch-agent-ctl 
command: Agent ko config file ke saath start/fetch karta hai
- -a fetch-config → action = naya config fetch karo
- -m ec2 → mode = EC2 pe chal raha hai (vs on-premise)
- -c file:<path> → config file kaha se le
- -s → agent ko immediately start bhi kar do

# Interview Q: CloudWatch Agent install karne ke liye IAM role kyu chahiye?
- → Agent ko AWS APIs call karni padti hain (metrics/logs push karne ke liye), aur EC2 pe koi hardcoded credentials nahi hote — isliye instance profile (jo humne section 9 mein banaya) use karta hai.



