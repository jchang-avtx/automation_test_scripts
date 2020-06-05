provider "aviatrix"  {
  controller_ip = var.avx_ctrlr_ip
  username      = var.avx_ctrlr_usr
  password      = var.avx_ctrlr_pass
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
