#!/bin/bash

# Update the package list to ensure we get the latest versions available
sudo apt update

# Install OpenJDK 11, a Java Development Kit, which is required by Jenkins
sudo apt install openjdk-11-jdk -y

# Install Maven (a build automation tool), wget (a utility for downloading files), and unzip (a utility for extracting compressed files)
sudo apt install maven wget unzip -y

# Download the Jenkins key for package verification and add it to the system's keyring
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

# Add the Jenkins package repository to the system's sources list
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update the package list again to include the Jenkins repository
sudo apt-get update

# Install Jenkins
sudo apt-get install jenkins -y
