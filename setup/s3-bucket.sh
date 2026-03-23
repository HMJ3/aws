#!/bin/bash

# ── Create S3 Bucket ────────────────────────────────────────────────────────
# Note: index.html will be uploaded manually after bucket creation
# Note: bash script will be uploaded manually if AWS CloudShell is being used
# if bastion host is in use, files can be uploaded via CLI

aws s3api create-bucket \
--bucket web-bucket8797512 \
--region us-east-1
