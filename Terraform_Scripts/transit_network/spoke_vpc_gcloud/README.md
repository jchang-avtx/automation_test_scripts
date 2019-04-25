Usage
-----------
After creating a base GCP Spoke GW (using terraform.tfvars), the test files should be run in this order:

1. **updateGWSize.tfvars**
  * will change the spoke GW's size from f1-micro to g1-small
2. **updateHAGWSize.tfvars**
  * will change the spoke HA GW's size from f1-micro to g1-small

Running the scripts in this order will allow testing of manipulation of individual parameters.
You can switch around orders to do combinations of different updates.
