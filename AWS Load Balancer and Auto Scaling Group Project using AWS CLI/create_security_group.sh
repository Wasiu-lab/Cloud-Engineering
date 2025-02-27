#!/bin/bash

# Variables
SECURITY_GROUP_NAME="web-app-sg"
ALB_SECURITY_GROUP_NAME="alb-sg"  # Security group for ALB
VPC_ID="vpc-0c2b11e04270d860e"  # Replace with your actual VPC ID
MY_IP=$(curl -s http://checkip.amazonaws.com)  # Automatically fetch your public IP

# Create Security Group for EC2 Instances
SG_ID=$(aws ec2 create-security-group --group-name $SECURITY_GROUP_NAME \
    --description "Security group for web application" --vpc-id $VPC_ID --query 'GroupId' --output text)

echo "Created Security Group $SECURITY_GROUP_NAME with ID: $SG_ID"

#FIXED: Create Security Group for ALB
ALB_SG_ID=$(aws ec2 create-security-group --group-name $ALB_SECURITY_GROUP_NAME \
    --description "Security group for Application Load Balancer" --vpc-id $VPC_ID --query 'GroupId' --output text)

echo "Created ALB Security Group $ALB_SECURITY_GROUP_NAME with ID: $ALB_SG_ID"

# Wait for AWS to register the security groups
sleep 5

# Allow HTTP traffic (open to everyone) - For ALB
aws ec2 authorize-security-group-ingress --group-id $ALB_SG_ID --protocol tcp --port 80 --cidr 0.0.0.0/0
echo "Allowed public HTTP access on ALB port 80"

# Allow ALB to communicate with EC2 instances
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 80 --source-group $ALB_SG_ID
echo "Allowed ALB to send HTTP traffic to EC2 instances on port 80"

# Allow SSH traffic (only from your IP)
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 22 --cidr $MY_IP/32
echo "Allowed SSH access on port 22 from $MY_IP"

# Allow EC2 instances to respond to traffic (Outbound rule)
aws ec2 authorize-security-group-egress --group-id $SG_ID --protocol tcp --port 80 --cidr 0.0.0.0/0
echo "Allowed EC2 instances to send responses on port 80"

#Allow ALB to respond as well (Outbound rule)
aws ec2 authorize-security-group-egress --group-id $ALB_SG_ID --protocol tcp --port 80 --cidr 0.0.0.0/0
echo "Allowed ALB to send responses on port 80"

echo "Security Group configuration completed successfully!"
