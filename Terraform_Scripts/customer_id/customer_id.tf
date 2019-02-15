# Set Aviatrix Customer ID and License

resource "aviatrix_customer_id" "test_customer_id" {
  customer_id = "${var.aviatrix_customer_id}"
}
