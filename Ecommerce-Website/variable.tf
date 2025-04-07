variable "vpc_cidr" {
    default = "10.0.0.0/16"
    description = "CIDR block for the VPC"
    type = string
}

variable "public-subnet-1_cidr" {
    default = "10.0.0.0/24"
    description = "CIDR block for Public Subnet 1"
    type = string
}

variable "public-subnet-2_cidr" {
    default = "10.0.1.0/24"
    description = "CIDR block for Public Subnet 2"
    type = string
}

variable "private-subnet-1_cidr" {
    default = "10.0.2.0/24"
    description = "CIDR block for Private Subnet 1"
    type = string
}

variable "private-subnet-2_cidr" {
    default = "10.0.3.0/24"
    description = "CIDR block for Private Subnet 2"
    type = string
}

variable "private-subnet-3_cidr" {
    default = "10.0.4.0/24"
    description = "CIDR block for Private Subnet 3"
    type = string
}

variable "private-subnet-4_cidr" {
    default = "10.0.5.0/24"
    description = "CIDR block for Private Subnet 4"
    type = string
}

variable "ssh_location" {
    default = "0.0.0.0/0" # Best practise should be restrcicted to your location 
    description = "IP Address that can SSH into EC2 instance"
    type = string
}

variable "database-snapshot_identifier" {
    default = ""
    description = "Database snapshot ARN"
    type = string
}

variable "database-instance-instance_class" {
    default = "db.t2.micro"
    description = "The database instance type"
    type = string
}