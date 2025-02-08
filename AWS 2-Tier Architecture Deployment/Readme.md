# AWS 2-Tier Architecture Deployment

This project demonstrates the deployment of a highly available and secure **2-tier architecture** in AWS, comprising a web tier (EC2 running PHP) and a database tier (RDS MySQL). Below is a complete guide with step-by-step instructions.

---

## **Project Architecture**
![Architecture Diagram](https://github.com/Wasiu-lab/Cloud-Engineering/blob/main/AWS%202-Tier%20Architecture%20Deployment/AWS/2%20tier.drawio.png)  
*Figure 1: High-Level Architecture Diagram.*

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

### **VPC and Networking**
A custom VPC was created with a CIDR block of `10.0.0.0/26` to serve as the networking backbone. Four subnets were configured:
- **Public Subnets:** `10.0.0.0/28` and `10.0.0.16/28` for hosting web-tier resources.
- **Private Subnets:** `10.0.0.32/28` and `10.0.0.48/28` for the database tier.

An Internet Gateway was attached to the VPC to allow Internet connectivity for resources in public subnets. A NAT Gateway was deployed in a public subnet to provide secure Internet access for resources in private subnets. The route tables were configured to route external traffic from public subnets through the Internet Gateway and traffic from private subnets through the NAT Gateway.

*(Insert screenshot of VPC and subnets configuration here)*

### **Security Configuration**
Two Security Groups were created to enforce strict access controls:
1. **Web Security Group:**
   - Allows inbound traffic on port 80 (HTTP) and 443 (HTTPS) from all sources.
   - Allows SSH (port 22) from a trusted IP address.
   - Allows outbound traffic to the database on port 3306 (MySQL).
2. **Database Security Group:**
   - Allows inbound traffic on port 3306 only from the Web Security Group.
   - Allows outbound traffic for software updates.

*(Insert screenshot of Security Group configuration here)*

### **Web Tier**
An EC2 instance was deployed in one of the public subnets to serve as the web server. An Elastic IP was attached to the instance for consistent public reachability. Nginx was installed as the web server, and PHP was configured to host a sample application. The PHP application connects to the RDS database to perform basic data operations.



*(Insert screenshot of EC2 instance configuration here)*

### **Database Tier**
An Amazon RDS MySQL instance was deployed in the private subnets. Multi-AZ deployment was enabled for high availability, and public access was disabled to ensure security. The database accepts connections only from the Web Security Group. A sample database (`webapp`) and table (`users`) were created for testing purposes.

*(Insert screenshot of RDS instance configuration here)*

### **Application Deployment**
A PHP application was deployed on the web server to connect to the RDS database. Below is the PHP script used:

```php
<?php
$conn = new mysqli("your-rds-endpoint", "admin", "yourpassword", "webapp");
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
echo "Connected successfully!";
?>
```

This script was saved in `/var/www/html/index.php` and tested by accessing the public IP address of the web server.

*(Insert screenshot of application output here)*

---

## **Testing and Validation**
- Verified that the web server is publicly accessible via HTTP/HTTPS.
- Tested the database connectivity using the PHP application.
- Ensured secure communication between the web tier and database tier.

*(Insert screenshots of test results here)*

---

## **Conclusion**
This project demonstrates the deployment of a scalable and secure 2-tier architecture in AWS, incorporating best practices for high availability, fault tolerance, and security. The architecture ensures seamless integration between the web and database tiers, providing a robust environment for hosting applications.

