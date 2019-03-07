Description
---
  Terraform configuration files to build encrypted peering and transitive peering

---
### Test cases
* **emptycreation.tfvars**
  * Tests empty/invalid creation/ update
  * Should fail
* **updateCIDR.tfvars**
  * Tests updating CIDR Destination
  * Should fail
* **updateSourceNext.tfvars**
  * Tests updating Source / Next Hop GW
  * Should fail
