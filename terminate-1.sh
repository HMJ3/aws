#!/bin/bash

# Terminate Web Server
echo "Terminating instance"

# Get Instance ID & Terminate
INSTANCE_ID=$(aws ec2 describe-instances \
--filters "Name=tag:Name,Values=web-server" \
--query 'Reservations[0].Instances[0].InstanceId' \
--output text --region us-east-1)

echo $INSTANCE_ID

aws ec2 terminate-instances \
--instance-ids $INSTANCE_ID \
--region us-east-1

echo "Waiting for instance to shutdown"

# Wait for instance to terminate
aws ec2 wait instance-terminated \
--instance-ids $INSTANCE_ID \
--region us-east-1

echo "Deleting security group"

# Delete security group
aws ec2 delete-security-group \
--group-name web-server-sg

echo "Web server and security group deleted."



