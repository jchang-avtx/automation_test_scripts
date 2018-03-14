provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.region1}"
}

# Additional provider configuration for west coast region
provider "aws" {
  alias  = "west"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.region2}"
}
# Additional provider configuration for west coast region
provider "aws" {
  alias  = "east2"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.region3}"
}



# Edit to enter your controller's IP, username and password to login with.
provider "aviatrix" {
  controller_ip = "${var.controller_ip}"
  username = "${var.controller_username}"
  password = "${var.controller_password}"
}

