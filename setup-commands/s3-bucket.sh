#!/bin/bash

# Guides
# Upload object to bucket
'https://docs.aws.amazon.com/AmazonS3/latest/userguide/GettingStartedS3CLI.html'

# Create S3 Bucket
# Note: index.html will be uploaded manually after bucket creation
# Note: bash script will be uploaded manually if AWS CloudShell is being used
# if bastion host is in use, files can be uploaded via CLI

aws s3api create-bucket \
--bucket web-bucket8797512 \
--region us-east-1

# Upload index.html
aws s3 cp setup-files/website/index.html s3://web-bucket8797512/index.html --content-type "text/html"
