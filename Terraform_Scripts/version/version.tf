## initial creation

resource "aviatrix_version" "test_version" {
  target_version = "4.1" # (OPTIONAL). if unspecified, default = upgrade to latest release
  # version = "4.1" # (COMPUTED) current version of the controller
}
