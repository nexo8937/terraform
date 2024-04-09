#!/bin/bash

sudo apt update
sudo apt install apt-transport-https
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
yes | sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y docker-ce  

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip
unzip awscliv2.zip
sudo ./aws/install


sudo docker login -u AWS -p $(aws ecr get-login-password --region us-east-1) 835619216981.dkr.ecr.us-east-1.amazonaws.com
sudo docker pull 835619216981.dkr.ecr.us-east-1.amazonaws.com/brainscale-simple-app:v1
sudo docker run -d -p 3000:3000 835619216981.dkr.ecr.us-east-1.amazonaws.com/brainscale-simple-app:v1
