#!/bin/bash

# Exit on error
set -e

# Update package list
echo "Updating package list..."
sudo dnf update -y

# Install Docker
echo "Installing Docker..."
sudo dnf install -y docker
sudo systemctl start docker
sudo systemctl enable docker

# Install Nginx
echo "Installing Nginx..."
sudo dnf install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Install unzip
echo "Installing unzip..."
sudo dnf install -y unzip

# Install AWS CLI using curl method
echo "Installing AWS CLI..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Clean up the AWS CLI installer files
echo "Cleaning up AWS CLI installer files..."
rm -rf awscliv2.zip aws/

# Pull WordPress Docker image
echo "Pulling WordPress Docker image..."
sudo docker pull wordpress

# Run WordPress container
echo "Running WordPress container..."
sudo docker run -d -p 8080:80 --name wordpress wordpress

# Create Nginx configuration for reverse proxy
echo "Configuring Nginx reverse proxy for yahya-aws-0.yahyaabdullahsaadsubata.online..."
sudo bash -c 'cat > /etc/nginx/conf.d/yahya-aws-0.yahyaabdullahsaadsubata.online.conf <<EOF
server {
    listen 80;
    server_name yahya-aws-0.yahyaabdullahsaadsubata.online;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF'

# Test Nginx configuration
echo "Testing Nginx configuration..."
sudo nginx -t

# Restart Nginx to apply changes
echo "Restarting Nginx..."
sudo systemctl restart nginx

# Success message
echo "Docker, Nginx, AWS CLI installed and WordPress is running with reverse proxy configured!"