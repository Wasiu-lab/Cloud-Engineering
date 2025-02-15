# Setting Up NGINX as a Load Balancer and Reverse Proxy

## Introduction
NGINX is a powerful web server that can be used as a **reverse proxy** and **load balancer** to distribute traffic across multiple backend servers. The aim of this documentation will set up NGINX on **Ubuntu**, configure it to serve two different websites, and implement a **load balancer** to manage traffic efficiently.

## Load Balancer 
Load balancing is the method of distributing network traffic equally across a pool of resources that support an application which the tool used for load balancing is a **Load Balancer**

## Prerequisites
Ensure you have the following before proceeding:
- An **Ubuntu** system
- Basic knowledge of Linux terminal commands
- Sudo privileges

## Step 1: Install NGINX
First, update your package lists and install NGINX using the following command:
```bash
sudo apt update
sudo apt install nginx -y
```

After installation, check if NGINX is running by accessing **localhost**:
```bash
http://127.0.0.1:80
```
_NGINX default welcome page should be visible._  
**📌 [Insert an image of the NGINX welcome page]**

## Step 2: Download and Extract Website Files
We need two different websites to serve. Download them using `wget`:
```bash
sudo wget [Website 1 URL]
sudo wget [Website 2 URL]
```
Extract them after downloading:
```bash
sudo unzip website1.zip
sudo unzip website2.zip
```

## Step 3: Organize Website Files in `/var/www`
Navigate to the NGINX web root directory:
```bash
cd /var/www
```
Create separate directories for the two websites:
```bash
sudo mkdir site1
sudo mkdir site2
```
Move the extracted website files into the respective folders:
```bash
sudo mv /path/to/website1/* /var/www/site1
sudo mv /path/to/website2/* /var/www/site2
```

## Step 4: Configure NGINX for Both Websites
Navigate to the NGINX configuration directory:
```bash
cd /etc/nginx/sites-enabled
```
By default, you will find a file named `default`. We will create two separate configuration files for our websites.

Create a new configuration file for **Site 1**:
```bash
sudo nano /etc/nginx/sites-available/site1
```
Paste the following configuration:
```nginx
server {
    listen 90;
    listen [::]:90;
    server_name site1.local;

    root /var/www/site1;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
```
Save and exit (`CTRL + X`, then `Y`, then `ENTER`).

Now, create another configuration file for **Site 2**:
```bash
sudo nano /etc/nginx/sites-available/site2
```
Paste this configuration:
```nginx
server {
    listen 95;
    listen [::]:95;
    server_name site2.local;

    root /var/www/site2;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
```
Save and exit.

Enable both sites by creating symbolic links:
```bash
sudo ln -s /etc/nginx/sites-available/site1 /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/site2 /etc/nginx/sites-enabled/
```
Restart NGINX for changes to take effect:
```bash
sudo systemctl restart nginx
```
Now, test if both websites are accessible by visiting:
- **Site 1** → `http://127.0.0.1:90`
- **Site 2** → `http://127.0.0.1:95`

**📌 [Insert screenshots of both websites running]**

## Step 5: Configure NGINX as a Load Balancer
Now, we will set up NGINX to distribute traffic between the two websites.

Navigate to the NGINX configuration directory:
```bash
cd /etc/nginx/sites-available
```
Open the default configuration file:
```bash
sudo nano /etc/nginx/sites-available/default
```
Replace its contents with the following:
```nginx
upstream backend {
    server 127.0.0.1:90;
    server 127.0.0.1:95;
}

server {
    listen 80;
    listen [::]:80;

    location / {
        proxy_pass http://backend;
    }
}
```
Save and exit.

Restart NGINX for the load balancer to take effect:
```bash
sudo systemctl restart nginx
```

## Step 6: Test the Load Balancer
Visit `http://127.0.0.1` in your browser. You should see that requests are being routed between **Site 1** and **Site 2**.

**📌 [Insert a GIF showing load balancing in action]**

## Conclusion
We have successfully configured **NGINX as a Load Balancer and Reverse Proxy**. Now, all requests made to `http://127.0.0.1` will be distributed between the two sites, improving reliability and efficiency.

### Additional Commands
- To check NGINX status:
  ```bash
  sudo systemctl status nginx
  ```
- To reload NGINX after making changes:
  ```bash
  sudo systemctl reload nginx
  ```
- To check for syntax errors before restarting:
  ```bash
  sudo nginx -t
  ```

### Next Steps
- Secure your NGINX setup with **SSL/TLS**.
- Configure **NGINX caching** for better performance.
- Implement **rate limiting** and **firewall rules** for security.

---
🚀 *Happy Hosting with NGINX!*


