# Splunk OpenVPN Regression Lab Setup

## Description
This Terraform configuration creates 2 AWS VPCs, each with 1 Ubuntu instances in a public subnet and 1 in a private subnet, and sets up an Aviatrix VPN gateway within one of the VPCs. One of the VMs in the VPC use a Linux-based OpenVPN Client and make a VPN connection to the Aviatrix VPN gateway. Continuous pings will be sent from the client to a private VM in that VPN gateway's VPC. Verify no ping packet is lost during a controller upgrade.

## Prerequisites
1. Create a public, private_key pair, and save the key pair such as in ~/Downloads/sshkey and ~/Downloads/sshkey.pub
```
  $ ssh-keygen -t rsa
```
2. Must have access to an Aviatrix Controller, with an AWS access account
    - Be sure to enable HTTPS access on port 443 from all sources temporarily or add HTTPS rule manually to allow connection from the public Ubuntu VM [1] IP
3. Must have Terraform installed
```
  $ brew install terraform
```

## Usage
1. Use the **terraform.tfvars.example** as a template, and provide necessary information such as the `aws_access_key`, `aws_region`. Be sure to save the file as a **.tfvars** extension. E.g. **terraform.tfvars**

2. Use the **credentials.tf.json.example** as a template, and provide the necessary credentials for the Controller login. Be sure to save the file as a **.tf.json** extension. E.g. **credentials.tf.json**

3. Perform the following commands to initialise the Terraform workspace and run the Terraform scripts
```
  $ terraform init
  $ terraform plan
  $ terraform apply -auto-approve
  $ terraform show
  $ terraform destroy -auto-approve
```
