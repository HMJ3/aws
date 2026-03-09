# These are commands to be run in AWS CLI 

### Get VPC-ID
```
VPC_ID=$(aws ec2 describe-vpcs \
--query "Vpcs[].VpcId" \
--output text)

echo $VPC_ID
```
### Create Security Group
```
aws ec2 create-security-group \
--group-name web-server-sg \
--description "security group for web server" \
--vpc-id vpc-07402b7fc0701cebb
```
### Get SG-ID
```
SG_ID=$(aws ec2 describe-security-groups \
--filters "Name=group-name,Values=web-server-sg" \
--query 'SecurityGroups[0].GroupId'  \
--output text)

echo $SG_ID
```
### Create new inbound rule
```
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
--output text \
--region us-east-1)

echo $INSTANCE_ID

aws ec2 terminate-instances \
--instance-ids $INSTANCE_ID \
--region us-east-1
```




