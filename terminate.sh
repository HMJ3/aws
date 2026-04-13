#!/bin/bash

# Configuration
INSTANCE_PROFILE_NAME="lab-instance-profile-webserver"
ROLE_NAME="LabRole"
REGION="us-east-1"
INSTANCE_NAME="web-server"
SG_NAME="web-server-sg"

# Terminate Web Server
echo "Terminating instance"

# Get Instance ID & Terminate
INSTANCE_ID=$(aws ec2 describe-instances \
--filters "Name=tag:Name,Values=$INSTANCE_NAME" \
--query 'Reservations[0].Instances[0].InstanceId' \
--output text --region $REGION)

echo $INSTANCE_ID

aws ec2 terminate-instances \
--instance-ids $INSTANCE_ID \
--region $REGION

echo "Waiting for instance to shutdown"

# Wait for instance to terminate
aws ec2 wait instance-terminated \
--instance-ids $INSTANCE_ID \
--region $REGION

echo "Deleting security group"

# Delete security group
aws ec2 delete-security-group \
--group-name $SG_NAME

echo "Removing role from instance profile"

# Remove role from instance profile
aws iam remove-role-from-instance-profile \
    --role-name $ROLE_NAME \
    --instance-profile-name $INSTANCE_PROFILE_NAME

echo "Deleting instance profile"

# Delete instance profile
aws iam delete-instance-profile \
    --instance-profile-name $INSTANCE_PROFILE_NAME

echo "Web server, security group, and instance profile deleted."
