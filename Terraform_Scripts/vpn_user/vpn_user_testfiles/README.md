Usage
-----------
After creating a base case to manipulate (using terraform.tfvars), the test files can be run in any order:
1. **changeemails.tfvars**
   * will change the emails attached to the users
   * (Warning: Error - changing emails is not supported by provider nor Controller)
2. **changegw.tfvars**
   * will change the gw the users are attached to
   * (Warning: Error - changing gw is not supported by provider, but can be done manually on Controller)
3. **changeuser.tfvars**
   * will change the usernames of the existing users
   * (Warning: Error - See Mantis: id = 7967)

* **emptycreation.tfvars**
   * (This is used to test invalid/ empty inputs; there are bugs; see Mantis: id=7985)
