Usage
-----------
After creating a base gateway to manipulate (using terraform.tfvars), the test files should be run in the following order:
1. **disableNAT.tfvars**
  * will disable SNAT
2. **updateTagList.tfvars**
  * will update tag_list from blank to something
3. **updateGWSize.tfvars**
  * will change GW size from t2.micro to t2.small
4. **updateHAGWSize.tfvars**
  * will change HA-GW size from t2.micro to t2.small

* Additional test case:
  * attempt apply without specifying peering_ha_gw_size; gw should not be created, error returned

Note: must wait 2 mins in between updating these parameters because gateway goes down shortly
