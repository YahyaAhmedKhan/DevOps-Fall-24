# Guide for Mids practice


## 1. Create a New User with SSH Key for Password-less Access

### Steps:

- Create a new user.
- Add the SSH key to the new user for passwordless login.
- Use the SSH key to SSH into the new user from your local machine.
### Commands:

- **SSH into your VM into a user with sudo privileges e.g. root, sysadmin etc.**

```bash
# Create a new user 
sudo adduser newuser

# Fill in the user's details, press enter to leave blank

# Add the user to the sudo group
sudo usermod -aG sudo newuser

# Switch to the new user
sudo su - newuser

# Create .ssh directory and set proper permissions
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Generate a key
ssh-keygen # this will make an RSA pair in ~/.ssh directory

# Copy your existing SSH public key (if it's in ~/.ssh/id_rsa.pub) to ~/.ssh/authorized_keys and set the correct permissions for that file
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Print out the private key, copy it, and paste it to your local machine's ~/.ssh directory in a new file
cat ~/.ssh/id_rsa # copy the printed contents
```
#### Local Machine

```bash
# Make a new file in your ~/.ssh directory
sudo nano ~/.ssh/privatekeyname 

# Paste the the private key's contents, write out/save the changes and exit nano

# Now try SSH access from your local machine using the key
ssh -i ~/.ssh/privatekeyname newuser@your-vms-ip
``` 

---

## 2. Create a Dockerfile and Build a Docker Image for Jenkins

### Steps:

- Make a new folder `jenkins` in your user's home directory
- Write a `Dockerfile` to install Jenkins.
- Build the Docker image.
 
```bash
cd ~/
mkdir jenkins
cd ~/jenkins
nano Dockerfile # Make sure you name the file exactly like this!
```

#### `Dockerfile`:

```Dockerfile
FROM jenkins/jenkins:lts 

USER root 

  

RUN mkdir -p /tmp/download && \ 

curl -L https://download.docker.com/linux/static/stable/x86_64/docker-18.03.1-ce.tgz | tar -xz -C /tmp/download && \ 

rm -rf /tmp/download/docker/dockerd && \ 

mv /tmp/download/docker/docker* /usr/local/bin/ && \ 

rm -rf /tmp/download && \ 

groupadd -g 999 docker && \ 

usermod -aG staff,docker jenkins 

  

USER jenkins
```

```bash
# Build the docker image. You should be in the directory containing the Dockerfile you just made. 

sudo docker build -t newuser-jenkins . # Don't forget the dot 
```
### Commands:

```bash
# Run the docker image from your Dockerfile

docker run -d --name newuser-jenkins -p 5003:8080 -p 5007:50000 -v newuser-jenkins:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock newuser-jenkins

# Don't forget to change the name of the contianer to yourname-jenkins
# Jenkins will now be running on 5003 
# You can replace 5003 and 5007 with any available ports (don't use 5060, 5061)


# Check if your container is running
sudo docker ps
```

### Troubleshooting

```bash
# To see all stopped and running containers do:
sudo docker ps -a

# Stop and remove your container with 
sudo docker stop container_id
sudo docker rm container_id

# To see images and remove them use:
sudo docker images
sudo docker rmi image_id # previous command will show image IDs
```

---
## 4. Create a New Git Repository and Push Code

### Steps:

- Create a new Git repository on your Github account.
- Pull the code from sir's Github Repo from this [link](https://github.com/Khhafeez47/nodeapp-iba)
- Make sure you have set up [SSH authentication](#setting-up-ssh-authentication-on-github) on your Github before this.

### Commands:

```bash
# Clone the teacher's repository
git clone <teacher-repo-url> nodeapp

# Navigate to the cloned repository
cd nodeapp

# Remove the existing Git configuration
rm -rf .git

# Reinitialize the Git repository
git init

# Add your own remote repository 
git remote add origin <your-repo-url>

# Stage all changes
git add .

# Commit the changes
git commit -m "inital commit"

# Pull changes from your repository to update the README
git fetch
git pull origin main --allow-unrelated-histories

# Resolve any merge conflicts if applicable
# (Manually edit files, then stage the resolved changes)
git add .

# Commit the merged changes
git commit -m "Merged changes from own repository"

# Push to your repository
git push -u origin main --force

# --force will overwrite the remote branch if there are merge conflicts, it shouldn't be a problem if your repo had nothing important.
```

---

## 5. Create a New Docker Hub Repository

### Steps:

- Log in to Docker Hub and create a new repository named `yourname-nodeapp` 

---
## 6. Create a Freestyle Project for Nodeapp in Jenkins

### Steps:

- Access the Jenkins web interface and set up and build the project.
- Your Jenkins server will be running on `http://your-vm-ip:5003` if you followed the above code
 
### Instructions:

1. Open your Jenkins instance in the browser by visiting `http://your-vm-ip:8081`
2. Get the Jenkins admin password by going it the Jenkins container's shell:

```bash
sudo docker exec -it jenkinscontainerid bash
cat /pathtopassword # The path will show on the Jenkins page you're on
```

3. Go to Manage Jenkins > Plugins > Available Plugins and install the **CloudBees Docker Build and Publish** plugin
4. Create a new Freestyle project by going to New Item, name it `newuser-nodeapp`.

### Jenkins Configuration

1. Under **Source Code Management**, select `Git` and provide your repository URL.
2. Specify your branch (change it to **main** or **master** depending on your repo)
4. Go down to Build Steps > Add build step > Docker build and Publish (if you don't see this option, it means the **Cloudbees Plugin** was not properly installed)
5. In **Docker Build and Publish**, enter the name of your dockerhub repo's name e.g. ` dockerhubusername/nodeapp-reponame`
6. Give it a tag, e.g. `latest`
7. Add Registry credentials using Add button > Jenkins
8. Enter your dockerhub credentials in **Username** and **Password**.
9. Select the added credentials in the Registry Credentials dropdown menu
10. Add another build step for **Execute Shell**. Add the following commands

```bash
# Pull the latest image from your Docker Hub repository 
docker pull your_dockerhub_username/your_app:latest 

# Stop and remove any running container with the same name (optional) 
docker stop nodeapp-yourname || true 
docker rm nodeapp-yourname || true 

# Run the Docker container from the image 
docker run -d -p 5000:5000 --name nodeapp-yourname -v nodeapp:/app your_dockerhub_username/your_app:latest

# Change 5000 to any available port. This is where your nodeapp will be running on your VM when Jenkins runs the build task.
```

5.  Save the configuration and build it using **Build Now**.
6. Click on the build under Build History and go Console Output to see if it was successful

Check if the node app is live on `your-vm-ip:5006`
## **7. Create a Subdomain for your App**

### Steps:
- Create a subdomain `newuser-nodeapp.yourdomain.com` by adding a record. 

### Instructions:
- Log in to your domain registrar's control panel.
- Go to the DNS settings for your domain.
- Add an A record pointing `newuser-nodeapp` to your VM's public IP.
- Set TTL to a low value like 60.

Check if your subdomain is live on DNS servers by visiting [whatsmydns.com](https://whatsmydns.com/) and entering your subdomain's complete URL, `newuser-nodeapp.yourdomain.com`

---

## **8. Create Nginx Configuration for Jenkins and Nodeapp**

### Steps:
- Set up reverse proxy configuration for Jenkins and your nodeapp in Nginx.

### Commands:

```bash
# Install nginx if you haven't already
sudo apt update
sudo apt install nginx

# Start and enable nginx
sudo systemctl start nginx
sudo systemctl enable nginx
```

```bash
# Remove the default congfig
sudo rm /etc/nginx/sites-available/default
sudo rm /etc/nginx/sites-enabled/default

# In the directory of available-sites, add a new site config for your nodeapp app and save the file
cd /etc/nginx/sites-available
nano newuser-nodeapp
```

### Nginx config file

```nginx
server {
    listen 80;
    server_name newuser-nodeapp.yourdomain.com;

    location / {
        proxy_pass http://localhost:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# Change localhost:5000 to whichever port your nodeapp is running on
```

The above file will redirect any requests on the default http port, i.e. 80, that have the URL address: `newuser-nodeapp.yourdomain.com` to `http://localhost:5000`, where your nodeapp is running.

```bash
# Check for errors in the configuration file
sudo nginx -t

# If it passes, restart nginx
sudo systemctl restart nginx
```

Your node app can now be reached by visiting your subdomain `newuser-nodeapp.yourdomain.com`

Repeat the same steps but for your Jenkins Server:

```bash
# Make a new subdomain record for the your Jenkins server

cd /etc/nginx/sites-available
nano newuser-jenkins

# Add the config info for your Jenkins server. Just hange the server name to a new subdomain for the jenkins e.g. `newuser-nodeapp.yourdomain.com` and the port in the proxy_pass parameter to the port your Jenkins in running on.

# Check for errors again and restart nginx
sudo nginx -t
sudo systemctl restart nginx
```

Your Jenkins app should now be live as well.

---
## Miscellaneous Help

### Setting up SSH authentication on Github

1. Go to your Github account [settings](https://github.com/settings/profile)
2. Go to **SSH and GPG keys** and add new SSH key.
3. Give it a name and paste the contents of your public key.

```bash
# This will print your public key to the console
cat ~/.ssh/id_rsa.pub
```

 4. Your SSH key has now been added. Github can now authenticate your user session by the corresponding private key in your `~/.ssh` directory called `id_rsa`

---

## References:

- https://www.digitalocean.com/community/tutorials/how-to-create-a-new-sudo-enabled-user-on-ubuntu
- https://github.com/Khhafeez47/nodeapp-iba
- 

