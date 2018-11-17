# use module to launch a controller

provider "aws" {
  region     = "${var.region}"
}

module "launch_controller" {
  source = "aviatrix_controller"
  create_aviatrix_iam_roles = "${var.create_aviatrix_iam_roles}"
  aws_account_number = "${var.aws_account_number}"
  controller_admin_password = "${var.controller_admin_password}"
  controller_vpc_cidr_prefix = "${var.controller_vpc_cidr_prefix}"
  controller_size = "${var.controller_size}"
  controller_key = "${var.controller_key}"
  controller_name_suffix = "${var.controller_name_suffix}"
  controller_admin_email = "${var.controller_admin_email}"
  controller_ami_type = "${var.controller_ami_type}"
}

# Configure Aviatrix provider access
provider "aviatrix" {
  controller_ip = "${module.launch_controller.controller_public_ip}"
  username = "admin"
  password = "${var.controller_admin_password}"
}

resource "aviatrix_customer_id" "setup_customer_id" {
  count = "${var.setup_customer_id}"
  customer_id = "${var.aviatrix_customer_id}"
}

resource "aviatrix_account" "setup_aws_account" {
  account_name = "${var.account_name}"
  cloud_type = 1
  aws_account_number = "${var.aws_account_number}"
  aws_iam = "true"
}

output "controller_public_ip" {
  value = "${module.launch_controller.controller_public_ip}"
}

