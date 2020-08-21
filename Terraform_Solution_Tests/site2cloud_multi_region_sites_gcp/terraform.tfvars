gcp_cloud_region       = "us-west1"

## Comment/Uncomment the following site regions that you want to test
gcp_site_region        = [
# "asia-east1",
# "asia-east2",
# "asia-northeast1",
# "asia-northeast2",
# "asia-northeast3",
# "asia-south1",  ### THIS GCP REGION MIGHT FACE RESOURCE AVAILABILITY PROBLEM
# "asia-southeast1",
# "asia-southeast2",
# "australia-southeast1",
# "europe-north1",
# "europe-west1",
# "europe-west2",
# "europe-west3",
# "europe-west4",
# "europe-west6",
# "northamerica-northeast1",
# "southamerica-east1",
# "us-central1",
 "us-east1",
# "us-east4",
# "us-west1",
# "us-west2",
# "us-west3",
# "us-west4",
]
pre_shared_key         = "0123456789"
phase_1_authentication = "SHA-1"
phase_2_authentication = "HMAC-SHA-1"
phase_1_dh_groups      = "2"
phase_2_dh_groups      = "2"
phase_1_encryption     = "AES-128-CBC"
phase_2_encryption     = "AES-128-CBC"
