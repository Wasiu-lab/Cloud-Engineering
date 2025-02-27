#!/bin/bash

# Set your VPC ID
VPC_ID="vpc-0c2b11e04270d860e" # Replace with your actual VPC ID

echo "Fetching all related resources for VPC: $VPC_ID..."

# Step 1: Terminate EC2 Instances
echo "Terminating EC2 instances..."
for INSTANCE in $(aws ec2 describe-instances --filters "Name=vpc-id,Values=$VPC_ID" --query "Reservations[*].Instances[*].InstanceId" --output text); do
    aws ec2 terminate-instances --instance-ids $INSTANCE
    echo "Terminated EC2 Instance: $INSTANCE"
done
echo "EC2 Instances terminated."

# Step 2: Delete Auto Scaling Groups
echo "Deleting Auto Scaling Groups..."
for ASG in $(aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[?VPCZoneIdentifier!=null] | [?contains(VPCZoneIdentifier, '$VPC_ID')].AutoScalingGroupName" --output text); do
    aws autoscaling delete-auto-scaling-group --auto-scaling-group-name $ASG --force-delete
    echo "Deleted Auto Scaling Group: $ASG"
done
echo "Auto Scaling Groups deleted."

# Step 3: Delete Launch Templates
echo "Deleting Launch Templates..."
for LT in $(aws ec2 describe-launch-templates --query "LaunchTemplates[*].LaunchTemplateId" --output text); do
    aws ec2 delete-launch-template --launch-template-id $LT
    echo "Deleted Launch Template: $LT"
done
echo "Launch Templates deleted."

# Step 4: Delete Load Balancers
echo "Deleting Load Balancers..."
for ALB in $(aws elbv2 describe-load-balancers --query "LoadBalancers[?VpcId=='$VPC_ID'].LoadBalancerArn" --output text); do
    aws elbv2 delete-load-balancer --load-balancer-arn $ALB
    echo "Deleted Load Balancer: $ALB"
done
echo "Load Balancers deleted."

# Step 5: Delete Target Groups
echo "Deleting Target Groups..."
for TG in $(aws elbv2 describe-target-groups --query "TargetGroups[?VpcId=='$VPC_ID'].TargetGroupArn" --output text); do
    aws elbv2 delete-target-group --target-group-arn $TG
    echo "Deleted Target Group: $TG"
done
echo "Target Groups deleted."

# Step 6: Delete NAT Gateways
echo "Deleting NAT gateways..."
for NAT in $(aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$VPC_ID" --query "NatGateways[*].NatGatewayId" --output text); do
    aws ec2 delete-nat-gateway --nat-gateway-id $NAT
    echo "Deleted NAT Gateway: $NAT"
    sleep 10  # Allow time for NAT Gateway deletion
    
done
echo "NAT Gateways deleted."

# Step 7: Release Elastic IPs
echo "Releasing Elastic IPs..."
for ALLOC_ID in $(aws ec2 describe-addresses --query "Addresses[*].AllocationId" --output text); do
    aws ec2 release-address --allocation-id $ALLOC_ID
    echo "Released Elastic IP: $ALLOC_ID"
done
echo "Elastic IPs released."

# Step 8: Delete Security Groups (except default)
echo "Deleting security groups..."
for SG in $(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" --query "SecurityGroups[*].GroupId" --output text); do
    aws ec2 delete-security-group --group-id $SG 2>/dev/null
    echo "Deleted Security Group: $SG"
done
echo "Security Groups deleted."

# Step 9: Delete Network Interfaces
echo "Deleting Network Interfaces..."
for ENI in $(aws ec2 describe-network-interfaces --filters "Name=vpc-id,Values=$VPC_ID" --query "NetworkInterfaces[*].NetworkInterfaceId" --output text); do
    aws ec2 delete-network-interface --network-interface-id $ENI 2>/dev/null
    echo "Deleted Network Interface: $ENI"
done
echo "Network Interfaces deleted."

# Step 10: Delete Route Tables (except main)
echo "Deleting route tables..."
for RTB in $(aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID" --query "RouteTables[*].RouteTableId" --output text); do
    for ASSOC in $(aws ec2 describe-route-tables --route-table-ids $RTB --query "RouteTables[*].Associations[*].RouteTableAssociationId" --output text); do
        aws ec2 disassociate-route-table --association-id $ASSOC
        echo "Disassociated Route Table: $ASSOC"
    done
    aws ec2 delete-route-table --route-table-id $RTB
    echo "Deleted Route Table: $RTB"
done
echo "Route Tables deleted."

# Step 11: Detach and Delete Internet Gateways
echo "Detaching and deleting internet gateways..."
for IGW in $(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$VPC_ID" --query "InternetGateways[*].InternetGatewayId" --output text); do
    aws ec2 detach-internet-gateway --internet-gateway-id $IGW --vpc-id $VPC_ID
    aws ec2 delete-internet-gateway --internet-gateway-id $IGW
    echo "Deleted Internet Gateway: $IGW"
done
echo "Internet Gateways deleted."

# Step 12: Delete Subnets
echo "Deleting subnets..."
for SUBNET in $(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query "Subnets[*].SubnetId" --output text); do
    aws ec2 delete-subnet --subnet-id $SUBNET
    echo "Deleted Subnet: $SUBNET"
done
echo "Subnets deleted."

# Step 13: Delete VPC
echo "Deleting VPC..."
aws ec2 delete-vpc --vpc-id $VPC_ID
if [ $? -eq 0 ]; then
    echo "Deleted VPC: $VPC_ID"
else
    echo "Failed to delete VPC. Ensure all dependencies are removed."
fi

echo "✅ Full cleanup completed!"
