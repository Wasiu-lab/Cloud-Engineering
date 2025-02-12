# AWS 2-Tier Architecture Deployment

This project demonstrates the deployment of a highly available and secure **2-tier architecture** in AWS, comprising a web tier (EC2 running PHP) and a database tier (RDS MySQL). Below is a complete guide with step-by-step instructions.

---

## **Project Architecture**
![Architecture Diagram](https://github.com/Wasiu-lab/Cloud-Engineering/blob/main/AWS%202-Tier%20Architecture%20Deployment/AWS/2%20tier.drawio.png)  
*High-Level Architecture Diagram.*

This architecture represents a **highly available and secure 2-tier application setup** in AWS, consisting of a web tier and a database tier within a Virtual Private Cloud (VPC) with a CIDR block of `10.0.0.0/26`. The web servers are hosted in public subnets (`10.0.0.0/28` and `10.0.0.16/28`) and are accessible via an Internet Gateway (IGW) for handling HTTP/HTTPS requests, while the database is hosted in private subnets (`10.0.0.32/28` and `10.0.0.48/28`) to ensure it is not directly exposed to the Internet. A NAT Gateway in the public subnet provides outbound Internet access for private resources. Security Groups are used to control traffic: the web tier allows HTTP, HTTPS, and SSH traffic from trusted sources, while the database tier only accepts traffic from the web tier on port 3306. The architecture spans multiple Availability Zones (AZs) for high availability and fault tolerance. Users interact with the web servers, which securely connect to the database to process and store data, ensuring a scalable, robust, and secure system.

---

## **Project Scope**

The goal of this project is to design, configure, and deploy a 2-tier architecture with the following components:

1. **VPC and Networking Configuration:**
   - Custom VPC with four subnets (two public, two private).
   - Internet Gateway for public subnet Internet access.
   - NAT Gateway for private subnet outbound connectivity.
2. **Security Groups:**
   - Web Security Group for HTTP, HTTPS, and SSH access.
   - Database Security Group allowing only web server connections.
3. **Web Tier:**
   - EC2 instance hosting Nginx and a PHP application.
4. **Database Tier:**
   - Amazon RDS MySQL instance for data storage.
5. **Application Deployment:**
   - PHP application connecting to the database for dynamic data processing.

---

## **Implementation Details**

### **1. VPC and Networking**

![VPC configuration](https://github.com/Wasiu-lab/Cloud-Engineering/blob/main/AWS%202-Tier%20Architecture%20Deployment/AWS/Vpc%20creation.PNG)
*VPC configuration.*

A custom VPC was created with a CIDR block of `10.0.0.0/26` to serve as the networking backbone. Four subnets were configured:
- **Public Subnets:** `10.0.0.0/28` and `10.0.0.16/28` for hosting web-tier resources.
- **Private Subnets:** `10.0.0.32/28` and `10.0.0.48/28` for the database tier.
  
An Internet Gateway was attached to the VPC to allow Internet connectivity for resources in public subnets. A NAT Gateway was deployed in a public subnet to provide secure Internet access for resources in private subnets. The route tables were configured to route external traffic from public subnets through the Internet Gateway and traffic from private subnets through the NAT Gateway. Route for `0.0.0.0/0` pointing to the Internet Gateway for the public route table while another route `0.0.0.0/0` pointing to a NAT Gateway for the private route table.

#### Create Subnets
1. Create a **Public Subnet**:
   - **Name**: `Public-Subnet`.
   - **Availability Zone**: `us-east-1a`.
   - **CIDR Block**: `10.0.0.0/28`.
   - Enable **Auto-assign Public IP**.

![Public Subnet Configuration](https://github.com/Wasiu-lab/Cloud-Engineering/blob/main/AWS%202-Tier%20Architecture%20Deployment/AWS/pub%20sub%201.PNG)
*Public Subnet Configuration.* 

2. Create a **Private Subnet**:
   - **Name**: `Private-Subnet`.
   - **Availability Zone**: `us-east-1b`.
   - **CIDR Block**: `10.0.0.32/28`.

![Private Subnet Configuration](https://github.com/Wasiu-lab/Cloud-Engineering/blob/main/AWS%202-Tier%20Architecture%20Deployment/AWS/private%20sub%201.PNG)
*Private Subnet Configuration.*

#### Attach an Internet Gateway
1. Create an **Internet Gateway** in the **VPC Dashboard**.
2. Attach the IGW to your VPC.

IGW Creation             |  Attching to VPC
:-------------------------:|:-------------------------:
![IGW Creation](https://github.com/Wasiu-lab/Cloud-Engineering/blob/main/AWS%202-Tier%20Architecture%20Deployment/AWS/IGW%20retatin.PNG)  |  ![Attching to VPC](https://github.com/Wasiu-lab/Cloud-Engineering/blob/main/AWS%202-Tier%20Architecture%20Deployment/AWS/attching%20igw%20to%20vpc.PNG)

#### Configure Route Tables
1. **Public Route Table**:
   - Associate the public subnet with this route table.
   - Add a route for `0.0.0.0/0` pointing to the Internet Gateway.
2. **Private Route Table**:
   - Associate the private subnet with this route table.
   - Add a route for `0.0.0.0/0` pointing to a **NAT Gateway**.

**Screenshot Placeholder**: Add screenshots of public and private route table configurations here.  
`![Route Table Configuration Screenshot](./images/route-tables.png)`

#### Create a NAT Gateway
1. In **NAT Gateways**, create a NAT Gateway in the **Public Subnet**.
2. Allocate an Elastic IP for the NAT Gateway.
3. Ensure the private route table uses this NAT Gateway for internet-bound traffic.

**Screenshot Placeholder**: Add a screenshot of the NAT Gateway setup here.  
`![NAT Gateway Setup Screenshot](./images/nat-gateway.png)`

### **2. Security Configuration**
Two Security Groups were created to enforce strict access controls:
1. **Web Security Group:**
   - Allows inbound traffic on port 80 (HTTP) and 443 (HTTPS) from all sources.
   - Allows SSH (port 22) from a trusted IP address.
   - Allows outbound traffic to the database on port 3306 (MySQL).
2. **Database Security Group:**
   - Allows inbound traffic on port 3306 only from the Web Security Group.
   - Allows outbound traffic for software updates.

*(Insert screenshot of Security Group configuration here)*

### **3. Web Tier**
An EC2 instance was deployed in one of the public subnets to serve as the web server. An Elastic IP was attached to the instance for consistent public reachability.

#### Install Nginx and PHP
1. Connect to the EC2 instance using SSH or EC2 Instance Connect.
2. Update and install the required software:
   ```bash
   sudo apt update
   sudo apt install nginx php php-mysql -y
   sudo systemctl start nginx
   sudo systemctl enable nginx
   ```
3. Test Nginx by visiting `http://<Elastic-IP>` or using the public ip address attached to the EC2 instance in your browser.

**Screenshot Placeholder**: Add a screenshot of the Nginx welcome page here.  
`![Nginx Test Screenshot](./images/nginx-test.png)`

*(Insert screenshot of EC2 instance configuration here)*

### **4. Database Tier**
An Amazon RDS MySQL instance was deployed in the private subnets. Multi-AZ deployment was enabled for high availability, and public access was disabled to ensure security. The database accepts connections only from the Web Security Group. A sample database (`webapp`) and table (`users`) were created for testing purposes.

*(Insert screenshot of RDS instance configuration here)*

---

#### Initialize the Database
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

#### **5. Deploy PHP Application**
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

### **6. Testing and Verification**
1. Open `http://<Elastic-IP>/index.php` in your browser.
2. If configured correctly, you should see **Connected successfully!**.
3. Verify the database connection by querying the `users` table.

**Screenshot Placeholder**: Add a screenshot of the final test result here.  
`![Final Test Screenshot](./images/final-test.png)`

---

## **Conclusion**
This project demonstrates the deployment of a scalable and secure 2-tier architecture in AWS, incorporating best practices for high availability, fault tolerance, and security. The architecture ensures seamless integration between the web and database tiers, providing a robust environment for hosting applications.

