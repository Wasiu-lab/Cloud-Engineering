# **FinPayTech Cloud Network Architecture**

## **Project Overview**
FinPayTech is a financial technology company that requires a **secure, scalable, and highly available** cloud network infrastructure. This project involves setting up a Virtual Private Cloud (VPC) with a **multi-tier architecture** in AWS, ensuring optimized security and efficient resource allocation.

---
## **Network Architecture**
### **VPC Design Overview**
The network is divided into **four subnets** within the FinPayTech VPC. It includes both **public and private subnets** across two availability zones (AZ1 and AZ2) to ensure high availability and fault tolerance.

### **AWS Components Used**:
- **VPC**: Isolated network within AWS (CIDR: `172.16.0.0/25`)
- **Internet Gateway (IGW)**: Enables internet access for public subnets
- **Public Subnets**: Host web servers and bastion hosts
- **Private Subnets**: Contain application servers and RDS Proxy databases
- **Route Tables**: Define traffic flow rules between subnets
- **AWS RDS Proxy**: Improves database connection management

### **Network Calculation Table**

| Subnet Name | CIDR Block | Subnet Mask | Total IPs | AWS Reserved IPs | Usable IPs |
|------------|-----------|-------------|-----------|----------------|------------|
| AZ1-Public_Subnet | 172.16.0.0/26 | 255.255.255.192 | 64 | 5 | 59 |
| AZ2-Public_Subnet | 172.16.0.64/27 | 255.255.255.224 | 32 | 5 | 27 |
| AZ1-Private_Subnet | 172.16.0.96/28 | 255.255.255.240 | 16 | 5 | 11 |
| AZ2-Private_Subnet | 172.16.0.112/29 | 255.255.255.248 | 8 | 5 | 3 |


---
## **Business Case for FinPayTech VPC**
### **Problem Statement:**
FinPayTech provides financial services, requiring a cloud network that is **secure, scalable, and compliant** with financial regulations.

### **Solution:**
1. **Multi-Tier Network Design**:
   - **Public Subnets** for web servers and load balancers.
   - **Private Subnets** for backend applications and databases.
2. **Security Enhancements**:
   - Use of **AWS Security Groups & NACLs** for access control.
   - **VPC Flow Logs** to monitor network activity.
   - **Encryption** at transit and rest.
3. **Performance Optimization:**
   - **Auto Scaling Groups** for handling increased traffic.
   - **AWS RDS Proxy** for improved database efficiency.
4. **Cost Optimization:**
   - **Reserved Instances & Savings Plans** for database services.
   - **AWS Cost Explorer** for monitoring expenses.
5. **High Availability & Disaster Recovery:**
   - Multi-AZ deployment ensures redundancy.
   - AWS **Backup & Snapshot** policies for resilience.

---
## **Project Screenshots**

### **1. Internet Gateway (IGW) Setup**
![Internet Gateway](./mnt/data/igw.PNG)

### **2. Subnet Configuration**
![Subnet](./mnt/data/subnet.PNG)

### **3. VPC Details**
![VPC](./mnt/data/vpc.PNG)
