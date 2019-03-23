Usage
-----------
The test files may be run in any order before a valid creation
1. **emptyGW.tfvars**
   * will attempt to create a peering tunnel without specifying 2 GWs
   * Note: this is a required parameter and should fail
2. **invalidCluster.tfvars**
   * creation with empty/ invalid input for cluster should pass and default to 'no'
   * Note: update function is not supported by Controller (should fail)
   * Must delete this tunnel before testing the other  (creation) test cases

    ```$ terraform destroy -target=aviatrix_tunnel.peeringTunnel```

3. **invalidHA.tfvars**
   * creation with empty/ invalid input for enable_ha should pass
   * Note: update function is not supported by Controller (should fail)
   * Must delete this tunnel before testing the other test cases

    ```$ terraform destroy -target=aviatrix_tunnel.peeringTunnel```
