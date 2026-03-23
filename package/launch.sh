#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create Instance Profile

aws iam create-instance-profile \
    --instance-profile-name lab-instance-profile-webserver

# Add Role To Profile

aws iam add-role-to-instance-profile \
    --role-name LabRole \
    --instance-profile-name lab-instance-profile-webserver

# Create S3 Bucket

BUCKET_NAME="web-bucket-$(openssl rand -hex 6)"
echo "Bucket name: $BUCKET_NAME"

aws s3api create-bucket \
    --bucket $BUCKET_NAME \
    --region us-east-1

# Upload index.html to Bucket

aws s3 cp $SCRIPT_DIR/index.html s3://$BUCKET_NAME/index.html \
    --content-type "text/html"

# Configure Web Server

# Get VPC ID
VPC_ID=$(aws ec2 describe-vpcs \
    --query "Vpcs[].VpcId" \
    --output text)
echo "VPC ID: $VPC_ID"

# Create Security Group
aws ec2 create-security-group \
    --group-name web-server-sg \
    --description "security group for web server" \
    --vpc-id $VPC_ID

# Get Security Group ID
SG_ID=$(aws ec2 describe-security-groups \
    --filters "Name=group-name,Values=web-server-sg" \
    --query 'SecurityGroups[0].GroupId' \
    --output text)
echo "Security Group ID: $SG_ID"

# Allow HTTP traffic
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

# Launch Web Server

aws ec2 run-instances \
    --image-id ami-02dfbd4ff395f2a1b \
    --count 1 \
    --instance-type t3.micro \
    --region us-east-1 \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=web-server}]' \
    --security-group-ids $SG_ID \
    --key-name vockey \
    --iam-instance-profile Name=lab-instance-profile-webserver \
    --user-data file://$SCRIPT_DIR/nginx-install.sh

# Get instance ID
INSTANCE_ID=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=web-server" "Name=instance-state-name,Values=running" \
    --query "Reservations[0].Instances[0].InstanceId" \
    --output text)

# Wait for instance to be ready
aws ec2 wait instance-status-ok --instance-ids $INSTANCE_ID

# Sync S3 bucket to nginx web root
aws ssm send-command \
    --instance-ids $INSTANCE_ID \
    --document-name "AWS-RunShellScript" \
    --parameters "commands=['aws s3 sync s3://$BUCKET_NAME /usr/share/nginx/html']"
