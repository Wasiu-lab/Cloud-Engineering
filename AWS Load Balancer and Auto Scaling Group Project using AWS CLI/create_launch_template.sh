#!/bin/bash

# Fetch the latest Amazon Linux 2 AMI ID dynamically
LATEST_AMI=$(aws ssm get-parameters --names /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 --query "Parameters[0].Value" --output text)

# Absolute path to user_data.sh file
USER_DATA_FILE="/mnt/c/Users/HP/Desktop/Cloud Eg/Load Balancer website/vs/src/user_data.sh"

# Check if user_data.sh file exists
if [[ ! -f "$USER_DATA_FILE" ]]; then
    echo "Error: $USER_DATA_FILE not found!"
    exit 1
fi

# Encode user_data.sh in base64
USER_DATA=$(base64 -w 0 "$USER_DATA_FILE")

# Create a launch template for EC2 instances
aws ec2 create-launch-template \
    --launch-template-name MyLaunchTemplate \
    --version-description "Version1" \
    --launch-template-data "{
        \"ImageId\": \"$LATEST_AMI\",
        \"InstanceType\": \"t2.micro\",
        \"UserData\": \"$USER_DATA\"
    }"

echo "Launch template created successfully!"
