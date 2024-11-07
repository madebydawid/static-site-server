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