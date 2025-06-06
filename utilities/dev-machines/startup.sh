#!/bin/sh

# This scrip installs:
#   - latest ubuntu updates
#   - wget
#   - Chrome remote Desktop
#   - GUI for Ubuntu (Xfce)
#   - Google Chrome
#   - Firefox
#   - Google Cloud SDK
#   - aws cli
#   - Python3
#   - Visual Studio Code
#   - Golang
#   - Postman
#   - jq
#   - npm
#   - NodeJS
#   - yarn
#   - Vue CLI
#	- Terraform and terraform tools
#   - Flutter
#   - A MySQL client for the CLI
#   - The MySQL Workbench interface
#   - Docker

# Get the latest package list
sudo apt update

# Do the updates
sudo apt-get update

# install wget
sudo apt install -y software-properties-common apt-transport-https wget

# Python3

## Install Python for Ubuntu
sudo apt install -y python3-pip

## Also install following packages for python development
sudo apt install -y python3-dev default-libmysqlclient-dev build-essential pkg-config 

## Install virtualenv
sudo apt-get install -y python3-venv

# END Install Python3

# Install jq
sudo snap install jq

# Download the Debian Linux Chrome Remote Desktop installation package:
wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb

# Install the package and its dependencies:
sudo dpkg --install chrome-remote-desktop_current_amd64.deb
sudo apt install -y --fix-broken

# Cleanup remove the unnecessary file after the installation is done:
rm chrome-remote-desktop_current_amd64.deb

# install xcfe
sudo DEBIAN_FRONTEND=noninteractive \
    apt install -y xfce4 xfce4-goodies desktop-base

# Configure Chrome Remote Desktop to use Xfce by default:
sudo bash -c 'echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" > /etc/chrome-remote-desktop-session'

# Xfce's default screen locker is Light Locker, which doesn't work with Chrome Remote Desktop. 
# install XScreenSaver as an alternative:
sudo apt install -y xscreensaver

# Install Firefox browser
sudo apt -y install firefox

# Install Chrome browser
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg --install google-chrome-stable_current_amd64.deb
sudo apt install -y --fix-broken

# Cleanup remove the unnecessary file after the installation is done:
rm google-chrome-stable_current_amd64.deb

# Disable the display manager service:
# There is no display connected to the VM --> the display manager service won't start.
sudo systemctl disable lightdm.service

# Install the Google Cloud SDK
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

sudo apt-get install apt-transport-https ca-certificates gnupg

curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

sudo apt-get update 
sudo apt-get install -y google-cloud-sdk

# END Install the Google Cloud SDK

# Install AWS CLI
# This is needed to interact with AWS resources

# Download the installation file 
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# Unzip the installer
unzip awscliv2.zip

# Run the install program
sudo ./aws/install

# Cleanup: remove the zip file for the aws installer
rm awscliv2.zip

# END Install AWS CLI

# Install Visual Studio Code
sudo snap install --classic code

# Install The AWS Toolkit extension for VS Code 
code --install-extension amazonwebservices.aws-toolkit-vscode

# END Install Visual Studio Code

# install Golang

# Download the code
# This will install Go v1.19.5
wget https://golang.org/dl/go1.19.5.linux-amd64.tar.gz

# Install Golang in the folder /usr/local
sudo tar -C /usr/local -xvf go1.19.5.linux-amd64.tar.gz

# Cleanup remove the installation file
rm go1.19.5.linux-amd64.tar.gz

# create a copy of the orginal /etc/profile file
sudo cp /etc/profile /etc/profile.vanila

# Configure the Go PATH (for all users)
echo '' | sudo tee -a /etc/profile > /dev/null
echo "# Configure the GOPATH for Golang " | sudo tee -a /etc/profile > /dev/null
echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee -a /etc/profile > /dev/null

# END install Golang

# Install Postman so we can test API if needed
sudo snap install postman

# Install Node 20. 
# [See the official Node documentation](https://github.com/nodesource/distributions#ubuntu-versions).

## Download and import the Nodesource GPG key
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

## Create deb repository on the machine

NODE_MAJOR=20
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list

## Run Update and Install
sudo apt-get update
sudo apt-get install nodejs -y

# END Install Node 20

# Get the lateste version of npm
sudo npm install --global npm@latest

# Get the latest version of yarn
sudo npm install --global yarn

# Install nvm v 0.39.1 to manage node versions
sudo wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

## Make sure nvm can be used (similar to restart the terminal)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Install the VUE CLI
sudo npm install -g @vue/cli

# Install the Firebase Tools
sudo npm install -g firebase-tools

# Install Terraform.
# This is taken from the Terraform official documentation: https://learn.hashicorp.com/tutorials/terraform/install-cli

# Add the HashiCorp GPG key.
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -

# Add the official HashiCorp Linux repository.
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

# Update and install.
sudo apt-get update && sudo apt-get install terraform

# END install Terraform

# Install Flutter
sudo snap install flutter --classic

# Install a command line MySQL client:
sudo apt-get install -y mysql-client

# Install MySQL Workbench
sudo apt-get install -y mysql-workbench

# Install Docker
sudo apt install -y docker.io

# Install DBeaver: a Multi SQL client
sudo snap install dbeaver-ce
