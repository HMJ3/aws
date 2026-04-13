#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Configuration
INSTANCE_NAME="${1:-web-server}"
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

echo "==> Launching web server: $INSTANCE_NAME"

# Add Role To Profile
echo "==> Attaching role '$ROLE_NAME' to instance profile '$INSTANCE_PROFILE_NAME'..."
EXISTING_ROLE=$(aws iam get-instance-profile \
    --instance-profile-name $INSTANCE_PROFILE_NAME \
    --query "InstanceProfile.Roles[?RoleName=='$ROLE_NAME'].RoleName" \
    --output text 2>/dev/null)
if [ -z "$EXISTING_ROLE" ]; then
    aws iam add-role-to-instance-profile \
        --role-name $ROLE_NAME \
        --instance-profile-name $INSTANCE_PROFILE_NAME
else
    echo "    Role already attached, skipping."
fi

# Create S3 Bucket
BUCKET_NAME="web-bucket-$(openssl rand -hex 6)"
echo "==> Creating S3 bucket: $BUCKET_NAME"

aws s3api create-bucket \
    --bucket $BUCKET_NAME \
    --region $REGION

# Upload index.html to Bucket
echo "==> Uploading index.html to s3://$BUCKET_NAME..."
aws s3 cp $SCRIPT_DIR/index.html s3://$BUCKET_NAME/index.html \
    --content-type "text/html"

# Get VPC ID
echo "==> Fetching default VPC ID..."
VPC_ID=$(aws ec2 describe-vpcs \
    --query "Vpcs[].VpcId" \
    --output text)
echo "    VPC ID: $VPC_ID"

# Create Security Group
echo "==> Checking if security group '$SG_NAME' exists..."
SG_ID=$(aws ec2 describe-security-groups \
    --filters "Name=group-name,Values=$SG_NAME" \
    --query 'SecurityGroups[0].GroupId' \
    --output text 2>/dev/null)
if [ -z "$SG_ID" ] || [ "$SG_ID" = "None" ]; then
    echo "    Security group not found, creating..."
    aws ec2 create-security-group \
        --group-name $SG_NAME \
        --description "$SG_DESCRIPTION" \
        --vpc-id $VPC_ID
    SG_ID=$(aws ec2 describe-security-groups \
        --filters "Name=group-name,Values=$SG_NAME" \
        --query 'SecurityGroups[0].GroupId' \
        --output text)
else
    echo "    Security group already exists, skipping."
fi
echo "    Security Group ID: $SG_ID"

# Allow HTTP traffic
echo "==> Checking if HTTP (port 80) ingress rule exists..."
HTTP_RULE=$(aws ec2 describe-security-groups \
    --group-ids $SG_ID \
    --query "SecurityGroups[0].IpPermissions[?FromPort==\`80\` && ToPort==\`80\` && IpProtocol=='tcp'].FromPort" \
    --output text 2>/dev/null)
if [ -z "$HTTP_RULE" ] || [ "$HTTP_RULE" = "None" ]; then
    echo "    Adding HTTP ingress rule..."
    aws ec2 authorize-security-group-ingress \
        --group-id $SG_ID \
        --protocol tcp \
        --port 80 \
        --cidr 0.0.0.0/0
else
    echo "    HTTP ingress rule already exists, skipping."
fi

# Launch Web Server
echo "==> Checking if EC2 instance '$INSTANCE_NAME' already exists..."
INSTANCE_ID=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=$INSTANCE_NAME" "Name=instance-state-name,Values=running,pending" \
    --query "Reservations[0].Instances[0].InstanceId" \
    --output text 2>/dev/null)
if [ -z "$INSTANCE_ID" ] || [ "$INSTANCE_ID" = "None" ]; then
    echo "    Instance not found, launching..."
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
    INSTANCE_ID=$(aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=$INSTANCE_NAME" "Name=instance-state-name,Values=running,pending" \
        --query "Reservations[0].Instances[0].InstanceId" \
        --output text)
else
    echo "    Instance already exists, skipping launch."
fi
echo "    Instance ID: $INSTANCE_ID"

# Wait for instance to be ready
echo "==> Waiting for instance to pass status checks (this may take a few minutes)..."
aws ec2 wait instance-status-ok --instance-ids $INSTANCE_ID
echo "    Instance is ready."

# Sync S3 bucket to nginx web root
echo "==> Syncing S3 bucket to nginx web root on the instance..."
aws ssm send-command \
    --instance-ids $INSTANCE_ID \
    --document-name "$SSM_DOCUMENT" \
    --parameters "commands=['aws s3 sync s3://$BUCKET_NAME $NGINX_WEB_ROOT']"

# Get public IP
PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query "Reservations[0].Instances[0].PublicIpAddress" \
    --output text)

echo ""
echo "=========================================="
echo "  Deployment complete!"
echo "  Public IP: $PUBLIC_IP"
echo "  Access the website here: http://$PUBLIC_IP"
echo "=========================================="

