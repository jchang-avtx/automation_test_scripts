### The following is to create a controller ec2
# AWS Security Group
module "create_aviatrix_roles" {
  source = "../aviatrix_iam_role"
  create_iam_role = "${var.create_aviatrix_iam_roles}"
  aws_account_number = "${var.aws_account_number}"
}

module "create_controller_vpc" {
  source = "../create_vpc"
  vpc_count = 1
  name_suffix = "TerraformControllerVPC"
  vpc_cidr_prefix = "${var.controller_vpc_cidr_prefix}"
}

resource "aws_security_group" "aviatrix_controller_sg" {
  name = "aviatrix_controller_sg"
  vpc_id = "${element(module.create_controller_vpc.vpc_id, 0)}"
  description = "Security group for controller"
  tags {
      Name = "SG-AviatrixController-${var.controller_name_suffix}"
  }
}

resource "aws_security_group_rule" "allow_https_inbound" {
  type  = "ingress"
  security_group_id = "${aws_security_group.aviatrix_controller_sg.id}"
  from_port       = 443
  to_port         = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  security_group_id = "${aws_security_group.aviatrix_controller_sg.id}"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

data "aws_region" "current" {}

# AWS ubuntu ec2 instance
resource "aws_instance" "aviatrix_controller_ec2" {
  ami = "${lookup(var.controller_amis[var.controller_ami_type], data.aws_region.current.name)}"
  instance_type = "${var.controller_size}"
  subnet_id = "${element(module.create_controller_vpc.subnet_id, 0)}"
  associate_public_ip_address = true
  vpc_security_group_ids = ["${aws_security_group.aviatrix_controller_sg.id}"]
  key_name = "${var.controller_key}"
  iam_instance_profile = "${module.create_aviatrix_roles.controller_ec2_role}"
  tags {
      Name = "AviatrixController-${var.controller_name_suffix}"
      VPC-RouteTable-Association-ID = "${element(module.create_controller_vpc.vpc_ra_id, 0)}"
  }
  provisioner "local-exec" {
    command = "sleep 1m"
  }
  depends_on = ["aws_security_group_rule.allow_https_inbound","aws_security_group_rule.allow_all_outbound"]
}

resource "aws_eip" "aviatrix_controller_eip" {
  instance = "${aws_instance.aviatrix_controller_ec2.id}"
  vpc      = true
}

resource "null_resource" "initial_setup_controller" {
  provisioner "local-exec" {
    command = "python3 aviatrix_controller/controller_initial_setup.py ${aws_eip.aviatrix_controller_eip.public_ip} ${aws_eip.aviatrix_controller_eip.private_ip} ${var.controller_admin_email} ${var.controller_admin_password}"
  }
}

output "controller_public_ip" {
  value = "${aws_eip.aviatrix_controller_eip.public_ip}"
}
