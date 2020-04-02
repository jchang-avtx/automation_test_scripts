# Aviatrix Automation Scripts for Terraform 0.12

Automation scripts for Aviatrix provider regression testing, updated for Terraform 0.12

- Due to Terraform 0.12 not being backwards-compatible, please see ```Terraform_Scripts``` for 0.11 and below
- **Note:** Terraform 0.12 is compatible with Aviatrix Controller 4.7+, Terraform R1.12+
- **Note:** Current scripts are updated for R2.0+

---
**STATUS:** Updated for UserConnect 5.4, Terraform R2.13

---

## Setup
### Prerequisites
1. **Aviatrix Controller(s)** - nodes that host parallel stage runs in Jenkins
2. **Jenkins server** - Ubuntu 18.x machine with Jenkins installed - where the regression pipeline will run
3. **Python3.7** - installed on Jenkins server
4. **Terraform** - have all items listed below installed under the *Jenkins* user in the **Jenkins server**
  * Terraform
  * Aviatrix Terraform provider (sourced locally)
  * Go
  * View setup instructions [HERE](https://github.com/terraform-providers/terraform-provider-aviatrix/blob/master/README.md)

### Credentials
1. In the Controller, the following access accounts must be created for AWS, ARM, GCP, and OCI with the following names respectively:
  * AWSAccess
  * AzureAccess
  * GCPAccess
  * OCIAccess
  * AWSGovRoot
2. The credentials used to create the above accounts must be stored to the Jenkins server credentials as secret-text:
  * Can be accessed by: **Jenkins -> Credentials -> System -> Global credentials (unrestricted) -> Add credentials**
    * **Note:** Name of the local Jenkins credentials does not matter, but must be referenced properly under the global ``environment { ... }`` block in the ***Jenkinsfile***
  * AWS requires ``AWS_ACCESS_KEY_ID`` and ``AWS_SECRET_ACCESS_KEY`` to be exported
  * ARM requires ``ARM_CLIENT_ID``, ``ARM_CLIENT_SECRET``, ``ARM_SUBSCRIPTION_ID``, ``ARM_TENANT_ID`` to be exported
3. Credentials for the Aviatrix Controllers that regression will be running on must be set as environment variables under the Jenkins Global Properties:
  * Can be accessed by: **Jenkins -> Manage Jenkins -> Configure System -> Global Properties -> Environment variables**
  * Set ``AVIATRIX_CONTROLLER_IP``, ``AVIATRIX_USERNAME``, ``AVIATRIX_PASSWORD`` with placeholder values
    * **Example:**
      ```
        Name    = AVIATRIX_CONTROLLER_IP
        Value   = 1.2.3.4
        Name    = AVIATRIX_USERNAME
        Value   = exampleuser
        Name    = AVIATRIX_PASSWORD
        Value   = examplepass
      ```
  * Set the controller (#) credentials as ``avx_ip_1``, ``avx_user_1``, ``avx_pass_1`` and increment as necessary
    * **Example:**
      ```
        Name    = avx_ip_1
        Value   = 174.168.34.16
        Name    = avx_user_1
        Value   = admin
        Name    = avx_pass_1
        Value   = realAdminPassword
      ```
  * Regression will take care of transitive switch of the values
4. Create environment variable for the email address to be used to receive email notifications for Regression task status upon completion:
  * Can be accessed by: **Jenkins -> Manage Jenkins -> Configure System -> Global Properties -> Environment variables**
  * Set ``email_recipient`` with desired email address
    * **Example:**
      ```
        Name    = email_recipient
        Value   = admin@example.com
      ```

### Infrastructure/ File Structure
1. You may change which test stage runs with which in parallel, by updating the ***Jenkinsfile*** and updating the respective test stage's ***.py***'s reference to which Controller credentials to use
2. For every test case, represented per directory, be sure to input the filepath for the ***terraform_fx.py*** in the respective test stage's ***.py*** file
  * by default, all Jenkins jobs will be located in ``/var/lib/jenkins/workspace/project-name/py_libs``
    ```
      # Example taken from run_aws_peer.py line 16

      sys.path.insert(1, '/var/lib/jenkins/workspace/Terraform-Regression/py_libs')
    ```
3. For ALL account-related test cases (denoted by "account_xxx")(this includes RBAC, introduced in R2.13), a ***.tfvars*** with the proper credentials for the respective account-type needs to be created and stored locally within the Jenkins server, within the respective directories
  * default path where the project is located: ``/var/lib/jenkins/workspace/project-name/``
  * **Example:** For test case "account_azure", an ***azure_acc_cred.tfvars*** is required, with the valid credential values.
    ```
      # azure_acc_cred.tfvars

      arm_sub_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
      arm_dir_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
      arm_app_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
      arm_app_key = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    ```
  * Please refer to their respective ***vars.tf*** for the variable names and the ***.py*** for what the ***.tfvars*** should be named. You may change these variables and filenames if you wish
  * **NOTE:** For test stages **account_gcp** and **account_oracle**, two (2) ***.json*** Gcloud project credentials and the (1) OCI API Private Key ***.pem*** are required to be stored in their directories, respectively.
4. **vpn_user_accelerator** test stage requires a pre-existing ELB
  * An Aviatrix VPN gateway with ELB-enabled can be created on the respective controller to satisfy this requirement
  * By default, the terraform file will look for an ELB name: ``elb-vpn-user-accel``, which can be changed as desired within the respective ***.tf*** file
5. **vpn_user** test stage requires a pre-existing SAML endpoint on whichever Controller this stage will run on
  * By default, the terraform file will look for a SAML endpoint name: ``saml_test_endpoint``, which can be changed as desired within the respective ***.tf*** file
  * Also requires a ***user_emails.tfvars*** with a list of 4 emails to be corresponded to the 4 VPN users being created
    ```
    # user_emails.tfvars

    vpn_user_email = ["testemail1@gmail.com",
                      "testemail2@gmail.com",
                      "testemail3@gmail.com",
                      "testemail4@gmail.com"]
    ```
