# DevOps-Fall-24

I'll guide you through the steps to complete each task, provide the necessary commands, and outline the configurations you'll need. Let's break it down:

---

### **1. Create a New User with SSH Key for Passwordless Access**

#### Steps:
- Create a new user.
- Add the SSH key to the new user for passwordless login.


#### Commands:

```bash
# Create a new user (replace 'yahya' with your name)
sudo adduser yahya

# Add the user to the sudo group
sudo usermod -aG sudo yahya

# Switch to the new user
sudo su - yahya

# Create .ssh directory and set proper permissions
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Copy your existing SSH public key (if it's in ~/.ssh/id_rsa.pub) to the new user
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Verify SSH access from your local machine
ssh yahya@your-vm-ip

# (Optional) Verify sudo access
sudo whoami
``` 

This snippet adds a new user, grants them sudo privileges, and sets up SSH access.

#### Local Machine
```bash

# copy the id_rsa key to your clipboard, and make a new file in ~/.ssh
cd ~/.ssh
nano keyname # paste the contents of the priavte key here

# change the permissions of the file 
chmod 600 ~/.ssh/keyname

# check the permissions, it should look like "-rw-------  1 yahyaahmedkhan  staff  2602 Oct  8 00:42 /Users/yahyaahmedkhan/.ssh/yahya2key"
ls -l ~/.ssh/yahya2key

# ssh into the user@ip using your key
ssh -i ~/.ssh/keyname yahya2@172.17.5.43

```

---

### **2. Create a Dockerfile and Build a Docker Image for Jenkins**

#### Steps:
- Make a new folder `jenkins` in your user's home directory
- Write a `Dockerfile` to install Jenkins.
- Build the Docker image.

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

#### Commands:

```bash
# Run the docker image from your Dockerfile

docker run -d --name yahya-jenkins -p 80:8080 -p 50000:50000 -v yahya-jenkins:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock yahya-jenkins

```

---
### 4. Create a Freestyle Project for Nodeapp in Jenkins

#### Steps:
- Access the Jenkins web interface and set up the project.
- You can make the GitHub repo and push the node app's code to it before or during the Jenkins setup. See [Create a New Git Repository](#5-create-a-new-git-repository-and-push).


#### Instructions:
1. Open your Jenkins instance in the browser (`http://your-vm-ip:8081`).
2. Get the admin password by going it the container's shell:
```bash
sudo docker exec -it containerid bash
cat /pathtopassword
```
3. Go to Manage Jenkins > Plugins > Available Plugins and install the **CloudBees Docker Build and Publish** plugin
4. Create a new Freestyle project by going to New Item, name it `yahya2-nodeapp`.

	1. Under **Source Code Management**, select `Git` and provide your repository URL.
	2. Specify your branch (change it to **main** or **master** depending on your repo)
	3. Go down to Build Steps > Add build step > Docker build and Publish (if you don't see this option, it means the **Cloudbees Plugin** was not properly installed)

---
### 5. Create a New Git Repository and Push Code

#### Steps:
- Create a new Git repository locally and push the code.

#### Commands:
```bash
# Navigate to your Node.js application directory
cd ~/nodeapp

# Initialize a Git repository
git init

# Add all files to the repository
git add .

# Commit your changes
git commit -m "Initial commit for yahya-nodeapp"

# Add a remote (replace with your Git repository URL)
git remote add origin https://github.com/your-username/yahya-reponame.git

# Push the code to the remote repository
git push -u origin master
```

---

### **6. Create a New Docker Hub Repository**

#### Steps:
- Log in to Docker Hub and create a new repository named `yahya-reponame`.

#### Commands:
```bash
 -------------------------------------------------------------------------------
docker build -t yahya2-jenkins .

docker run -d --name yahya2-jenkins -p 8045:8080 -p 50000:50000 -v yahya2-jenkins:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock yahya2-jenkins


----------------------------------------------------------------------------------

# Pull the latest image from your Docker Hub repository 

docker pull your_dockerhub_username/your_app:latest 

  

# Stop and remove any running container with the same name (optional) 

docker stop your_app_container || true 

docker rm your_app_container || true 

  

# Run the Docker container from the image 

 

docker run -d -p 5000:5000 --name containername -v nodeapp:/app your_dockerhub_username/your_app:latest 
```

---

### **7. Create a Subdomain for your App**

#### Steps:
- Create a subdomain `yahya-nodeapp.yahyaabdullahsaadsubata.online`.

#### Instructions:
- Log in to your domain registrar's control panel.
- Go to the DNS settings for your domain.
- Add an A or CNAME record pointing `yahya-nodeapp` to your VM's public IP.

---

### **8. Create Nginx Configuration for Jenkins and Nodeapp**

#### Steps:
- Set up reverse proxy configuration for Jenkins and Nodeapp in Nginx.

#### Commands:
```bash
cd /etc/nginx/sites-available

nano yahya2-jenkins

```

```
server {
    listen 80;
    server_name yahya-jenkins.yahyaabdullahsaadsubata.online;

    location / {
        proxy_pass http://localhost:8082;  # Change to your backend server address
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

---

https://www.digitalocean.com/community/tutorials/how-to-create-a-new-sudo-enabled-user-on-ubuntu

https://github.com/Khhafeez47/nodeapp-iba


