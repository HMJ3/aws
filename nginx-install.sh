#! /bin/basch

#Install NGINX
yum update -y
yum install -y nginx aws-cli

# Sync S3 bucket to web root
aws s3 sync s3://web-bucket67512 /usr/share/nginx/html

systemctl start nginx
systemctl enable nginx

