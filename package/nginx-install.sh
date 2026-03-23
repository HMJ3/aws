#! /bin/bash

# Install NGINX
yum update -y
yum install -y nginx aws-cli

systemctl start nginx
systemctl enable nginx

