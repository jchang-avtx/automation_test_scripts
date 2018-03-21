#!/bin/bash

# Setting up download path for terraform
cd $HOME/Aviatrix_Terraform

mkdir $HOME/terraform
cd $HOME/terraform
# Download terraform release version
wget https://releases.hashicorp.com/terraform/0.11.4/terraform_0.11.4_linux_amd64.zip
sudo apt-get install -y zip unzip
unzip terraform_0.11.4_linux_amd64.zip

sudo mv terraform /usr/local/bin/
terraform -version

# Setting up download path for GO
cd $HOME/terraform

# Download go lang version and extract
wget https://storage.googleapis.com/golang/go1.9.2.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.9.2.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
go version

# Setting up GOPATH
echo "export GOPATH=$HOME/work" > ~/.bash_profile
source ~/.bash_profile
export GOBIN=$HOME/work/bin
echo "export GOPATH=$HOME/work" > ~/.zshrc
source ~/.zshrc

# Building the Aviatrix Plugin
mkdir -p $GOPATH/src/github.com/terraform-providers
cd $GOPATH/src/github.com/terraform-providers
sudo apt install git 

# git clone the latest Aviatrix provider APIs
git clone https://github.com/AviatrixSystems/terraform-provider-aviatrix.git

cd $GOPATH/src/github.com/terraform-providers/terraform-provider-aviatrix
sudo apt install make
make fmt
make build
echo 'providers {
  "aviatrix" = "$GOPATH/bin/terraform-provider-aviatrix"
  }' >> ~/.terraformrc

# terraform configuration directory
mkdir $HOME/test-Aviatrix
cd $HOME/test-Aviatrix
terraform init
echo
echo "--------------------------------------------------------------------------------------"
echo "Congratulations! You can now start building terraform configuration files for Aviatrix"
echo "--------------------------------------------------------------------------------------"
echo
bash
echo
