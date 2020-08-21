aws_cloud_region       = "us-west-2"

## Comment/Uncomment the following site regions that you want to test
aws_site_region        = [
  "us-east-1",
#  "us-east-2",
#  "us-west-1",
#  "us-west-2",
#  "af-south-1",
#  "ap-east-1",
#  "ap-south-1",
#  "ap-northeast-2",
  "ap-southeast-1",
#  "ap-southeast-2",
#  "ap-northeast-1",
  "ca-central-1",
#  "eu-central-1",
#  "eu-west-1",
#  "eu-west-2",
#  "eu-south-1",
#  "eu-west-3",
#  "eu-north-1",
#  "me-south-1",
#  "sa-east-1",
]
pre_shared_key         = "0123456789"
phase_1_authentication = "SHA-1"
phase_2_authentication = "HMAC-SHA-1"
phase_1_dh_groups      = "2"
phase_2_dh_groups      = "2"
phase_1_encryption     = "AES-128-CBC"
phase_2_encryption     = "AES-128-CBC"
