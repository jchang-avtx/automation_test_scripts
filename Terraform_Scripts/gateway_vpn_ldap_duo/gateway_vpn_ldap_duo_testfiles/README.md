Usage
-----------
After creating a base case to manipulate (using terraform.tfvars), the test files should be run in the following order:
1. **updateduo.tfvars**
   * update and changes Duo-related parameter values
   * Please see Mantis id =
2. **updateldap.tfvars**
   * update and changes LDAP-related parameter values
   * Please see Mantis id =

* **modechange.tfvars**
   * (This is used to test changing OTP mode or enable/disabling LDAP)
   * Similar to invalid inputs testing for the mode
   * Please see Mantis id =
* **emptycreation.tfvars**
   * (This is used to test invalid/ empty inputs; see Mantis: id = )
