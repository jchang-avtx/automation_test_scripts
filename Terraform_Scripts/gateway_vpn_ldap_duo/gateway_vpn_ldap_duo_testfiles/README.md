Usage
-----------
After creating a base case to manipulate (using terraform.tfvars), the test files can be run in any order:
1. **updateduo.tfvars**
   * update and changes Duo-related parameter values
   * Please see Mantis id = 8142
2. **updateldap.tfvars**
   * update and changes LDAP-related parameter values
   * Please see Mantis id = 8142

* **modechange.tfvars**
   * (This is used to test changing OTP mode or enable/disabling LDAP)
   * Similar to invalid inputs testing for the mode
   * Please see Mantis id = 8142
* **emptycreation.tfvars**
   * (This is used to test invalid/ empty inputs; see Mantis: id = 8142)
