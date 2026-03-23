

THIS WORKS
Created lab-instance-profile
Attached role
Launch bastion 
Upload files: scp -i labsuser.pem setup-files.zip ec2-user@32.195.48.216:~/
Create S3 bucket - "/web-bucket879457512-new"
Upload to bucket - aws s3 cp /home/ec2-user/setup-files/website/* s3://web-bucket879457512-new/index.html --content-type "text/html"
config web-server
launch web-server

# ── Create Instance Profile ─────────────────────────────────────────────────

aws iam create-instance-profile \
    --instance-profile-name lab-instance-profile

# ── Add Role To Profile (instance profile works as a wrapper for a role) ─────────────────────────────────────────────────────

aws iam add-role-to-instance-profile \
    --role-name LabRole \
    --instance-profile-name lab-instance-profile


# LAUNCH BASTION FROM bastion-host.sh
# CONFIGURE AWS CLI

# DOWNLOAD FILES AS ZIP
# TRANSFER FILES WITH SCP
scp -i labsuser.pem setup-files.zip ec2-user@32.195.48.216:~/
unzip setup-files.zip

# CREATE S3 BUCKET
aws s3api create-bucket \
--bucket web-bucket8797512 \
--region us-east-1

# GET BUCKET NAME
# Copy the bucket name and add to the command below

# UPLOAD FILES TO BUCKET
aws s3 cp setup-files/website/index.html s3://web-bucket8797512/index.html --content-type "text/html"

# CONFIG AND LAUNCH WEB-SERVER from web-server.sh