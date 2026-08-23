# Elastic Block Storage (EBS)
- in this lab we will understand to Attach, Create, Format, Mount, Test, Unmount,Remove,Detach The AMAZON EBS Volume on an EC2 Linux Instance

# Step:1 Create AWS EC2 Instance
instance Details:
- EC2 instance: Linux
- Root Disk: 8GB
- Availability Zoni: us-east-1a (it should be same for all)

![EC2 Instance](https://github.com/Nikunj-Java/DevOpsFeb_2026/blob/main/Session-46/images/image-1.png)

- wait till status checks completed to ```3/3 checks passed```
![alt text](https://github.com/Nikunj-Java/DevOpsFeb_2026/blob/main/Session-46/images/image-2.png)

- Connect using AWS CLI
![alt text](https://github.com/Nikunj-Java/DevOpsFeb_2026/blob/main/Session-46/images/image-4.png)

![alt text](https://github.com/Nikunj-Java/DevOpsFeb_2026/blob/main/Session-46/images/image-3.png)

- Get the List of Available Disk
```
lsblk
```
![alt text](https://github.com/Nikunj-Java/DevOpsFeb_2026/blob/main/Session-46/images/image-5.png)

## Step:2 Create Elastic Block Storage Volume(EBS Volume)
- Go to: left Navigation Menu> EBS> Volumes

![alt text](https://github.com/Nikunj-Java/DevOpsFeb_2026/blob/main/Session-46/images/image-6.png)

- Click on ```Create Volume```

- Choose This Setting

    1. Volume Type: gp3 (Gernal purpose SSD (gp3))
    2. Size: 1 Gib
    3. Availability Zone: us-east-1a (Must Be Same as your EC2 Instance)

## Step:3 Attach EBS Volume to EC2
__Note:__ Make Sure Your EC2 Instance and EBS volume Must be in a Same AZ's, if they are in different AZ, You Won't be able to Attach the Volume to EC2 Instance

- click on Volume > Action > Attach Volume

- choose your instance

- choose device name
![alt text](https://github.com/Nikunj-Java/DevOpsFeb_2026/blob/main/Session-46/images/image-13.png)

- goto> EC2 Instance> Storage>

- scroll down and check the list of EBS, You will see the newly added EBS

- check using AWS CLI
```
lsblk
```
![alt text](https://github.com/Nikunj-Java/DevOpsFeb_2026/blob/main/Session-46/images/image-16.png)

## Step:4 Format the EBS Volume

- Format it with ```ext4``` filesystem:
```
sudo mkfs -t ext4 /dev/nvme1n1
```
![alt text](https://github.com/Nikunj-Java/DevOpsFeb_2026/blob/main/Session-46/images/image-17.png)

verify the Filesystem
```
lsblk -f
```

![alt text](https://github.com/Nikunj-Java/DevOpsFeb_2026/blob/main/Session-46/images/image-18.png)

## Step:5 Create a Mount Point
- Create a directory called ```/data```

```
sudo mkdir /data
```

- Mount The EBS Volume

```
sudo mount /dev/nvme1n1 /data
```
- verify the mount with:
```
df -h
```
![alt text](https://github.com/Nikunj-Java/DevOpsFeb_2026/blob/main/Session-46/images/image-19.png)

- output
```
/dev/nvme1n1      974M   24K   907M   1%   /data
```

## Step:6 Test the EBS Volume
- create a test file on the mounted EBS Volume
```
echo "Hello From EBS" | sudo tee /data/test.txt
```
- Read the file
```
cat /data/test.txt
```
O/P:- Hello From EBS

## Step:7 Unmount Disk
```
sudo umount /data
```
Now Try to Read Data
```
cat /data/test.txt
```
Output:
```
cat: /data/test.txt: No such file or directory
```
## Step:8 Mount The Disk
```
sudo mount /dev/nvme1n1 /data
```
Now Try to Read Data
```
cat /data/test.txt
```

## Step: 9 Detach The Volume
- Go to: volumes>action>Detach Volume

- Go to: EC2 Instance>Storage>
__Note:__ here the latest EBS Volume is now No Longer Exist

## Step:10 Create A Snapshot
- What is Snapshot?
```
> it is a backup of the EBS volume at that point/ time
> used for Recovery Or Disaster management
```
- Go to: EBS Volumes> actions> snapshot
![alt text](https://github.com/Nikunj-Java/DevOpsFeb_2026/blob/main/Session-46/images/image-24.png)

![alt text](https://github.com/Nikunj-Java/DevOpsFeb_2026/blob/main/Session-46/images/image-26.png)

- Goto> AWS CLI> Create another File 
```
echo "This file exists after snapshot" | sudo tee /data/after-snapshot.txt
```
- Then:
```
ls -l /data
```
![alt text](https://github.com/Nikunj-Java/DevOpsFeb_2026/blob/main/Session-46/images/image-27.png)

## Step:11 Create Volume From SnapShot
- Go to> EBS>Snapshot>Create Volume From SnapShot
![alt text](https://github.com/Nikunj-Java/DevOpsFeb_2026/blob/main/Session-46/images/image-28.png)

![alt text](https://github.com/Nikunj-Java/DevOpsFeb_2026/blob/main/Session-46/images/image-32.png)

![alt text](https://github.com/Nikunj-Java/DevOpsFeb_2026/blob/main/Session-46/images/image-33.png)

- Go to> AWS CLI> lsblk
![alt text](https://github.com/Nikunj-Java/DevOpsFeb_2026/blob/main/Session-46/images/image-34.png)
so here ```nvme3n1``` is the New Volume From Sanpshot

- run
```
lsblk -f
```
## Step:12 Mount The Restored Volume
- create another mount point
```
sudo mkdir /restore
```
```
sudo mount /dev/nvme3n1 /restore
```
```
df -h
```
![alt text](https://github.com/Nikunj-Java/DevOpsFeb_2026/blob/main/Session-46/images/image-35.png)

if you will see this carefully you will get previously loaded(Backup) data  here

![alt text](https://github.com/Nikunj-Java/DevOpsFeb_2026/blob/main/Session-46/images/image-36.png)