#!/bin/bash

# Create Instance Profile
aws iam create-instance-profile \
    --instance-profile-name lab-instance-profile-bastion

# Add Role To Profile (instance profile works as a wrapper for a role)
aws iam add-role-to-instance-profile \
    --role-name LabRole \
    --instance-profile-name lab-instance-profile-bastion

# Configure Bastion Host

# Get VPC ID
VPC_ID=$(aws ec2 describe-vpcs \
--query "Vpcs[].VpcId" \
--output text)
echo $VPC_ID

# Create Security Group
aws ec2 create-security-group \
--group-name bastion-host-sg \
--description "security group for bastion host" \
--vpc-id $VPC_ID

# Get Security Group ID
SG_ID=$(aws ec2 describe-security-groups \
--filters "Name=group-name,Values=bastion-host-sg" \
--query 'SecurityGroups[0].GroupId' \
--output text)

echo $SG_ID

# Add Security Group Rule
aws ec2 authorize-security-group-ingress \
--group-id $SG_ID \
--protocol tcp \
--port 22 \
--cidr 0.0.0.0/0

# Launch Bastion Host

# Get Security Group ID
SG_ID=$(aws ec2 describe-security-groups \
--filters "Name=group-name,Values=bastion-host-sg" \
--query 'SecurityGroups[0].GroupId' \
--output text)

echo $SG_ID

# Launch Instance
aws ec2 run-instances \
--image-id ami-02dfbd4ff395f2a1b \
--count 1 \
--instance-type t3.micro \
--region us-east-1 \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=bastion-host}]' \
--security-group-ids $SG_ID \
--key-name vockey \
--iam-instance-profile Name=lab-instance-profile-bastion

# TERMINATE BASTION HOST AND DEPENDENCIES

# Get Instance ID & Terminate
INSTANCE_ID=$(aws ec2 describe-instances \
--filters "Name=tag:Name,Values=bastion-host" \
--query 'Reservations[0].Instances[0].InstanceId' \
--output text --region us-east-1)

echo $INSTANCE_ID

aws ec2 terminate-instances \
--instance-ids $INSTANCE_ID \
--region us-east-1

# Wait for instance to terminate
aws ec2 wait instance-terminated \
--instance-ids $INSTANCE_ID \
--region us-east-1

echo "Deleting security group"

# Delete security group
aws ec2 delete-security-group \
--group-name bastion-host-sg

echo "Web server and security group deleted."

# Remove Profile from Role
aws iam remove-role-from-instance-profile \
--role-name LabRole \
--instance-profile-name lab-instance-profile-bastion

# Delete Instance Profile
aws iam delete-instance-profile \
    --instance-profile-name lab-instance-profile-bastion
