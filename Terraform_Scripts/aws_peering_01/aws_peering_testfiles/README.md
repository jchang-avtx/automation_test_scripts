# Usage
-----------
* **emptycreation.tfvars**
  * This is used to test create/ update with empty inputs
  * Mantis issues stated inside, if any
  * You must manually manipulate the values (comment/uncomment) to test either invalid/ empty inputs for various parameters
* **invalidRT.tfvars**
  * This is used to test create/ update on the route tables
* **updatepeer.tfvars**
  * This is used to test update with valid input
  * Will fail because peer resource does not support updating; must destroy and create new one

Please see file for more specific instructions on variable manipulation
