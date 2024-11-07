#!/bin/bash

# Configuration
LOCAL_PATH="/d/static-site-server/dawids-static-site"  # Ange sökvägen till din lokala mapp med webbplatsfiler
REMOTE_USER="Panda"          # Ditt användarnamn på servern
REMOTE_HOST="51.12.60.115" # Serverns IP-adress
REMOTE_PATH="/var/www/html/dawids-static-site"  # Den sökväg på servern där webbplatsen ska kopieras

# Sync files to the server
echo "Deploying files to the server..."
rsync -avz --delete $LOCAL_PATH $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH

# Check if the deployment was successful
if [ $? -eq 0 ]; then
    echo "Deployment completed successfully!"
else
    echo "Deployment failed. Please check for errors."
fi

