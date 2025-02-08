# AWS 2-Tier Architecture Deployment

This project demonstrates the deployment of a highly available and secure **2-tier architecture** in AWS, comprising a web tier (EC2 running PHP) and a database tier (RDS MySQL). Below is a complete guide with step-by-step instructions.

---

## **Project Architecture**
![Architecture Diagram](https://github.com/Wasiu-lab/Cloud-Engineering/blob/main/AWS%202-Tier%20Architecture%20Deployment/AWS/2%20tier.drawio.png)  
*Figure 1: High-Level Architecture Diagram.*

This architecture represents a **highly available and secure 2-tier application setup** in AWS, consisting of a web tier and a database tier within a Virtual Private Cloud (VPC) with a CIDR block of `10.0.0.0/26`. The web servers are hosted in public subnets (`10.0.0.0/28` and `10.0.0.16/28`) and are accessible via an Internet Gateway (IGW) for handling HTTP/HTTPS requests, while the database is hosted in private subnets (`10.0.0.32/28` and `10.0.0.48/28`) to ensure it is not directly exposed to the Internet. A NAT Gateway in the public subnet provides outbound Internet access for private resources. Security Groups are used to control traffic: the web tier allows HTTP, HTTPS, and SSH traffic from trusted sources, while the database tier only accepts traffic from the web tier on port 3306. The architecture spans multiple Availability Zones (AZs) for high availability and fault tolerance. Users interact with the web servers, which securely connect to the database to process and store data, ensuring a scalable, robust, and secure system.

---

## **Step-by-Step Guide**

### **Step 1: VPC and Networking**
#### 1.1 Create a VPC
1. Navigate to the **VPC Dashboard** in AWS.
2. Click **Create VPC** and configure:
   - **Name**: `2-Tier-VPC`.
   - **IPv4 CIDR Block**: `10.0.0.0/16`.
   - Enable **DNS Hostnames** and **DNS Resolution**.
3. Save your VPC configuration.

**Screenshot Placeholder**: Add a screenshot of the VPC configuration here.  
`![VPC Configuration Screenshot](./images/vpc-configuration.png)`

#### 1.2 Create Subnets
1. Create a **Public Subnet**:
   - **Name**: `Public-Subnet`.
   - **Availability Zone**: `us-east-1a`.
   - **CIDR Block**: `10.0.0.0/28`.
   - Enable **Auto-assign Public IP**.
2. Create a **Private Subnet**:
   - **Name**: `Private-Subnet`.
   - **Availability Zone**: `us-east-1b`.
   - **CIDR Block**: `10.0.0.16/28`.

**Screenshot Placeholder**: Add a screenshot of subnet creation here.  
`![Subnet Creation Screenshot](./images/subnet-creation.png)`

#### 1.3 Attach an Internet Gateway
1. Create an **Internet Gateway** in the **VPC Dashboard**.
2. Attach the IGW to your VPC.

**Screenshot Placeholder**: Add a screenshot of the IGW attachment here.  
`![Internet Gateway Attachment Screenshot](./images/internet-gateway.png)`

#### 1.4 Configure Route Tables
1. **Public Route Table**:
   - Associate the public subnet with this route table.
   - Add a route for `0.0.0.0/0` pointing to the Internet Gateway.
2. **Private Route Table**:
   - Associate the private subnet with this route table.
   - Add a route for `0.0.0.0/0` pointing to a **NAT Gateway**.

**Screenshot Placeholder**: Add screenshots of public and private route table configurations here.  
`![Route Table Configuration Screenshot](./images/route-tables.png)`

#### 1.5 Create a NAT Gateway
1. In **NAT Gateways**, create a NAT Gateway in the **Public Subnet**.
2. Allocate an Elastic IP for the NAT Gateway.
3. Ensure the private route table uses this NAT Gateway for internet-bound traffic.

**Screenshot Placeholder**: Add a screenshot of the NAT Gateway setup here.  
`![NAT Gateway Setup Screenshot](./images/nat-gateway.png)`

---

### **Step 2: Security Configuration**
#### 2.1 Create Security Groups
1. **Web Security Group**:
   - Allow inbound:
     - **HTTP (port 80)**: `0.0.0.0/0`.
     - **HTTPS (port 443)**: `0.0.0.0/0`.
     - **SSH (port 22)**: Restrict to your local machine’s IP.
   - Allow outbound:
     - **Database port** (3306 for MySQL or 5432 for PostgreSQL).

2. **Database Security Group**:
   - Allow inbound:
     - Only from the **Web Security Group** on database port (3306 or 5432).
   - Allow outbound for software updates.

**Screenshot Placeholder**: Add screenshots of the Security Groups configuration here.  
`![Security Group Configuration Screenshot](./images/security-groups.png)`

---

### **Step 3: Web Tier Deployment**
#### 3.1 Launch an EC2 Instance
1. In **EC2 Dashboard**, click **Launch Instance**.
2. Configure:
   - **AMI**: Ubuntu Server 22.04.
   - **Instance Type**: t2.micro (free-tier eligible).
   - **Subnet**: `Public-Subnet`.
   - Assign a public IP.
   - **Key Pair**: Skip if connecting without a key pair.
3. Attach an **Elastic IP** for public reachability.

**Screenshot Placeholder**: Add a screenshot of the EC2 instance launch details here.  
`![EC2 Launch Screenshot](./images/ec2-launch.png)`

#### 3.2 Install Nginx and PHP
1. Connect to the EC2 instance using SSH or EC2 Instance Connect.
2. Update and install required software:
   ```bash
   sudo apt update
   sudo apt install nginx php php-mysql -y
   sudo systemctl start nginx
   sudo systemctl enable nginx
   ```
3. Test Nginx by visiting `http://<Elastic-IP>` in your browser.

**Screenshot Placeholder**: Add a screenshot of the Nginx welcome page here.  
`![Nginx Test Screenshot](./images/nginx-test.png)`

#### 3.3 Deploy PHP Application
1. Create a PHP file:
   ```bash
   sudo nano /var/www/html/index.php
   ```
2. Add the following code to connect to RDS:
   ```php
   <?php
   $conn = new mysqli("your-rds-endpoint", "admin", "yourpassword", "webapp");
   if ($conn->connect_error) {
       die("Connection failed: " . $conn->connect_error);
   }
   echo "Connected successfully!";
   ?>
   ```
3. Save the file and test it at `http://<Elastic-IP>/index.php`.

**Screenshot Placeholder**: Add a screenshot of the PHP connection test here.  
`![PHP Connection Test Screenshot](./images/php-test.png)`

---

### **Step 4: Database Tier Deployment**
#### 4.1 Create an RDS MySQL Database
1. Go to the **RDS Dashboard**.
2. Click **Create Database** and configure:
   - **Engine**: MySQL 8.0.
   - **Instance Class**: db.t3.micro.
   - **Storage**: 20 GB.
   - Enable **Multi-AZ Deployment**.
   - Disable **Public Access**.
3. Assign the **Database Security Group** to this instance.

**Screenshot Placeholder**: Add a screenshot of the RDS instance configuration here.  
`![RDS Instance Screenshot](./images/rds-instance.png)`

#### 4.2 Initialize the Database
1. Connect to the RDS instance from the EC2 server:
   ```bash
   mysql -h <RDS-ENDPOINT> -u admin -p
   ```
2. Create a database and table:
   ```sql
   CREATE DATABASE webapp;
   USE webapp;
   CREATE TABLE users (id INT PRIMARY KEY, name VARCHAR(50));
   INSERT INTO users VALUES (1, 'Cloud Engineer');
   ```

**Screenshot Placeholder**: Add a screenshot of database initialization commands here.  
`![Database Initialization Screenshot](./images/database-init.png)`

---

### **Step 5: Testing and Verification**
1. Open `http://<Elastic-IP>/index.php` in your browser.
2. If configured correctly, you should see **Connected successfully!**.
3. Verify the database connection by querying the `users` table.

**Screenshot Placeholder**: Add a screenshot of the final test result here.  
`![Final Test Screenshot](./images/final-test.png)`
