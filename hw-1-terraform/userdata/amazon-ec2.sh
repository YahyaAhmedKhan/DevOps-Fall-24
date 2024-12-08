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

# Install Git
echo "Installing Git..."
sudo dnf install -y git

# Clone the React app from GitHub
echo "Cloning the React app repository..."
REPO_URL="https://github.com/YahyaAhmedKhan/reactapp-devops-hafeez.git"
APP_DIR="reactapp"
if [ -d "$APP_DIR" ]; then
    echo "Directory $APP_DIR already exists. Pulling latest changes..."
    cd $APP_DIR && git pull && cd ..
else
    git clone $REPO_URL $APP_DIR
fi
cd $APP_DIR

# Step 1: Create a standard Dockerfile
echo "Creating standard Dockerfile for React app..."
cat > Dockerfile <<EOF
FROM node:16-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
EOF

# Check if the image already exists and remove it if it does
if [ "$(sudo docker images -q reactapp-standard)" ]; then
    echo "Removing existing image 'reactapp-standard'..."
    sudo docker rmi reactapp-standard || true
fi

# Build the standard Docker image
echo "Building standard Docker image for React app..."
sudo docker build -t reactapp-standard .

# Check if the container already exists and remove it if it does
if [ "$(sudo docker ps -a -q -f name=reactapp-standard)" ]; then
    echo "Stopping and removing existing container 'reactapp-standard'..."
    sudo docker stop reactapp-standard || true
    sudo docker rm reactapp-standard || true
fi

# Run the standard Docker container
echo "Running standard Docker container for React app..."
sudo docker run -d -p 3000:3000 --name reactapp-standard reactapp-standard

# Step 2: Modify the Dockerfile to use multi-stage build
echo "Modifying Dockerfile for multi-stage build..."
cat > Dockerfile <<EOF
# Stage 1: Build the React app
FROM node:16-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Stage 2: Serve React app with Nginx
FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
EOF

# Check if the image already exists and remove it if it does
if [ "$(sudo docker images -q reactapp-multistage)" ]; then
    echo "Removing existing image 'reactapp-multistage'..."
    sudo docker rmi reactapp-multistage || true
fi

# Build the multi-stage Docker image
echo "Building multi-stage Docker image for React app..."
sudo docker build -t reactapp-multistage .

# Check if the container already exists and remove it if it does
if [ "$(sudo docker ps -a -q -f name=reactapp-multistage)" ]; then
    echo "Stopping and removing existing container 'reactapp-multistage'..."
    sudo docker stop reactapp-multistage || true
    sudo docker rm reactapp-multistage || true
fi

# Run the multi-stage Docker container using Nginx
echo "Running multi-stage Docker container for React app..."
sudo docker run -d -p 8080:80 --name reactapp-multistage reactapp-multistage

# Configure Nginx for reverse proxy
echo "Configuring Nginx reverse proxy for reactapp.yahyaabdullahsaadsubata.online..."
sudo bash -c 'cat > /etc/nginx/conf.d/reactapp.yahyaabdullahsaadsubata.online.conf <<EOF
server {
    listen 80;
    server_name yahya-hw1-amzn.yahyaabdullahsaadsubata.online;

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
echo "React app deployed in two stages: standard Docker build and multi-stage Docker build with Nginx reverse proxy!"
