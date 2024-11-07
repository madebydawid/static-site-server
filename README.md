# Quick Guide to Setting Up a VM in Azure

## Overview
This guide provides concise instructions for setting up a Virtual Machine (VM) in Azure using the Microsoft Azure Portal. The steps below follow the official [Microsoft documentation](https://learn.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-portal?tabs=ubuntu) and outline the essential process to get an Ubuntu-based VM up and running.

## Steps to Create an Ubuntu VM

### 1. Sign In to the Azure Portal
- Go to [https://portal.azure.com](https://portal.azure.com) and log in with your Azure credentials.

### 2. Create a Virtual Machine
- In the left-hand menu, click **"Create a resource"**.
- Search for **"Virtual Machine"** and select **"Create"**.
- Fill in the following details:
  - **Subscription**: Choose your subscription.
  - **Resource Group**: Select an existing group or create a new one.
  - **Virtual machine name**: Enter a name for your VM.
  - **Region**: Choose the region closest to your location.
  - **Image**: Select **Ubuntu Server 24.04 LTS**.
  - **Size**: Choose an appropriate size for your needs (e.g., Standard DS1 v2).

### 3. Configure Administrator Account
- Under **Administrator account**, choose **SSH public key**.
- Enter your **username**.
- Paste your **SSH public key** (generated locally with `ssh-keygen`).

### 4. Configure Networking
- In the **Networking** tab, review the default settings:
  - Ensure **Virtual network** and **Subnet** are set.
  - Set **Public IP** to "Enabled" for external access.
  - Keep **NIC network security group** as "Basic" to enable SSH access.

### 5. Review and Create
- Click **Review + create**.
- Verify the configurations and click **Create** to deploy the VM.

### 6. Connect to Your VM
- Once the VM is deployed, navigate to the **Virtual Machines** section in the portal.
- Select your VM and copy its **public IP address**.
- Connect using SSH:
  ```bash
  ssh username@your-vm-public-ip
  ```

## Update and Install Nginx
- Update package-list on the server with

```bash
sudo apt update && sudo apt upgrade -y
```
- Install Nginx
```bash
sudo apt install nginx -y
```
- Start and activate Nginx
```bash
sudo systemctl start nginx
sudo systemctl enable nginx
```
- Control that Nginx is running
```bash
sudo systemctl status nginx
```
*If you see "active (running)", then Nginx is running correctly*

## Create and prepare a simple static webpage

- Create a local folder for your website (on your machine)
```bash
mkdir ~/my-static-site
cd ~/my-static-site
```
- Create a simple HTML-file
```html
echo '<!DOCTYPE html>
<html>
<head>
    <title>Dawids Static Site</title>
    <link rel="stylesheet" type="text/css" href="styles.css">
</head>
<body>
    <h1>Welcome to My Static Site!</h1>
    <p>This is a simple static website hosted with Nginx, as part of [Roadmap.sh](https://roadmap.sh/projects/static-site-server) project.</p>
    <img src="image.jpg" alt="Sample Image">
</body>
</html>' > index.html
```
- Add a styles.css file
```css
echo 'body {
    font-family: Arial, sans-serif;
    text-align: center;
}
h1 {
    color: #2c3e50;
}' > styles.css
```

- Add an image file
Place an image in the same directory and name it `image.jpg` (use your preferred image)

## Configure Nginx for hosting the website
- Copy files to the Server using `scp`
```bash
scp -r ~/my-static-site/* username@your-vm-public-ip:/var/www/html/
```
- Edit `Nginx config`-file to Serve the Site
```bash
sudo nano /etc/nginx/sites-available/default
```
- Modify the `root` directive to point to your website
```bash
root /var/www/html;
index index.html;
```
- Test Nginx Configuration by checking for syntax errors
```bash
sudo nginx -t
```
- Reload Nginx
```bash
sudo systemctl reload nginx
```

- Verify the Webpage in your browser
```vbnet
http://your-vm-public-ip
```
[static-site-working](add link)

## Set up rsync for Easy Deployment (Optional)
If you want to streamline updating your static site, you can use `rsync` to deploy changes to the server.

- **Install** `rsync`
```bash
sudo apt install rsync -y
```

- **Create a `deploy.sh` script on your local machine**: 
```bash
nano deploy.sh
```
- **Add content** to the script
```bash
#!/bin/bash

LOCAL_DIR="~/sitename/"         # Replace 'site-name' with the name of your local folder
REMOTE_USER="azure-user"        # Replace with your actual username on the VM
REMOTE_HOST="your-public-vm-ip" # Replace with the public IP address of your VM
REMOTE_DIR="/var/www/html"      # Path on the server where the files should be deployed
SSH_KEY="path/to/id_rsa"        # Replace with the full path to your private SSH key (e.g., ~/.ssh/id_rsa)

# Function to run a command with error checking
run_command() {
    if ! "$@"; then
        echo "Error: Command failed: $*"
        exit 1
    fi
}

# Ensure the remote directory exists and has correct permissions
echo "Setting up remote directory..."
run_command ssh -i "$SSH_KEY" "$REMOTE_USER@$REMOTE_HOST" "sudo mkdir -p $REMOTE_DIR && sudo chown -R $REMOTE_USER:$REMOTE_USER $REMOTE_DIR && sudo chmod -R 755 $REMOTE_DIR"

# Sync files
echo "Syncing files..."
run_command rsync -avz --chmod=D755,F644 -e "ssh -i $SSH_KEY" "$LOCAL_DIR" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR"

# Set correct permissions after sync
echo "Setting final permissions..."
run_command ssh -i "$SSH_KEY" "$REMOTE_USER@$REMOTE_HOST" "sudo chown -R nginx:nginx $REMOTE_DIR && sudo chmod -R 755 $REMOTE_DIR"

echo "Deployment completed successfully!"

```

- **Make the script executable**
```bash
chmod -x deploy.sh
```
- **Run the script to deploy your site**
```bash
./deploy.sh
```

---
[Link to roadmap.sh project](https://roadmap.sh/projects/static-site-server)