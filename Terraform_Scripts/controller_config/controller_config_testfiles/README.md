Usage
-----------
After creating a base controller_config resource with global controller attributes to manipulate (using terraform.tfvars), the test files should be run in this order:
1. **enableHTTP.tfvars**
  * enable http_access
2. **disableFQDN.tfvars**
  * disable FQDN exception rule (default = enabled)
3. **changeAccount.tfvars**
  * irrelevant test case since all accounts are under the same controller
4. **disableSG.tfvars**
  * disables Security Group Management feature (initial creation is enabled)


Running the scripts in this order will allow testing of manipulation of individual parameters.
You can switch around orders to do combinations of different updates.
