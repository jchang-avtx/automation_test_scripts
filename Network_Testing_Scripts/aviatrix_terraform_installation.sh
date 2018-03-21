#!/bin/bash
#setting up path for terraform
cd $HOME

if [ ! -d $HOME/Aviatrix_Terraform ] ; then
       mkdir $HOME/Aviatrix_Terraform
fi
cd $HOME/Aviatrix_Terraform

if [ ! -d $HOME/terraform ] ; then
       mkdir $HOME/terraform
fi
cd $HOME/terraform


wget https://releases.hashicorp.com/terraform/0.11.4/terraform_0.11.4_linux_amd64.zip
sudo apt-get install -y zip unzip
unzip terraform_0.11.4_linux_amd64.zip


sudo mv terraform /usr/local/bin/
terraform -version
#setting up path for GO

cd $HOME/terraform



wget https://storage.googleapis.com/golang/go1.9.2.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.9.2.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
go version

#setting up GOPATH
echo "export GOPATH=$HOME/work" > ~/.bash_profile
source ~/.bash_profile
export GOBIN=$HOME/work/bin
echo "export GOPATH=$HOME/work" > ~/.zshrc
source ~/.zshrc

#Building the Aviatrix Plugin
mkdir -p $GOPATH/src/github.com/terraform-providers
cd $GOPATH/src/github.com/terraform-providers
sudo apt install git 

git clone https://github.com/AviatrixSystems/terraform-provider-aviatrix.git

cd $GOPATH/src/github.com/terraform-providers/terraform-provider-aviatrix
sudo apt install make
make fmt
make build
echo 'providers {
  "aviatrix" = "$GOPATH/bin/terraform-provider-aviatrix"
  }' >> ~/.terraformrc

# terraform configuration directory
if [ ! -d $HOME/test-Aviatrix ] ; then
       mkdir $HOME/test-Aviatrix
fi
cd $HOME/test-Aviatrix
terraform init
echo
echo "--------------------------------------------------------------------------------------"
echo "Congratulations! You can now start building terraform configuration files for Aviatrix"
echo "--------------------------------------------------------------------------------------"
echo
bash
