#!/bin/bash

# ── Create Instance Profile ─────────────────────────────────────────────────

aws iam create-instance-profile \
    --instance-profile-name web-server-profile

# ── Delete Instance Profile ─────────────────────────────────────────────────

aws iam delete-instance-profile \
    --instance-profile-name 'web-server-profile'

# ── Add Profile to Role ─────────────────────────────────────────────────────

aws iam add-role-to-instance-profile \
    --role-name LabRole \
    --instance-profile-name web-server-profile

# ── Remove Profile from Role ────────────────────────────────────────────────

aws iam remove-role-from-instance-profile \
--role-name LabRole \
--instance-profile-name web-server-profile

# ── Attach Role to Running EC2 Instance ────────────────────────────────────

BASTION_ID=$(aws ec2 describe-instances \
--filters "Name=tag:Name,Values=bastion-host" \
--query "Reservations[].Instances[].InstanceId" \
--output text)

echo $BASTION_ID

aws ec2 associate-iam-instance-profile \
  --instance-id $BASTION_ID \
  --iam-instance-profile Name=web-server-profile
