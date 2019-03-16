Usage
-----------
After creating a base gateway to manipulate (using terraform.tfvars), the following test files may be run in any order:
1. **invalidSingleAZHA.tfvars**
   * test invalid input for single_az_ha parameter (despite it being optional)

* **emptycreation.tfvars**
   * (This is used to test empty input)
   * should pass because optional
   * Additional test case: Refresh, Updating single_az_ha from 'disabled' to 'enabled'
