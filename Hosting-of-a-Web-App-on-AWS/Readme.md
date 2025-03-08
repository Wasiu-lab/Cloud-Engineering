# Hosting of a Web Application using AWS resources 
This project is a full-stack web application built using React js for the frontend, Express js for the backend, and MySQL as the database. The application is designed to demonstrate the implementation of a 3-tier architecture, where the presentation layer (React js), application logic layer (Express js), and data layer (MySQL) are separated into distinct tiers.


## User Interface Screenshots 
#### Dashboard
![Dashboard](https://github.com/Wasiu-lab/Cloud-Engineering/blob/main/Hosting-of-a-Web-App-on-AWS/Pictures/dashboard.png)

#### Books
![Dashboard](https://github.com/Wasiu-lab/Cloud-Engineering/blob/main/Hosting-of-a-Web-App-on-AWS/Pictures/books.png)

#### Authors
![Dashboard](https://github.com/Wasiu-lab/Cloud-Engineering/blob/main/Hosting-of-a-Web-App-on-AWS/Pictures/authors.png)

# 3-Tier Production-Grade Architecture Deployment

## Overview
This project demonstrates a **highly available**, **scalable**, and **secure** deployment of a **React.js frontend** and **Node.js backend** application using AWS cloud services. The architecture follows a **3-tier deployment model**, consisting of:

- **Presentation Tier**: React.js hosted on EC2 with Nginx and Load Balancer
- **Application Tier**: Node.js backend with PM2 running in private subnets
- **Data Tier**: RDS MySQL database with multi-AZ deployment for high availability

## Architecture Diagram
![Architecture Diagram](https://github.com/Wasiu-lab/Cloud-Engineering/blob/main/Hosting-of-a-Web-App-on-AWS/Pictures/3-tier%20Production-Grade%20Architecture.drawio.png)

---

## Technologies Used
- **AWS Services**: EC2, RDS (MySQL), CloudFront, Route 53, ACM, VPC, Load Balancers (ALB), Auto Scaling Groups, Security Groups, CloudWatch
- **Frontend**: React.js, Nginx
- **Backend**: Node.js, PM2
- **Infrastructure as Code**: Bash scripts for automation
- **Database**: AWS RDS MySQL (Primary & Standby Replication)

## Project Setup and Implementation Steps

### 1. Configuring Route 53 for Domain Management
- Create a **public hosted zone** in **Route 53**.
- Update the **name servers** in your domain registrar.
- Ensure domain traffic is properly routed.

### 2. Requesting an SSL Certificate from ACM
- Generate a **public SSL certificate** using **AWS Certificate Manager (ACM)**.
- Validate ownership via DNS records in **Route 53**.
- Enables **HTTPS** for secure traffic.

### 3. VPC and Subnet Configuration
- Create a **VPC with multiple subnets**:
  - **Public subnets**: For the frontend and bastion host.
  - **Private subnets**: For backend EC2 instances and database.

### 4. Setting Up Security Groups
Define security groups for controlled communication:
- **Bastion Host SG**: Allows SSH access.
- **Presentation Tier SG**: Allows HTTP traffic from Load Balancer.
- **Application Tier SG**: Allows Node.js traffic.
- **Database Tier SG**: Allows MySQL access from application instances.

### 5. Launching the Bastion Host
- Deploy an **Amazon Linux EC2 instance**.
- Configure a **key pair for SSH access**.
- Restrict access to only your IP.

### 6. Deploying the Database Tier (RDS MySQL)
- Create a **DB subnet group**.
- Set up a **multi-AZ MySQL database**.
- Enable **automatic backups** and **high availability**.
- Configure **SSH tunneling** for database access.

### 7. Configuring the Presentation Tier (Frontend)
- Create a **Launch Template** for EC2 frontend instances.
- Deploy a **React.js app** with **Nginx**.
- Use an **Application Load Balancer (ALB)** to distribute traffic.
- Configure an **Auto Scaling Group (ASG)** for automatic scaling.

### 8. Configuring the Application Tier (Backend)
- Create a **Launch Template** for backend EC2 instances.
- Deploy **Node.js with PM2** for process management.
- Use an **Application Load Balancer** for API requests.
- Configure an **Auto Scaling Group**.

### 9. Implementing Auto Scaling
- Set up **CloudWatch Alarms** for CPU usage.
- Automatically **scale up/down EC2 instances** based on demand.
- Use **stress testing** to validate autoscaling.

### 10. Integrating CloudWatch Logs
- Create **log groups** in CloudWatch.
- Attach **IAM roles** to EC2 instances for log streaming.
- Monitor logs in **CloudWatch Logs**.

### 11. Setting Up CloudFront for Content Delivery
- Configure **CloudFront Distribution** for caching and performance.
- Set the **origin** as the **ALB** for the frontend.
- Enforce **HTTPS redirection**.

### 12. Configuring DNS Records in Route 53
- Create **alias records** for CloudFront.
- Ensure domain traffic is properly routed to the CloudFront distribution.

---

## Source Code
The source code used for deploying this infrastructure are available in the GitHub repository. Each script is documented with inline comments for clarity.

**Source Code**: [GitHub Link](#)
---

## Testing & Validation
- **Stress test the autoscaling feature** by artificially increasing CPU load.
- **Check ALB health checks** to ensure smooth traffic routing.
- **Monitor logs in CloudWatch** for debugging.

---

## Screenshots
_(Add images of implementation steps, such as EC2 setup, RDS creation, ALB configurations, etc.)_

---



## Connecting to private EC2 instance via a bastion host
1. To change the ssh key permission:

```bash
chmod 400 your_key.pem
```

2. To start ssh agent:

```bash
eval "$(ssh-agent -s)"  
```

3. To add key to ssh agent:

```bash
ssh-add your_key.pem
```

4. To ssh into bastion host with agent forwarding:

```bash
ssh -A ec2-user@bastion_host_public_ip
```

5. To connect private instance from the bastion host:

```bash
ssh ec2-user@private_instance_private_ip 
```

## Setting up the Data Tier
#### Install MySQL
1. To download MySQL repository package:

```bash
wget https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm
```

2. To verify the package download:

```bash
ls -lrt 
```

3. To install MySQL repository package:

```bash
sudo dnf install -y mysql80-community-release-el9-1.noarch.rpm 
```

4. To import GPG key: 

```bash
sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2023 
```

5. To update package index:

```bash
sudo dnf update –y 
```

6. To install MySQL server:

```bash
sudo dnf install -y mysql-community-server  
```

7. To start the mysql service:

```bash
sudo systemctl start mysqld
```

8. To enable mysql to start on boot:

```bash
sudo systemctl enable mysqld 
```

9. To secure the mysql installation:

```bash
sudo grep 'temporary password' /var/log/mysqld.log 

sudo mysql_secure_installation 
```

10. To create database and restore data, please refer SQL scripts on [db.sql](./backend/db.sql) file.


## Setting up the Application Tier
#### Install GIT
```bash
sudo yum update -y

sudo yum install git -y

git — version
```

#### Clone repository
```bash
git clone https://github.com/learnItRightWay01/react-node-mysql-app.git
```

#### Install node.js
1. To install node version manager (nvm)
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
```

2. To load nvm
```bash
source ~/.bashrc
```

3. To use nvm to install the latest LTS version of Node.js
```bash
nvm install --lts
```

4. To test that Node.js is installed and running
```bash
node -e "console.log('Running Node.js ' + process.version)"
```

## Setting up the Presentation Tier
#### Install GIT
```
PLEASE REFER ABOVE
```

#### Clone repository
```
PLEASE REFER ABOVE
```

#### Install node.js
```
PLEASE REFER ABOVE
```

#### Install NGINX
```bash
dnf search nginx

sudo dnf install nginx

sudo systemctl restart nginx 

nginx -v
```

#### Copy react.js build files
```bash
sudo cp -r dist /usr/share/nginx/html 
```

#### Update NGINX config
1. Server name and root
```
server_name    domain.com www.subdomain.com
root           /usr/share/nginx/html/dist
```

2. Setup reverse proxy
```
location /api { 
   proxy_pass http://application_tier_instance_private_ip:3200/api; 
}
```

3. Restart NGINX
```
sudo systemctl restart nginx
```

## User data scripts
#### Install NGINX
For [AWS solutions - 06](https://youtu.be/snQlL0fJI3Q) and  [AWS solutions - 07](https://youtu.be/eRX1FI2cFi8)

```bash
#!/bin/bash 
# Update package lists 
yum update -y 

# Install Nginx 
yum install -y nginx 

# Stop and disable default service (optional) 
systemctl stop nginx 
systemctl disable nginx 

# Create a custom welcome message file 
echo "Welcome to Presentation Tier EC2 instance in Availability Zone B." > /usr/share/nginx/html/index.html 

# Start and enable the Nginx service 
systemctl start nginx 
systemctl enable nginx
```

#### Install NGINX
For Auto Scaling Group setup.

```bash
#!/bin/bash 
# Update the package list and install NGINX 
sudo yum update -y 
sudo yum install nginx -y 

# Start and enable NGINX 
sudo systemctl start nginx 
sudo systemctl enable nginx 

# Fetch metadata token 
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600") 

# Fetch instance details using IMDSv2 
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" "http://169.254.169.254/latest/meta-data/instance-id") 
AVAILABILITY_ZONE=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" "http://169.254.169.254/latest/meta-data/placement/availability-zone") 
PUBLIC_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" "http://169.254.169.254/latest/meta-data/public-ipv4") 

# Create a simple HTML page displaying instance details 
sudo bash -c "cat > /usr/share/nginx/html/index.html <<EOF 
<h1>Instance Details</h1> 
<p><b>Instance ID:</b> $INSTANCE_ID</p> 
<p><b>Availability Zone:</b> $AVAILABILITY_ZONE</p> 
<p><b>Public IP:</b> $PUBLIC_IP</p> 
EOF" 

# Restart NGINX to ensure changes are applied 
sudo systemctl restart nginx 
```

#### Stress Testing
```bash
sudo yum install stress –y 
stress --cpu 4 --timeout 180s

top
```

#### Connet to RDS instance via SSH
##### SSH tunneling through a bastion host
```bash
ssh -i /path/to/your/private-key.pem -N -L 3307:<RDS-Endpoint>:3306 ec2-user@<Bastion-Host-IP>
```

##### SSH tunneling through a bastion host and a private EC2 (SSH chaining)
```bash
ssh-add /path/to/your/private-key.pem
ssh -A -L 3307:localhost:3306 ec2-user@<public-IP> -t "ssh -L 3306:<rds-endpoint>:3306 ec2-user@<private-IP>"
```

#### Configure Application Tier
For Auto Scaling Group setup.

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
echo "DB_HOST=\"<rds-instance.end.point.region.rds.amazonaws.com>\"" >> "$ENV_FILE"
echo "DB_PORT=\"3306\"" >> "$ENV_FILE"
echo "DB_USER=\"<db-user>\"" >> "$ENV_FILE"
echo "DB_PASSWORD=\"<db-user-password>\"" >> "$ENV_FILE"  # Replace with actual password
echo "DB_NAME=\"<db-name>\"" >> "$ENV_FILE"

# Install Node.js dependencies as ec2-user
sudo -u ec2-user npm install

# Start the application using PM2 as ec2-user
sudo -u ec2-user npm run serve

# Ensure PM2 restarts on reboot as ec2-user
sudo -u ec2-user pm2 startup systemd 
sudo -u ec2-user pm2 save 
```

#### Enabale Cloudwatch logs for Application Tier
For Auto Scaling Group setup.

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

#### Configure Presentation Tier
For Auto Scaling Group setup.

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
APP_TIER_ALB_URL="http://<internal-application-tier-alb-end-point.region.elb.amazonaws.com>"  # Replace with your actual alb endpoint
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
SERVER_NAME="<domain subdomain>"  # Replace with your actual domain name

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

## Conclusion
This project successfully demonstrates a **scalable, highly available, and secure** deployment of a React.js and Node.js application in AWS using DevOps best practices. By leveraging **load balancers, auto-scaling groups, and CloudFront**, the application can handle increased traffic efficiently while maintaining **high availability** and **performance**.
