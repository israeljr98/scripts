#!/bin/bash

sudo apt update
sudo apt upgrade



# Install SMB Server

sudo apt install samba samba-common-bin

# Configure Samba

echo "Setting up SMB Share..."
# timeout(1)
read -p "Enter the name of the SMB share (default: smbshare): " smbShareName
smbShareName="${smbShareName:-smbshare}"
ssdMnt=$(findmnt -rn -S /dev/sda1 -o TARGET)

echo "
[${smbShareName}]
path = ${ssdMnt}
writeable = yes
browseable = yes
public = no
" | sudo tee -a /etc/samba/smb.conf

# Create the SMB share directory

# sudo mkdir /dev/sda1/${smbShareName}

echo "Samba share '${smbShareName}' configured."

sudo smbpasswd -a $USER

echo 'New SMB user added: ${USER}'

# Restarting Samba

sudo systemctl restart smbd


# Docker Install

echo "Installing Docker..."

curl -sSL https://get.docker.com | sh

echo "Creating user group 'docker'..."

sudo groupadd docker

echo "Adding user $USER to 'docker' group..."

sudo usermod -aG docker $USER

echo "Docker installed and configured. Will possibly need a restart."

docker run hello-world

# Portainer Install

docker pull portainer/portainer-ce:latest

docker volume create portainer_data

docker run -d -p 8000:8000 -p 9443:9443 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest

echo "Portainer installed. Access here: https://$(hostname).local:9443"



# Code Server Install

curl -fsSL https://code-server.dev/install.sh | sh
sudo systemctl enable --now code-server@$USER