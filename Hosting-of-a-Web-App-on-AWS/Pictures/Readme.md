## Implementation Steps

### 1. Networking Setup

#### 1.1 VPC and Subnet Creation
```
- Created a VPC with CIDR block 10.0.0.0/16
- Created public subnets in 2 AZs for resources requiring internet access
- Created private subnets in 2 AZs for application and data tiers
- Enabled auto-assignment of public IP for EC2 instances in public subnets
```

#### 1.2 Security Group Configuration
Created the following security groups:

**Bastion Host SG:**
- Inbound: SSH (port 22) from any IP address
- Outbound: All traffic

**Presentation Tier Load Balancer SG:**
- Inbound: HTTP (port 80) from any IP address
- Outbound: All traffic

**Presentation Tier EC2 SG:**
- Inbound: SSH (port 22) from Bastion Host SG
- Inbound: HTTP (port 80) from Presentation Tier ALB SG
- Outbound: All traffic

**Application Tier Load Balancer SG:**
- Inbound: HTTP traffic from Presentation Tier EC2 SG
- Outbound: All traffic

**Application Tier EC2 SG:**
- Inbound: SSH (port 22) from Bastion Host SG
- Inbound: TCP (port 3200) from Application Tier ALB SG
- Outbound: All traffic

**Data Tier SG:**
- Inbound: MySQL (port 3306) from Bastion Host SG
- Inbound: MySQL (port 3306) from Application Tier EC2 SG
- Outbound: All traffic

### 2. Domain and SSL Configuration

#### 2.1 Route 53 Setup
- Created a public hosted zone for the domain name
- Updated name servers in the domain registrar to direct DNS queries

#### 2.2 SSL Certificate Creation
- Requested a public SSL certificate from AWS Certificate Manager
- Created DNS validation records in Route 53
- Waited for certificate validation and issuance

### 3. Database Tier Setup

#### 3.1 DB Subnet Group Creation
- Created a DB subnet group spanning multiple availability zones for resilience

#### 3.2 RDS MySQL Instance Deployment
- Deployed a multi-AZ MySQL database for high availability
- Configured automated backups and maintenance windows

#### 3.3 Database Initialization
- Connected to the RDS instance via SSH tunnel through the Bastion Host
- Created a dedicated database user for application access
- Loaded initial schema and data

### 4. Bastion Host Deployment

#### 4.1 Bastion Host Launch
- Launched an EC2 instance with Amazon Linux 2023 AMI in a public subnet
- Associated the Bastion Host Security Group
- Configured SSH key pair for secure access

### 5. Application Tier Setup

#### 5.1 Launch Template Creation
- Created a launch template for the Application Tier EC2 instances
- Configured user data script for automated Node.js application deployment:

```bash
#!/bin/bash
# Update package list and install required packages
sudo yum update -y
sudo yum install -y git

# Install Node.js (use NodeSource for the latest version)
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs

# Install PM2 globally
sudo npm install -g pm2

# Define variables
REPO_URL="https://github.com/learnItRightWay01/react-node-mysql-app.git"
BRANCH_NAME="feature/add-logging"
REPO_DIR="/home/ec2-user/react-node-mysql-app/backend"
ENV_FILE="$REPO_DIR/.env"

# Clone the repository
cd /home/ec2-user
sudo -u ec2-user git clone $REPO_URL
cd react-node-mysql-app

# Checkout to the specific branch
sudo -u ec2-user git checkout $BRANCH_NAME
cd backend

# Define the log directory and ensure it exists
LOG_DIR="/home/ec2-user/react-node-mysql-app/backend/logs"
mkdir -p $LOG_DIR
sudo chown -R ec2-user:ec2-user $LOG_DIR

# Append environment variables to the .env file
echo "LOG_DIR=$LOG_DIR" >> "$ENV_FILE"
echo "DB_HOST=\"<rds-instance-endpoint>\"" >> "$ENV_FILE"
echo "DB_PORT=\"3306\"" >> "$ENV_FILE"
echo "DB_USER=\"<db-user>\"" >> "$ENV_FILE"
echo "DB_PASSWORD=\"<db-user-password>\"" >> "$ENV_FILE"
echo "DB_NAME=\"<db-name>\"" >> "$ENV_FILE"

# Install Node.js dependencies as ec2-user
sudo -u ec2-user npm install

# Start the application using PM2 as ec2-user
sudo -u ec2-user npm run serve

# Ensure PM2 restarts on reboot as ec2-user
sudo -u ec2-user pm2 startup systemd
sudo -u ec2-user pm2 save
```

#### 5.2 CloudWatch Integration
Added CloudWatch agent configuration to the Application Tier launch template:

```bash
# Install CloudWatch agent
sudo yum install -y amazon-cloudwatch-agent

# Create CloudWatch agent configuration
sudo tee /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json > /dev/null <<EOL
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/home/ec2-user/react-node-mysql-app/backend/logs/*.log",
            "log_group_name": "backend-node-app-logs",
            "log_stream_name": "{instance_id}",
            "timestamp_format": "%Y-%m-%d %H:%M:%S"
          }
        ]
      }
    }
  }
}
EOL

# Start CloudWatch agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s
```

#### 5.3 Application Tier Target Group Setup
- Created a target group for the Application Tier
- Protocol: HTTP, Port: 3200
- Configured health checks with path: `/health`

#### 5.4 Application Tier Load Balancer Deployment
- Created an internal Application Load Balancer in private subnets
- Assigned Application Tier ALB Security Group
- Associated the ALB with the Application Tier target group

#### 5.5 Application Tier Auto Scaling Group Creation
- Created an ASG using the Application Tier launch template
- Configured minimum, desired, and maximum capacity
- Set up target tracking scaling policy based on CPU utilization
- Enabled CloudWatch monitoring for the ASG

### 6. Presentation Tier Setup

#### 6.1 Launch Template Creation
- Created a launch template for the Presentation Tier EC2 instances
- Configured user data script for automated React.js application deployment:

```bash
#!/bin/bash
# Update package list and install required packages
sudo yum update -y
sudo yum install -y git

# Install Node.js (use NodeSource for the latest version)
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs

# Install NGINX
sudo yum install -y nginx

# Start and enable NGINX
sudo systemctl start nginx
sudo systemctl enable nginx

# Define variables
REPO_URL="https://github.com/learnItRightWay01/react-node-mysql-app.git"
BRANCH_NAME="feature/add-logging"
REPO_DIR="/home/ec2-user/react-node-mysql-app/frontend"
ENV_FILE="$REPO_DIR/.env"
APP_TIER_ALB_URL="http://<internal-application-tier-alb-endpoint>"
API_URL="/api"

# Clone the repository as ec2-user
cd /home/ec2-user
sudo -u ec2-user git clone $REPO_URL
cd react-node-mysql-app

# Checkout to the specific branch
sudo -u ec2-user git checkout $BRANCH_NAME
cd frontend

# Ensure ec2-user owns the directory
sudo chown -R ec2-user:ec2-user /home/ec2-user/react-node-mysql-app

# Create .env file with the API_URL
echo "VITE_API_URL=\"$API_URL\"" >> "$ENV_FILE"

# Install Node.js dependencies as ec2-user
sudo -u ec2-user npm install

# Build the frontend application as ec2-user
sudo -u ec2-user npm run build

# Copy the build files to the NGINX directory
sudo cp -r dist /usr/share/nginx/html/

# Update NGINX configuration
NGINX_CONF="/etc/nginx/nginx.conf"
SERVER_NAME="<domain-name>"

# Backup existing NGINX configuration
sudo cp $NGINX_CONF ${NGINX_CONF}.bak

# Write new NGINX configuration
sudo tee $NGINX_CONF > /dev/null <<EOL
user nginx;
worker_processes auto;

error_log /var/log/nginx/error.log warn;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    log_format main '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                    '\$status \$body_bytes_sent "\$http_referer" '
                    '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    include /etc/nginx/conf.d/*.conf;
}
EOL

# Create a separate NGINX configuration file
sudo tee /etc/nginx/conf.d/presentation-tier.conf > /dev/null <<EOL
server {
    listen 80;
    server_name $SERVER_NAME;
    root /usr/share/nginx/html/dist;
    index index.html index.htm;

    #health check
    location /health {
        default_type text/html;
        return 200 "<!DOCTYPE html><p>Health check endpoint</p>\n";
    }

    location / {
        try_files \$uri /index.html;
    }

    location /api/ {
        proxy_pass $APP_TIER_ALB_URL;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOL

# Restart NGINX to apply the new configuration
sudo systemctl restart nginx
```

#### 6.2 Presentation Tier Target Group Setup
- Created a target group for the Presentation Tier
- Protocol: HTTP, Port: 80
- Configured health checks with path: `/health`

#### 6.3 Presentation Tier Load Balancer Deployment
- Created an internet-facing Application Load Balancer in public subnets
- Assigned Presentation Tier ALB Security Group
- Associated the ALB with the Presentation Tier target group

#### 6.4 Presentation Tier Auto Scaling Group Creation
- Created an ASG using the Presentation Tier launch template
- Configured minimum, desired, and maximum capacity
- Set up target tracking scaling policy based on CPU utilization (50%)
- Enabled CloudWatch monitoring for the ASG

### 7. CloudFront Distribution Setup

#### 7.1 CloudFront Configuration
- Created a CloudFront distribution with the Presentation Tier ALB as origin
- Configured to use HTTPS with the ACM certificate
- Set up proper cache behaviors
- Enabled HTTP to HTTPS redirection

### 8. DNS Configuration

#### 8.1 Route 53 Record Creation
- Created an alias record for the root domain pointing to the CloudFront distribution
- Created an alias record for the www subdomain pointing to the CloudFront distribution

### 9. Stress Testing and Verification

#### 9.1 ASG Testing
- Connected to an EC2 instance via the Bastion Host
- Installed stress testing tools:

```bash
sudo yum install stress -y
stress --cpu 4 --timeout 180s
```

- Verified CloudWatch alarms triggered and new instances launched
- Monitored system with `top` command

#### 9.2 End-to-End Testing
- Verified website accessibility via domain name
- Tested application functionality
- Confirmed data persistence in the database

## Connecting to Resources

### Connecting to the Bastion Host

```bash
# Change SSH key permissions
chmod 400 your_key.pem

# Start SSH agent
eval "$(ssh-agent -s)"

# Add key to SSH agent
ssh-add your_key.pem

# Connect to Bastion Host
ssh -A ec2-user@bastion_host_public_ip
```

### Connecting to Private EC2 Instances via Bastion Host

```bash
# From the Bastion Host
ssh ec2-user@private_instance_private_ip
```

### Connecting to RDS Instance via SSH Tunnel

```bash
# SSH tunneling through Bastion Host
ssh -i /path/to/your/private-key.pem -N -L 3307:<RDS-Endpoint>:3306 ec2-user@<Bastion-Host-IP>

# SSH tunneling through Bastion Host and private EC2 (SSH chaining)
ssh-add /path/to/your/private-key.pem
ssh -A -L 3307:localhost:3306 ec2-user@<public-IP> -t "ssh -L 3306:<rds-endpoint>:3306 ec2-user@<private-IP>"
```

## Future Improvements

1. Implement Infrastructure as Code (IaC) using AWS CloudFormation or Terraform
2. Add AWS WAF for enhanced security
3. Implement CI/CD pipeline for automated deployments
4. Add multi-region support for global high availability
5. Implement database read replicas for improved performance

## Repository Structure

```
/
├── backend/               # Node.js application code
│   ├── src/               # Source code
│   ├── db.sql             # Database schema
│   └── package.json       # Dependencies
├── frontend/              # React.js application code
│   ├── src/               # Source code
│   └── package.json       # Dependencies
├── scripts/               # Deployment scripts
│   ├── application-tier/  # Scripts for application tier
│   └── presentation-tier/ # Scripts for presentation tier
└── diagrams/              # Architecture diagrams
```

## Conclusion

This project successfully demonstrates the implementation of a production-grade, 3-tier architecture on AWS. The architecture provides high availability, fault tolerance, and scalability across multiple availability zones, making it suitable for enterprise-level applications.

## License

[MIT](LICENSE)
