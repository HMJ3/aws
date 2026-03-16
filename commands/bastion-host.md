# Setup Bastion Host in AWS cloud-shell

´´´
VPC_ID=$(aws ec2 describe-vpcs \
--query "Vpcs[].VpcId" \
--output text)
echo $VPC_ID

aws ec2 create-security-group \
--group-name bastion-host-sg \
--description "security group for bastion host" \
--vpc-id $VPC_ID

SG_ID=$(aws ec2 describe-security-groups \
--filters "Name=group-name,Values=bastion-host-sg" \
--query 'SecurityGroups[0].GroupId'  \
--output text)
echo $SG_ID

aws ec2 authorize-security-group-ingress \
--group-id $SG_ID \
--protocol tcp \
--port 22 \
--cidr 0.0.0.0/0

SG_ID=$(aws ec2 describe-security-groups \
--filters "Name=group-name,Values=bastion-host-sg" \
--query 'SecurityGroups[0].GroupId'  \
--output text)
echo $SG_ID

aws ec2 run-instances \
--image-id ami-02dfbd4ff395f2a1b \
--count 1 \
--instance-type t3.micro \
--region us-east-1 \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=bastion-host}]' \
--security-group-ids $SG_ID \
--key-name vockey
´´´