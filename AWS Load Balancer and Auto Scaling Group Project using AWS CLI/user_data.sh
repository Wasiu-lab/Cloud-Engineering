#!/bin/bash 
yum update -y 
yum install -y httpd 
echo "<h1>Hello Abdulwasiu, Welcome to My Simple Demo App</h1>" > /var/www/html/index.html 
systemctl start httpd 
systemctl enable httpd 