# ============================================================
# CLOUDWATCH METRIC FILTER
# ============================================================

# Concept (bahut important — real monitoring interview topic):
- CloudWatch Logs raw text hoti hai — usko directly alarm mein use nahi kar sakte. 
- Metric Filter raw logs ko scan karke matching pattern milne pe ek numeric metric create kar deta hai.

    > log_group_name 
        → kaunse log group ko scan karna hai (same jo humne banaya)

    > pattern = "ERROR" 
        → jab bhi koi log line mein "ERROR" word aayega, ye filter trigger hoga

    > metric_transformation:
       > name = "JenkinsErrorCount" 
            → naye metric ka naam
       > namespace = "JenkinsApp" 
            → CloudWatch mein metrics ek "namespace" ke andar organize hote hain (custom folder jaisa)
       > value = "1" 
            → har match pe counter mein +1 add karo
       > default_value = 0 
            → agar koi match na ho to metric ki value 0 rahegi (missing data se bachne ke liye)


# Execution Flow (poore project ka):
Jenkins log file mein "ERROR" likha jata hai
        ↓
CloudWatch Agent file ko poll karta hai (config.json ke through)
        ↓
Log line CloudWatch Logs (/jenkins/logs group) mein bhej di jati hai
        ↓
Metric Filter pattern "ERROR" match karta hai
        ↓
JenkinsErrorCount metric mein +1 increment hota hai
        ↓
CloudWatch Alarm har 60 sec mein Sum check karta hai
        ↓
Agar Sum > 5 ho jaye 1 minute mein → Alarm state = ALARM
        ↓
SNS Topic ko notify kiya jata hai
        ↓
Email subscriber (tera email) ko alert mil jata hai


# ============================================================
# SNS TOPIC and SNS EMAIL SUBSCRIPTION
# ============================================================
- SNS Topic = ek "broadcast channel" — jisko bhi is channel pe kuch bhejo, saare subscribers ko notification milegi

- Subscription = var.email (tera email mansoorikaif365@gmail.com) is topic ko subscribe kar raha hai email protocol se

# ============================================================
# CLOUDWATCH ALARM
# ============================================================

> namespace + metric_name 
→ same jo Metric Filter mein define kiya tha (yaha match hona zaruri hai, warna alarm kabhi trigger nahi hoga)

> comparison_operator = "GreaterThanThreshold" + threshold = 5 
→ matlab "jab value 5 se zyada ho jaye"

> period = 60, evaluation_periods = 1 
→ har 60-second window mein 1 baar check karo

> statistic = "Sum" 
→ us 60-sec window ke andar saare error counts add karo

> alarm_actions 
→ alarm trigger hone pe kya karna hai (SNS ko notify)

> ok_actions 
→ jab alarm wapas normal ho jaye (OK state), tab bhi notify karo (recovery notification)
> treat_missing_data = "notBreaching" 
→ agar koi data hi nahi aaya (metric missing), to usko "problem nahi hai" treat karo — false alarms se bachne ke liye

> depends_on 
→ explicitly bata raha hai ki Alarm banane se pehle Metric Filter zarur ban chuka ho (implicit dependency already hai reference se, ye extra safety hai)