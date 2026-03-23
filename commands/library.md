# These are commands to be run in AWS CLI 

### Get VPC-ID
```
aws ec2 create-security-group \
--group-name web-server_sg \
--description "security group for web server" \
--vpc-id vpc-07402b7fc0701cebb
```

### Create Security Group
```
aws ec2 create-security-group \
--group-name web-server_sg \
--description "security group for web server" \
--vpc-id vpc-07402b7fc0701cebb
```

### Get SG-ID
```
SG_ID=$(aws ec2 describe-security-groups \
--filters "Name=group-name,Values=launch-wizard-1" \
--query 'SecurityGroups[0].GroupId'  \
--output text)

echo $SG_ID

### Create new inbound rule
aws ec2 authorize-security-group-ingress \
--group-id $SG_ID \
--protocol tcp \
--port 80 \
--cidr 0.0.0.0/0
```

### Install EC2 Instance
```
aws ec2 run-instances \
--image-id ami-02dfbd4ff395f2a1b \
--count 1 \
--instance-type t3.micro \
--region us-east-1 \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=web-server}]' \
--security-group-ids $SG_ID \
--key-name vockey \
--user-data file://nginx-install.sh
```

### Terminate EC2 Instance
```
INSTANCE_ID=$(aws ec2 describe-instances \
--filters "Name=tag:Name,Values=web-server" \
--query 'Reservations[0].Instances[0].InstanceId' \
--output text --region us-east-1)

echo $INSTANCE_ID

aws ec2 terminate-instances \
--instance-ids $INSTANCE_ID \
--region us-east-1
```

### Create S3 Bucket

[Examples]("https://docs.aws.amazon.com/cli/latest/reference/s3api/create-bucket.html#examples")
[S3-Buckets]("https://docs.aws.amazon.com/AmazonS3/latest/userguide/create-bucket-overview.html")

```
aws s3api create-bucket \
--bucket web-bucket67512 \
--region us-east-1
```
### Create instance profile

Created instances: web-server-profile (16.2.2026)

```
aws iam create-instance-profile \
    --instance-profile-name web-server-profile

Output
{
    "InstanceProfile": {
        "Path": "/",
        "InstanceProfileName": "web-server-profile",
        "InstanceProfileId": "AIPAUDEYC4QMZRDHUNTMN",
        "Arn": "arn:aws:iam::281639314457:instance-profile/web-server-profile",
        "CreateDate": "2026-03-16T11:33:05+00:00",
        "Roles": []
    }
}

```

### Manage Profiles

Source - https://stackoverflow.com/a/72966105

```
# delete instance profile
aws iam delete-instance-profile \
    --instance-profile-name 'web-server-profile'
```

```
# add profile to role
aws iam add-role-to-instance-profile \
    --role-name LabRole \
    --instance-profile-name web-server-profile
```

```
# remove profile from role
aws iam remove-role-from-instance-profile \
--role-name LabRole \
--instance-profile-name web-server-profile
```


### Add to running EC2 instance
```
BASTION_ID=$(aws ec2 describe-instances \
--filters "Name=tag:Name,Values=bastion-host" \
--query "Reservations[].Instances[].InstanceId" \
--output text )

echo $BASTION_ID
```

### Attach role to instance
```
aws ec2 associate-iam-instance-profile \
  --instance-id $BASTION_ID \
  --iam-instance-profile Name=web-server-profile
```

### Final EC2 instance command
```
SG_ID=$(aws ec2 describe-security-groups \
--filters "Name=group-name,Values=web-server-sg" \
--query 'SecurityGroups[0].GroupId'  \
--output text)
echo $SG_ID

aws ec2 run-instances \
--image-id ami-02dfbd4ff395f2a1b \
--count 1 \
--instance-type t3.micro \
--region us-east-1 \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=web-server}]' \
--security-group-ids $SG_ID \
--key-name vockey \
--iam-instance-profile Name=web-server-profile \
--user-data file://nginx-install.sh
```



