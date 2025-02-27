#!/bin/bash

# Variables
ASG_NAME="my-auto-scaling-group"  # Ensure this is your actual ASG name

# Function to count running instances in the ASG
count_asg_instances() {
    aws autoscaling describe-auto-scaling-groups \
        --auto-scaling-group-names "$ASG_NAME" \
        --query "AutoScalingGroups[0].Instances[*].InstanceId" \
        --output text | wc -w
}

# Step 1: Get initial count of instances
echo "Checking current ASG instance count..."
INITIAL_COUNT=$(count_asg_instances)
echo "Initial running instances: $INITIAL_COUNT"

# Step 2: Get an instance ID from the ASG
INSTANCE_ID=$(aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names "$ASG_NAME" \
    --query "AutoScalingGroups[0].Instances[0].InstanceId" \
    --output text)

if [ -z "$INSTANCE_ID" ]; then
    echo "Error: No instances found in ASG!"
    exit 1
fi

echo "Terminating instance: $INSTANCE_ID"

# Step 3: Terminate the instance
aws ec2 terminate-instances --instance-ids "$INSTANCE_ID"

# Step 4: Wait for ASG to launch a new instance
echo "Waiting for ASG to replace the terminated instance..."
sleep 30  # Initial wait before checking

while true; do
    CURRENT_COUNT=$(count_asg_instances)
    echo "Current running instances: $CURRENT_COUNT"
    
    if [ "$CURRENT_COUNT" -ge "$INITIAL_COUNT" ]; then
        echo "ASG has replaced the instance. Scaling is working!"
        break
    fi
    
    echo "Waiting for new instance to launch..."
    sleep 10
done

echo "Final instance count: $(count_asg_instances)"
echo "ASG successfully maintained the instance count!"
