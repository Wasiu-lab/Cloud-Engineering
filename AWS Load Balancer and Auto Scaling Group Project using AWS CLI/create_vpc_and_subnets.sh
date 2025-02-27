#!/bin/bash

# Create a VPC
VPC_ID=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 --query 'Vpc.VpcId' --output text)

# Assign a name to the VPC
aws ec2 create-tags --resources $VPC_ID --tags Key=Name,Value=ALB-ASG-VPC

echo "Created VPC with ID: $VPC_ID and Name: ALB-ASG-VPC"

# Get availability zones
AZ1=$(aws ec2 describe-availability-zones --query 'AvailabilityZones[0].ZoneName' --output text)
AZ2=$(aws ec2 describe-availability-zones --query 'AvailabilityZones[1].ZoneName' --output text)

# Create Public Subnets
PUBLIC_SUBNET1_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.1.0/24 --availability-zone $AZ1 --query 'Subnet.SubnetId' --output text)
aws ec2 create-tags --resources $PUBLIC_SUBNET1_ID --tags Key=Name,Value=PublicSubnet1
echo "Created Public Subnet 1 with ID: $PUBLIC_SUBNET1_ID in $AZ1"

PUBLIC_SUBNET2_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.2.0/24 --availability-zone $AZ2 --query 'Subnet.SubnetId' --output text)
aws ec2 create-tags --resources $PUBLIC_SUBNET2_ID --tags Key=Name,Value=PublicSubnet2
echo "Created Public Subnet 2 with ID: $PUBLIC_SUBNET2_ID in $AZ2"

# Create Private Subnets
PRIVATE_SUBNET1_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.3.0/24 --availability-zone $AZ1 --query 'Subnet.SubnetId' --output text)
aws ec2 create-tags --resources $PRIVATE_SUBNET1_ID --tags Key=Name,Value=PrivateSubnet1
echo "Created Private Subnet 1 with ID: $PRIVATE_SUBNET1_ID in $AZ1"

PRIVATE_SUBNET2_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.4.0/24 --availability-zone $AZ2 --query 'Subnet.SubnetId' --output text)
aws ec2 create-tags --resources $PRIVATE_SUBNET2_ID --tags Key=Name,Value=PrivateSubnet2
echo "Created Private Subnet 2 with ID: $PRIVATE_SUBNET2_ID in $AZ2"

# Create an Internet Gateway and attach it to the VPC
IGW_ID=$(aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text)
aws ec2 attach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID
echo "Created and attached Internet Gateway with ID: $IGW_ID"

# Create a Public Route Table and associate with Public Subnets
PUBLIC_RT_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID --query 'RouteTable.RouteTableId' --output text)
aws ec2 create-tags --resources $PUBLIC_RT_ID --tags Key=Name,Value=PublicRouteTable
aws ec2 create-route --route-table-id $PUBLIC_RT_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID
aws ec2 associate-route-table --route-table-id $PUBLIC_RT_ID --subnet-id $PUBLIC_SUBNET1_ID
aws ec2 associate-route-table --route-table-id $PUBLIC_RT_ID --subnet-id $PUBLIC_SUBNET2_ID
echo "Created and associated Public Route Table: $PUBLIC_RT_ID"

# Allocate an Elastic IP for NAT Gateway
EIP_ALLOC_ID=$(aws ec2 allocate-address --query 'AllocationId' --output text)

# Create a NAT Gateway in the first Public Subnet
NAT_GW_ID=$(aws ec2 create-nat-gateway --subnet-id $PUBLIC_SUBNET1_ID --allocation-id $EIP_ALLOC_ID --query 'NatGateway.NatGatewayId' --output text)
echo "Created NAT Gateway with ID: $NAT_GW_ID in Public Subnet 1"

# Wait for NAT Gateway to become available
echo "Waiting for NAT Gateway to become available..."
aws ec2 wait nat-gateway-available --nat-gateway-ids $NAT_GW_ID
echo "NAT Gateway is now available"

# Create a Private Route Table and associate with Private Subnets
PRIVATE_RT_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID --query 'RouteTable.RouteTableId' --output text)
aws ec2 create-tags --resources $PRIVATE_RT_ID --tags Key=Name,Value=PrivateRouteTable
aws ec2 create-route --route-table-id $PRIVATE_RT_ID --destination-cidr-block 0.0.0.0/0 --nat-gateway-id $NAT_GW_ID
aws ec2 associate-route-table --route-table-id $PRIVATE_RT_ID --subnet-id $PRIVATE_SUBNET1_ID
aws ec2 associate-route-table --route-table-id $PRIVATE_RT_ID --subnet-id $PRIVATE_SUBNET2_ID
echo "Created and associated Private Route Table: $PRIVATE_RT_ID"

echo "VPC, Subnets, Internet Gateway, NAT Gateway, and Route Tables configured successfully!"
#The script creates a VPC with two public and two private subnets across two availability zones. It also creates an internet gateway and a NAT gateway to allow instances in the private subnets to access the internet. 
#The script uses the AWS CLI to create the VPC, subnets, gateways, and route tables.      