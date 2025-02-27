#!/bin/bash

# Variables
ALB_NAME="my-load-balancer"
TARGET_GROUP_NAME="my-target-group"
VPC_ID="vpc-0c2b11e04270d860e"  # Replace with actual VPC ID
PUBLIC_SUBNETS="subnet-08cd52648363386d7 subnet-0d7d3921fbccfa959" # Use multiple subnets
SECURITY_GROUP_ID="sg-0c8c1497866c3ce8a"  # Security Group ID from previous script

# Create Target Group
TARGET_GROUP_ARN=$(aws elbv2 create-target-group --name $TARGET_GROUP_NAME \
    --protocol HTTP --port 80 --vpc-id $VPC_ID \
    --query 'TargetGroups[0].TargetGroupArn' --output text)

# Create Application Load Balancer in multiple subnets
ALB_ARN=$(aws elbv2 create-load-balancer --name $ALB_NAME \
    --subnets $PUBLIC_SUBNETS --security-groups "$SECURITY_GROUP_ID" \
    --scheme internet-facing --query 'LoadBalancers[0].LoadBalancerArn' --output text)

# Create Listener
aws elbv2 create-listener --load-balancer-arn $ALB_ARN \
    --protocol HTTP --port 80 \
    --default-actions Type=forward,TargetGroupArn=$TARGET_GROUP_ARN

echo "Application Load Balancer and Target Group created successfully."
