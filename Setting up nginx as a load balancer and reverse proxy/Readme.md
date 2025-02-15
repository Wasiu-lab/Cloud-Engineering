# Setting Up NGINX as a Load Balancer and Reverse Proxy

## Introduction
NGINX is a powerful web server that can be used as a **reverse proxy** and **load balancer** to distribute traffic across multiple backend servers. The aim of this documentation will set up NGINX on **Ubuntu**, configure it to serve two different websites, and implement a **load balancer** to manage traffic efficiently.

## Load Balancer 
Load balancing is the method of distributing network traffic equally across a pool of resources that support an application which the tool used for load balancing is a **Load Balancer**

## **Project Overview**
The aim of the project is to host two website running on nginx with both will have individual customized IP address whiCh wilL be ```127.0.0.1:90```  and ```127.0.0.1:95```. After hosting the site, we will set up a load balancer which will run on the webserver localhost port ```127.0.0.1:80``` which will also serve as a reverse proxy so that refreshing the locahost will switch between both websites that has been setup on the nginx webserver.
Site 1             |  Site 2
:-------------------------:|:-------------------------:
![Site1](https://github.com/Wasiu-lab/Cloud-Engineering/blob/main/Setting%20up%20nginx%20as%20a%20load%20balancer%20and%20reverse%20proxy/Pictures/site%201.PNG)  |  ![Site](https://github.com/Wasiu-lab/Cloud-Engineering/blob/main/Setting%20up%20nginx%20as%20a%20load%20balancer%20and%20reverse%20proxy/Pictures/site%202.PNG)

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
![NGINX welcome page](https://github.com/Wasiu-lab/Cloud-Engineering/blob/main/Setting%20up%20nginx%20as%20a%20load%20balancer%20and%20reverse%20proxy/Pictures/installing%20nginx.PNG)

After installation, check if NGINX is running by accessing **localhost**:
```bash
http://127.0.0.1:80
```
_NGINX default welcome page should be visible._  
![NGINX welcome page](https://github.com/Wasiu-lab/Cloud-Engineering/blob/main/Setting%20up%20nginx%20as%20a%20load%20balancer%20and%20reverse%20proxy/Pictures/nginx%20working.PNG)

## Step 2: Download and Extract Website Files
We need two different websites to serve. Download them using `wget`:
```bash
sudo wget https://github.com/startbootstrap/startbootstrap-agency/archive/gh-pages.zip 
sudo wget https://github.com/startbootstrap/startbootstrap-grayscale/archive/gh-pages.zip
```

Extract them after downloading:
```bash
sudo unzip gh-pages.zip
sudo unzip gh-pages.zip.1
```
   
![Site1](https://github.com/Wasiu-lab/Cloud-Engineering/blob/main/Setting%20up%20nginx%20as%20a%20load%20balancer%20and%20reverse%20proxy/Pictures/site%201%20downbload.PNG) 
**Download and Extract Website**

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
![Site1](https://github.com/Wasiu-lab/Cloud-Engineering/blob/main/Setting%20up%20nginx%20as%20a%20load%20balancer%20and%20reverse%20proxy/Pictures/creating%20folder%20for%20site%201%20n%202%20IN%20VAR.PNG) 

Folder creation in the var/www directory

Move the extracted website files into the respective folders:
```bash
sudo mv startbootstrap-agency-gh-pages/* /var/www/site1
sudo mv startbootstrap-grayscale-gh-pages/* /var/www/site2
```
then using the tree function to confirm if the file movement was sucsseful or not 
```bash
tree
```
![Site1](https://github.com/Wasiu-lab/Cloud-Engineering/blob/main/Setting%20up%20nginx%20as%20a%20load%20balancer%20and%20reverse%20proxy/Pictures/using%20the%20tree%20function%20to%20confirm%20file%20movement.PNG) 

Confirmation of website files movemnt into the respective folders 

## Step 4: Configure NGINX for Both Websites
Navigate to the NGINX configuration directory:
```bash
cd /etc/nginx/sites-enabled
```
By default, you will find a file named `default`. We will create two separate configuration files for our websites.

![Site1](https://github.com/Wasiu-lab/Cloud-Engineering/blob/main/Setting%20up%20nginx%20as%20a%20load%20balancer%20and%20reverse%20proxy/Pictures/creating%20config%20file%20for%20site%201%20and%202.PNG)

**Configuration file for both site**

***Create a new configuration file for **Site 1**:***
```bash
sudo nano /etc/nginx/sites-enabled/site1
```
Paste the following configuration:
```nginx
server {
       listen 90;
       #listen [::]:81;

       server_name site1.com;

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
sudo nano /etc/nginx/sites-enabled/site2
```
Paste this configuration:
```nginx
server {
       listen 95;
       #listen [::]:81;

       server_name site2.com;

       root /var/www/site2;
       index index.html;

       location / {
               try_files $uri $uri/ =404;
       }
}
```
Save and exit.

Restart NGINX for changes to take effect:
```bash
sudo systemctl restart nginx
```
Test if the configureation file are correctly configured 
```bash
nginx t
```

![Site1](https://github.com/Wasiu-lab/Cloud-Engineering/blob/main/Setting%20up%20nginx%20as%20a%20load%20balancer%20and%20reverse%20proxy/Pictures/checking%20if%20config%20for%20site%20available%20is%20working%20well.PNG)

Now, test if both websites are accessible by visiting:
- **Site 1** → `http://127.0.0.1:90`
- **Site 2** → `http://127.0.0.1:95`
  
Site 1             |  Site 2
:-------------------------:|:-------------------------:
![Site1](https://github.com/Wasiu-lab/Cloud-Engineering/blob/main/Setting%20up%20nginx%20as%20a%20load%20balancer%20and%20reverse%20proxy/Pictures/site%201%20working.PNG)  |  ![Site](https://github.com/Wasiu-lab/Cloud-Engineering/blob/main/Setting%20up%20nginx%20as%20a%20load%20balancer%20and%20reverse%20proxy/Pictures/site%202%20working.PNG)

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

---
🚀 *Happy Hosting with NGINX!*


