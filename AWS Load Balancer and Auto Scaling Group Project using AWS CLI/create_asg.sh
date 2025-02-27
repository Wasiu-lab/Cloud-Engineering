#!/bin/bash

# Variables
ASG_NAME="my-auto-scaling-group"
LAUNCH_TEMPLATE_NAME="MyLaunchTemplate"  # Ensure this matches the actual name of your launch template
TARGET_GROUP_ARN="arn:aws:elasticloadbalancing:us-east-1:248189917274:targetgroup/my-target-group/bf9d9892fa61f2d8"  
# IMPORTANT: Ensure this is the correct Target Group ARN

VPC_ID="vpc-0c2b11e04270d860e"  # Your VPC ID
SUBNETS="subnet-027dd21501851d5ae,subnet-0724aa1e8a1ea1b06"  # Ensure this is comma-separated and we are using the private subnets

# Create Auto Scaling Group
aws autoscaling create-auto-scaling-group \
    --auto-scaling-group-name $ASG_NAME \
    --launch-template "LaunchTemplateName=$LAUNCH_TEMPLATE_NAME,Version=1" \
    --min-size 2 \
    --max-size 4 \
    --desired-capacity 2 \
    --vpc-zone-identifier "$SUBNETS" \
    --health-check-type ELB \
    --health-check-grace-period 300 \
    --tags Key=Name,Value=$ASG_NAME,PropagateAtLaunch=true

# Check if ASG was created successfully
if [ $? -eq 0 ]; then
    echo "Auto Scaling Group '$ASG_NAME' created successfully."

    # Attach Target Group to Auto Scaling Group
    aws autoscaling attach-load-balancer-target-groups \
        --auto-scaling-group-name $ASG_NAME \
        --target-group-arns "$TARGET_GROUP_ARN"

    echo "Target Group '$TARGET_GROUP_ARN' attached successfully."

    # Configure Scaling Policies
    aws autoscaling put-scaling-policy \
        --auto-scaling-group-name $ASG_NAME \
        --policy-name "scale-out" \
        --scaling-adjustment 1 \
        --adjustment-type "ChangeInCapacity" \
        --cooldown 300

    aws autoscaling put-scaling-policy \
        --auto-scaling-group-name $ASG_NAME \
        --policy-name "scale-in" \
        --scaling-adjustment -1 \
        --adjustment-type "ChangeInCapacity" \
        --cooldown 300

    echo "Auto Scaling Group configuration completed successfully."
else
    echo "Error: Auto Scaling Group '$ASG_NAME' failed to create."
fi
