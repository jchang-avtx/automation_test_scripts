## Manage Aviatrix spoke_vpc (Gcloud)

resource "aviatrix_spoke_vpc" "gcloud_spoke_gw" {
  cloud_type = 4
  account_name = "GCPAccess"
  gw_name = "gcloudspokegw"
  vpc_id = "default"
  vpc_reg = "us-west2-a" # is "Zone" in GUI
  vpc_size = "${var.gcp_instance_size}" # f1-micro ## g1-small
  subnet = "10.168.0.0/20" # 10.168.0.0/20 (us-west2) ## 10.138.0.0/20 (us-west1)
  ha_subnet = "us-west2-b" # 10.168.0.0/20
  ha_gw_size = "${var.gcp_ha_gw_size}"
  enable_nat = "${var.toggle_snat}" # cannot have SNAT enabled if you have HA-enabled
  # single_az_ha = "enabled" # used if not have HA-gw; not supported for Gcloud
  # transit_gw = "gcloudTransitGW" # there is no GCP transit_vpc
  # tag_list = ["k1:v1"] # only supported in AWS
}
