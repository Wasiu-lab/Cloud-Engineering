# Create Security Group for the Application Load Balancer
# terraform aws create security group
resource "aws_security_group" "alb-security-group" {
  name        = "ALB Security Group"
  description = "Enable HTTP and HTTPS access to the ALB"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "Allow HTTP access to the ALB"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Allow HTTPS access to the ALB"
    from_port        = 443
    to_port          =443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags   = {
    Name = "ALB Security Group"
  }
}

# Create Security Group for the Bastion Host aka Jump Box
# terraform aws create security group
resource "aws_security_group" "ssh-security-group" {
  name        = "SSH Security Group"
  description = "Enable SSH access to the Bastion Host"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "Allow SSH access to the Bastion Host"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["${var.ssh_location}"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags   = {
    Name = "SSH Security Group"
  }
}

# Create Security Group for the Web Server
# terraform aws create security group
resource "aws_security_group" "webserver-security-group" {
  name        = "Web Server Security Group"
  description = "Enable HTTP and HTTPS access to the Web Server"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "Allow HTTP access to the Web Server"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    # The SG should allow access only from the ALB security group
    # This allows the ALB to communicate with the Web Server
    security_groups  = ["${aws_security_group.alb-security-group.id}"]
  }

  ingress {
    description      = "Allow HTTPS access to the Web Server"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    # The SG should allow access only from the ALB security group
    security_groups  = ["${aws_security_group.alb-security-group.id}"]
  }

  ingress {
    description      = "Allow SSH access to the Web Server"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    # The SG should allow access only from the SSH security group
    security_groups  = ["${aws_security_group.ssh-security-group.id}"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    # The SG should allow all outbound traffic
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags   = {
    Name = "Web Server Security Group"
  }
}

# Create Security Group for the Database
# terraform aws create security group
resource "aws_security_group" "database-security-group" {
  name        = "Database Security Group"
  description = "Enable MySQL/Aurora access to the Database"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "Allow MySQL/Aurora access to the Database"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups  = ["${aws_security_group.webserver-security-group.id}"]
    # The SG should allow access only from the Web Server security group
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags   = {
    Name = "Database Security Group"
  }
}