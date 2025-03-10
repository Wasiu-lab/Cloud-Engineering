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

## Architecture Overview

![Architecture Diagram](https://github.com/Wasiu-lab/Cloud-Engineering/blob/main/Hosting-of-a-Web-App-on-AWS/Pictures/3-tier%20Production-Grade%20Architecture.drawio.png)

This project demonstrates a **highly available**, **scalable**, and **secure** deployment of a **React.js frontend** and **Node.js backend** application using AWS cloud services. The architecture follows a **3-tier deployment model**, consisting of:

### 🔹 Presentation Tier
A highly scalable front-end environment using EC2 instances with Nginx to serve a React.js application. CloudFront provides fast, reliable, and secure content delivery to users globally with HTTPS support, leveraging edge locations to optimize load times.

### 🔹 Application Tier
A robust and resilient back-end system using Node.js on EC2 instances managed by PM2. Auto Scaling Groups dynamically adjust based on traffic demands, while an Application Load Balancer efficiently distributes requests. CloudWatch provides real-time monitoring and logging for proactive system management.

### 🔹 Data Tier
A highly available RDS MySQL database that ensures data redundancy and reliability across multiple availability zones, with automated backups and failover support.

---

## Technologies Used

1. **VPC** with 1 public and 2 private subnets across 2 availability zones
2. **Internet Gateway** for communication between VPC instances and the Internet
3. **Security Groups** for firewall protection
4. **NAT Gateway** enabling private instances to access the internet
5. **Bastion Host** as a control entry point to the private network
6. **EC2 Instances** for hosting the web applications
7. **Application Load Balancers** to distribute traffic across Auto Scaling Groups
8. **Auto Scaling Groups** for dynamic EC2 instance creation ensuring high availability
9. **RDS MySQL** for the database tier with multi-AZ deployment
10. **Route 53** for domain registration and DNS record management
11. **AWS Certificate Manager** for SSL/TLS certificates
12. **CloudFront** for global content delivery
13. **CloudWatch** for centralized logging, monitoring, and alarms
14. **GitHub** for source code management
15. **Frontend (React.js, Nginx)**: Presentation Tier
16. **Backend (Node.js, PM2)**: Application Tier
17. **Infrastructure as Code**: Bash scripts for automation

## Project Setup and Implementation Steps

### 1. Configuring Route 53 for Domain Management
- Create a **public hosted zone** in **Route 53**.
- Update the **name servers** in your domain registrar.
- Ensure domain traffic is properly routed.
  
![Architecture Diagram](https://github.com/Wasiu-lab/Cloud-Engineering/blob/main/Hosting-of-a-Web-App-on-AWS/Pictures/creating%20a%20hosted%20zone.PNG)

### 2. Requesting an SSL Certificate from ACM
- Generate a **public SSL certificate** using **AWS Certificate Manager (ACM)**.
- Validate ownership via DNS records in **Route 53**.
- Enables **HTTPS** for secure traffic.
  
![Architecture Diagram](https://github.com/Wasiu-lab/Cloud-Engineering/blob/main/Hosting-of-a-Web-App-on-AWS/Pictures/certificat%20request.PNG)

### 3. VPC and Subnet Configuration
- Create a **VPC with multiple subnets**:
- **Public subnets**: For the frontend and bastion host.
- **Private subnets**: For backend EC2 instances and database.
  
![Architecture Diagram](https://github.com/Wasiu-lab/Cloud-Engineering/blob/main/Hosting-of-a-Web-App-on-AWS/Pictures/VPC%20workflow.PNG)

### 4. Setting Up Security Groups
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

![Architecture Diagram](https://github.com/Wasiu-lab/Cloud-Engineering/blob/main/Hosting-of-a-Web-App-on-AWS/Pictures/All%20SG.PNG)

### 5. Launching the Bastion Host
- Launched an EC2 instance with Amazon Linux 2023 AMI in a public subnet
- Configure a **key pair for SSH access**.
- Associated the Bastion Host Security Group

![Architecture Diagram](https://github.com/Wasiu-lab/Cloud-Engineering/blob/main/Hosting-of-a-Web-App-on-AWS/Pictures/bastion%20host%20setup.PNG)

### 6. Deploying the Database Tier (RDS MySQL)

#### 6.1 DB Subnet Group Creation
- Created a DB subnet group spanning multiple availability zones for resilience

![Architecture Diagram](https://github.com/Wasiu-lab/Cloud-Engineering/blob/main/Hosting-of-a-Web-App-on-AWS/Pictures/creating%20db%20subnet.PNG)

#### 6.2 RDS MySQL Instance Deployment
- Deployed a multi-AZ MySQL database for high availability
- Configured automated backups and maintenance windows

![Architecture Diagram](https://github.com/Wasiu-lab/Cloud-Engineering/blob/main/Hosting-of-a-Web-App-on-AWS/Pictures/db%20created.PNG)

#### 6.3 Database Initialization
- Connected to the RDS instance via SSH tunnel through the Bastion Host
- Connect to mysql workbench using the Host, Port, Username, and the password created
- Created a dedicated database user for application access
- Loaded initial schema and data

![Architecture Diagram](https://github.com/Wasiu-lab/Cloud-Engineering/blob/main/Hosting-of-a-Web-App-on-AWS/Pictures/conneced%20to%20mysql%20to%20load%20data.PNG)

### 7. Configuring the Presentation Tier (Frontend)
- Create a **Launch Template** for EC2 frontend instances.
- Deploy a **React.js app** with **Nginx**.
- Use an **Application Load Balancer (ALB)** to distribute traffic.
- Configure an **Auto Scaling Group (ASG)** for automatic scaling.

![Architecture Diagram](https://github.com/Wasiu-lab/Cloud-Engineering/blob/main/Hosting-of-a-Web-App-on-AWS/Pictures/Instance%20runnign%20with%20ALB%20and%20ASG.PNG)

### 8. Configuring the Application Tier (Backend)
- Create a **Launch Template** for backend EC2 instances.
- Deploy **Node.js with PM2** for process management.
- Use an **Application Load Balancer** for API requests.
- Configure an **Auto Scaling Group**.
- Connect to the private subnet that the Application Tier is running and check the state of the PM2 managing the Node.js

![Architecture Diagram](https://github.com/Wasiu-lab/Cloud-Engineering/blob/main/Hosting-of-a-Web-App-on-AWS/Pictures/connect%20to%20the%20application%20instance%20and%20checking%20pms%202%20logs.PNG)

### 9. Implementing Auto Scaling
- Set up **CloudWatch Alarms** for CPU usage.
- Automatically **scale up/down EC2 instances** based on demand.
- Use **stress testing** to validate autoscaling.

### 10. Integrating CloudWatch Logs
- Create **log groups** in CloudWatch.
- Attach **IAM roles** to EC2 instances for log streaming.
- Monitor logs in **CloudWatch Logs**.

![Architecture Diagram](https://github.com/Wasiu-lab/Cloud-Engineering/blob/main/Hosting-of-a-Web-App-on-AWS/Pictures/Alerm%20showin%20high%20cpu%20utilization.PNG)

### 11. Setting Up CloudFront for Content Delivery
- Created a CloudFront distribution with the Presentation Tier ALB as origin
- Configured to use HTTPS with the ACM certificate
- Set up proper cache behaviors
- Enabled HTTP to HTTPS redirection

![Architecture Diagram](https://github.com/Wasiu-lab/Cloud-Engineering/blob/main/Hosting-of-a-Web-App-on-AWS/Pictures/cloud%20fron%20distribution.PNG)

### 12. Configuring DNS Records in Route 53
- Created an alias record for the root domain pointing to the CloudFront distribution
- Created an alias record for the www subdomain pointing to the CloudFront distribution
- Ensure domain traffic is properly routed to the CloudFront distribution.

![Architecture Diagram](https://github.com/Wasiu-lab/Cloud-Engineering/blob/main/Hosting-of-a-Web-App-on-AWS/Pictures/project%20complete.PNG)

---

## Source Code
The source code used for deploying this infrastructure are available in the GitHub repository. Each script is documented with inline comments for clarity.

**Source Code**: [GitHub Link](https://github.com/Wasiu-lab/Dynamic-Web-Application-Souce-code)

---

## Testing & Validation
- **Stress test the autoscaling feature** by artificially increasing CPU load.
- **Check ALB health checks** to ensure smooth traffic routing.
- **Monitor logs in CloudWatch** for debugging.

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
