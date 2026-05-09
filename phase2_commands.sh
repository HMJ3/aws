#!/bin/bash

# Replace these values before running:
# YOUR_INSTANCE_ID  = i-0842c143351e4cf44
# YOUR_REGION       = us-east-1
# YOUR_TOPIC_ARN    = arn:aws:sns:us-east-1:281639314457:phase2-alerts

# 1. Create the SNS topic
aws sns create-topic \
    --name phase2-alerts \
    --region us-east-1

# 2. Subscribe your email (paste the TopicArn from step 1)
aws sns subscribe \
    --topic-arn arn:aws:sns:us-east-1:281639314457:phase2-alerts \
    --protocol email \
    --notification-endpoint henrik.einola@gmail.com \
    --region us-east-1

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
    --dimensions Name=InstanceId,Value=i-0842c143351e4cf44 \
    --alarm-actions arn:aws:sns:us-east-1:281639314457:phase2-alerts \
    --region us-east-1

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
    --dimensions Name=InstanceId,Value=i-0842c143351e4cf44 \
    --alarm-actions arn:aws:sns:us-east-1:281639314457:phase2-alerts \
    --region us-east-1
