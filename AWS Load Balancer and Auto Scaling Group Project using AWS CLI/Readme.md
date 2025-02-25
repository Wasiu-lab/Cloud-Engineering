# AWS Load Balancer and Auto Scaling Group Project

## Project Overview
This project demonstrates how to create a highly available web application using AWS services. It utilizes an Elastic Load Balancer (ELB) to distribute incoming traffic and an Auto Scaling Group (ASG) to manage EC2 instances dynamically. The architecture includes a Launch Template for defining EC2 configurations and a Target Group for registering instances.

## Project Architecture
1. **VPC**: A Virtual Private Cloud (VPC) with public and private subnets.
2. **Application Load Balancer (ALB)**: Deployed in the public subnet to handle incoming traffic.
3. **Auto Scaling Group (ASG)**: Located in the private subnet, managing EC2 instances.
4. **Health Checks**: Configured to replace unhealthy instances automatically.
5. **Security Group**: Allows only HTTP (port 80) traffic from the internet and SSH (port 22) traffic from a specified IP address.

## Step-by-Step Implementation

### Step 1: Create a VPC and Subnets
- Execute the script `src/create_vpc_and_subnets.sh` to create a VPC with two public subnets and two private subnets.

### Step 2: Create a Security Group
- Run the script `src/create_security_group.sh` to create a security group that allows:
  - HTTP (port 80) from 0.0.0.0/0
  - SSH (port 22) from your specific IP address

### Step 3: Create an Application Load Balancer (ALB)
- Use the script `src/create_alb.sh` to create an ALB in the public subnet and set up a target group (e.g., `my-target-group`) for registering instances with HTTP protocol.

### Step 4: Create a Launch Template
- Execute `src/create_launch_template.sh` to create a launch template specifying:
  - AMI: Amazon Linux 2
  - Instance Type: t2.micro (Free Tier)
  - User Data script located in `src/user_data.sh` to install and configure the web server.
  - Kindly use ```pwd``` to get the path and correct the path in the `user_data.sh` script

### Step 5: Create an Auto Scaling Group (ASG)
- Run the script `src/create_asg.sh` to create an ASG in the private subnet, attaching the launch template and target group. Configure the ASG with:
  - Minimum instances: 2
  - Maximum instances: 4
  - Scaling policies based on CPU utilization.
  - TARGET_GROUP_ARN: The below prompt wil give the value needed to run the TARGET_GROUP_ARN
    ```aws elbv2 describe-target-groups --query "TargetGroups[*].TargetGroupArn" --output text```

### Step 6: Test the Load Balancer
- Copy the ALB DNS name and open it in a web browser. You should see the message: "Welcome to My Load Balanced App".
- Terminate one instance to observe the ASG automatically replacing it.

## Key Learnings from This Project
- Achieved high availability using Load Balancer and Auto Scaling Group.
- Implemented auto-healing capabilities through ASG health checks.
- Gained insights into scalability based on demand. 

## Project Files
- `src/create_vpc_and_subnets.sh`: Script to create VPC and subnets.
- `src/create_security_group.sh`: Script to create security group.
- `src/create_alb.sh`: Script to create Application Load Balancer.
- `src/create_launch_template.sh`: Script to create launch template for EC2 instances.
- `src/create_asg.sh`: Script to create Auto Scaling Group.
- `src/user_data.sh`: User data script for EC2 instance configuration. 

## Git Ignore
- The `.gitignore` file specifies files and directories to be ignored by Git, including logs and temporary files.
