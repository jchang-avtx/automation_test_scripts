# Usage
---

After creating a base admin email managed by Terraform (using terraform.tfvars), the test files can be run in any order to manipulate update, empty/invalid test cases:

* **emptycreation.tfvars**
  * (This is used to test empty email input for create/ update)
  * see id = 8453
* **invalidemail.tfvars**
  * (This is used to test invalid email input for create/ update)
* **updateemail.tfvars**
  * (This is used to test valid email update)
