#!/bin/bash

# ── Create Instance Profile ─────────────────────────────────────────────────

aws iam create-instance-profile \
    --instance-profile-name lab-instance-profile

# ── Delete Instance Profile ─────────────────────────────────────────────────

aws iam delete-instance-profile \
    --instance-profile-name lab-instance-profile

# ── Add Role To Profile (instance profile works as a wrapper for a role) ─────────────────────────────────────────────────────

aws iam add-role-to-instance-profile \
    --role-name LabRole \
    --instance-profile-name lab-instance-profile

# ── Remove Profile from Role ────────────────────────────────────────────────

aws iam remove-role-from-instance-profile \
--role-name LabRole \
--instance-profile-name lab-instance-profile

# ── Attach Role to Running EC2 Instance ────────────────────────────────────

INSTANCE_ID=$(aws ec2 describe-instances \
--filters "Name=tag:Name,Values=bastion-host" \
--query "Reservations[].Instances[].InstanceId" \
--output text)

echo $INSTANCE_ID

aws ec2 associate-iam-instance-profile \
  --instance-id $INSTANCE_ID \
  --iam-instance-profile Name=lab-instance-profile
