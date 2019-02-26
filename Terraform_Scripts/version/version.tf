## initial creation

## can specify release version number to upgrade to. "latest" will upgrade to latest release
resource "aviatrix_version" "test_version" {
  target_version = "latest" # (OPTIONAL). if unspecified, controller will not be upgraded;
}
