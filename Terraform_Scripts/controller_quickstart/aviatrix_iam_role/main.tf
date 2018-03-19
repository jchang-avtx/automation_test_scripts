# create aviatrix role and policy
resource "aws_iam_policy" "aviatrix_assume_role_policy" {
  count       = "${var.create_iam_role}"
  name        = "aviatrix-assume-role-policy"
  description = "aviatrix assume role policy"
  policy      = "${file("aviatrix_iam_role/aviatrix-assume-role-policy.json")}"
}

resource "aws_iam_policy" "aviatrix_app_policy" {
  count       = "${var.create_iam_role}"
  name        = "aviatrix-app-policy"
  description = "aviatrix app policy"
  policy      = "${file("aviatrix_iam_role/aviatrix-app-policy.json")}"
}


resource "aws_iam_role" "aviatrix_role_ec2" {
    count       = "${var.create_iam_role}"
    name = "aviatrix-role-ec2"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role" "aviatrix_role_app" {
    count       = "${var.create_iam_role}"
    name = "aviatrix-role-app"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${var.aws_account_number}:root"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "aviatrix_role_ec2_attach" {
  count       = "${var.create_iam_role}"
  name       = "aviatrix-role-ec2-attach"
  roles      = ["${aws_iam_role.aviatrix_role_ec2.name}"]
  policy_arn = "${aws_iam_policy.aviatrix_assume_role_policy.arn}"
}

resource "aws_iam_policy_attachment" "aviatrix_role_app_attach" {
  count       = "${var.create_iam_role}"
  name       = "aviatrix-role-app-attach"
  roles      = ["${aws_iam_role.aviatrix_role_app.name}"]
  policy_arn = "${aws_iam_policy.aviatrix_app_policy.arn}"
}

resource "aws_iam_instance_profile" "aviatrix-role-ec2" {
  count       = "${var.create_iam_role}"
  name = "aviatrix-role-ec2"
  role = "aviatrix-role-ec2"
}

output "controller_ec2_role" {
  value = "aviatrix-role-ec2"
}

