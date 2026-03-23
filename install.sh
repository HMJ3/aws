# ── Configure Storage and Permissions ────────────────────────────────────────────────────

# Create S3 Bucket - upload files
aws s3api create-bucket \
    --bucket web-bucket879457512-new \
    --region us-east-1

# Create Instance Profile
aws iam create-instance-profile \
    --instance-profile-name lab-instance-profile

# Attach Instance Profile To Role (LabRole)
aws iam add-role-to-instance-profile \
    --role-name LabRole \
    --instance-profile-name lab-instance-profile

# ── Configure Web Server ────────────────────────────────────────────────────

# Get VPC ID
VPC_ID=$(aws ec2 describe-vpcs \
--query "Vpcs[].VpcId" \
--output text)
echo $VPC_ID

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

echo $SG_ID

# Add Security Group Rule
aws ec2 authorize-security-group-ingress \
--group-id $SG_ID \
--protocol tcp \
--port 80 \
--cidr 0.0.0.0/0

# ── Launch Web Server ───────────────────────────────────────────────────────

# Get Security Group ID
SG_ID=$(aws ec2 describe-security-groups \
--filters "Name=group-name,Values=web-server-sg" \
--query 'SecurityGroups[0].GroupId' \
--output text)

echo $SG_ID

# Launch Instance
aws ec2 run-instances \
--image-id ami-02dfbd4ff395f2a1b \
--count 1 \
--instance-type t3.micro \
--region us-east-1 \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=web-server}]' \
--security-group-ids $SG_ID \
--key-name vockey \
--iam-instance-profile Name=lab-instance-profile \
--user-data file://nginx-install.sh
