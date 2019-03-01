# Set Aviatrix Admin Email Address

resource "aviatrix_admin_email" "test_admin_email" {
  admin_email = "${var.avx_admin_email}"
}
