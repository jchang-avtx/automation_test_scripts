# Manage Aviatrix Transit Network Gateways

# Create a transit VPC - insane mode enabled
# Omit ha_subnet to launch transit VPC without HA.
# HA subnet can later be added or deleted to enable/disable HA in transit VPC

## Additional test case:
# 1. attempt apply without specifying ha_gw_size; gw should not be created, error returned

resource "aviatrix_transit_vpc" "test_transit_gw" {
  cloud_type        = 1
  account_name      = "PrimaryAccessAccount"
  gw_name           = "transitGWInsane"
  # enable_nat        = "${var.aviatrix_enable_nat}"
  vpc_id            = "vpc-abc123"
  vpc_reg           = "us-east-1"
  vpc_size          = "c5.large" ## insane mode gateways must be at c5 series
  subnet            = "10.0.1.64/26~~us-east-1a"
  # ha_subnet = "10.0.1.128/26~~us-east-1a" # (optional) HA subnet. Setting to empty/unset will disable HA. Setting to valid subnet will create an HA gateway in the subnet
  # ha_gw_size = "c5.large" # (optional) HA gw size. Mandatory if HA is enabled (ex. "c5.large")

  # tag_list = ["k1:v1"] # optional
  enable_hybrid_connection = "true" # (optional) enable to prep for TGW attachment; allows you to skip Step5 in TGW orchestrator
  connected_transit = "yes" # (optional) specify connected transit status (yes or no)

  insane_mode = "true" #  If enabled, will look for spare /26 segment to create a new subnet; must be formatted AWS: "10.0.0.0/26~~us-east1c
}
