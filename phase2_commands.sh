#!/bin/bash

# Replace these values before running:
# YOUR_INSTANCE_ID  = i-0abc123def456789
# YOUR_REGION       = us-east-1
# YOUR_TOPIC_ARN    = the ARN printed after you create the topic

# 1. Create the SNS topic
aws sns create-topic \
    --name phase2-alerts \
    --region YOUR_REGION

# 2. Subscribe your email (paste the TopicArn from step 1)
aws sns subscribe \
    --topic-arn YOUR_TOPIC_ARN \
    --protocol email \
    --notification-endpoint henrik.einola@gmail.com \
    --region YOUR_REGION

# Go to your email and click the confirmation link before continuing

# 3. High CPU alarm
aws cloudwatch put-metric-alarm \
    --alarm-name EC2-HighCPU \
    --metric-name CPUUtilization \
    --namespace AWS/EC2 \
    --statistic Average \
    --period 300 \
    --evaluation-periods 1 \
    --threshold 70 \
    --comparison-operator GreaterThanThreshold \
    --dimensions Name=InstanceId,Value=YOUR_INSTANCE_ID \
    --alarm-actions YOUR_TOPIC_ARN \
    --region YOUR_REGION

# 4. Status check alarm
aws cloudwatch put-metric-alarm \
    --alarm-name EC2-StatusCheckFailed \
    --metric-name StatusCheckFailed \
    --namespace AWS/EC2 \
    --statistic Maximum \
    --period 60 \
    --evaluation-periods 2 \
    --threshold 1 \
    --comparison-operator GreaterThanOrEqualToThreshold \
    --dimensions Name=InstanceId,Value=YOUR_INSTANCE_ID \
    --alarm-actions YOUR_TOPIC_ARN \
    --region YOUR_REGION
