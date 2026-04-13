#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set Server Name
INSTANCE_NAME="web-server-1"

# Settings
INSTANCE_PROFILE_NAME="LabInstanceProfile"
ROLE_NAME="LabRole"
REGION="us-east-1"
IMAGE_ID="ami-02dfbd4ff395f2a1b"
INSTANCE_TYPE="t3.micro"
SG_NAME="web-server-sg"
SG_DESCRIPTION="security group for web server"
KEY_NAME="vockey"
SSM_DOCUMENT="AWS-RunShellScript"
NGINX_WEB_ROOT="/usr/share/nginx/html"

# Add Role To Profile
aws iam add-role-to-instance-profile \
    --role-name $ROLE_NAME \
    --instance-profile-name $INSTANCE_PROFILE_NAME

# Create S3 Bucket
BUCKET_NAME="web-bucket-$(openssl rand -hex 6)"
echo "Bucket name: $BUCKET_NAME"

aws s3api create-bucket \
    --bucket $BUCKET_NAME \
    --region $REGION

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
    --group-name $SG_NAME \
    --description "$SG_DESCRIPTION" \
    --vpc-id $VPC_ID

# Get Security Group ID
SG_ID=$(aws ec2 describe-security-groups \
    --filters "Name=group-name,Values=$SG_NAME" \
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
    --image-id $IMAGE_ID \
    --count 1 \
    --instance-type $INSTANCE_TYPE \
    --region $REGION \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_NAME}]" \
    --security-group-ids $SG_ID \
    --key-name $KEY_NAME \
    --iam-instance-profile Name=$INSTANCE_PROFILE_NAME \
    --user-data file://$SCRIPT_DIR/nginx-install.sh

# Get instance ID
INSTANCE_ID=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=$INSTANCE_NAME" "Name=instance-state-name,Values=running" \
    --query "Reservations[0].Instances[0].InstanceId" \
    --output text)

# Wait for instance to be ready
aws ec2 wait instance-status-ok --instance-ids $INSTANCE_ID

# Sync S3 bucket to nginx web root
aws ssm send-command \
    --instance-ids $INSTANCE_ID \
    --document-name "$SSM_DOCUMENT" \
    --parameters "commands=['aws s3 sync s3://$BUCKET_NAME $NGINX_WEB_ROOT']"

    aws ssm send-command \
    --instance-ids $INSTANCE_ID \
    --document-name "$SSM_DOCUMENT" \
    --parameters "commands=['aws s3 sync s3://$BUCKET_NAME $NGINX_WEB_ROOT']"