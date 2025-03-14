#!/bin/bash

sudo apt update
sudo apt upgrade

echo "Installing Uncomplicated Firewall (ufw)..."

sudo apt install ufw

sudo apt install -y ca-certificates curl gnupg

# Install and configure Oh My ZSH

echo "Installing zsh..."

sudo apt-get update && sudo apt-get upgrade

sudo apt-get install zsh

echo "Changing shell to zsh..."

sudo chsh -s $(which zsh) $USER

echo "Installing oh-my-zsh..."

sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "Installing zsh-syntax-highlighting..."

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions

# export PATH=$HOME/bin:/usr/local/bin:$PATH

# plugins=(git zsh-completions zsh-autosuggestions zsh-syntax-highlighting)
# autoload -U compinit && compinit

sudo apt-get install fonts-powerline


# ZSH_THEME="agnoster"

. ~/.zshrc


# Install SMB Server

sudo apt install samba samba-common-bin

# Configure Samba

echo "Setting up SMB Share..."
# timeout(1)
read -p "Enter the name of the SMB share (default: smbshare): " smbShareName
smbShareName="${smbShareName:-smbshare}"

sudo mkdir -p /mnt/ssd
sudo mount /dev/sda1 /mnt/ssd
ssdMnt=$(findmnt -rn -S /dev/sda1 -o TARGET)

echo "
[${smbShareName}]
path = ${ssdMnt}/tera
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


# NodeJS Install

echo "Installing Node, npm, yarn..."

curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/nodesource.gpg
NODE_MAJOR=22
echo "deb [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt update
sudo apt install -y nodejs 
sudo apt install build-essential



# Code Server Install

curl -fsSL https://code-server.dev/install.sh | sh
sudo systemctl enable --now code-server@$USER