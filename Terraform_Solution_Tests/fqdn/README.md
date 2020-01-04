## FQDN Test

### Description

This Terraform configuration creates AWS VPC testbed environment with ubuntu instances, sets up Aviatrix gateway, configures FQDN filters, and then tests end-to-end traffic to make sure FQDN filters are working. After test is done, copy the result output from the remote host to the local machine.

### Prerequisites

1) Create a public_key private_key pair. For example. "ssh-keygen -t rsa" and save the key pair such as ~/Downloads/sshkey and ~/Downloads/sshkey.pub

2) Provide the location of the public_key as variable in provider_cred.tfvars file.

3) Provide the location of the private_key as local variable in fqdn.tf file. Also, add the private_key on the local machine where terraform is going to run. For example, ssh-add ~/Downloads/sshkey

4) Provide other info such as controller_ip, aws_access_key, etc as necessary in provider_cred.tfvars file.

### Usage
```
terraform init
terraform plan -var-file=provider_cred.tfvars -detailed-exitcode
terraform apply -var-file=provider_cred.tfvars -auto-approve
terraform show
terraform destroy -var-file=provider_cred.tfvars -auto-approve
```

### Test Duration

Total Test Time = \~16 min (Create=\~4min Destroy=\~12min)

### Test Result

Check **result.txt** file in the same terraform script location. It should say **"PASS"** or **"FAIL"**.

### Troubleshoot

If test result is "FAIL" or user needs to check more info, check **log.txt** file in the same terraform script location after the run.
