output "Spoke Linux Public IP"{
  value = ["${aws_instance.spoke-Linux.*.public_ip}"]
}
output "Spoke Linux Private IP"{
  value = ["${aws_instance.spoke-Linux.*.private_ip}"]
}
output "Shared Services Linux Public IP"{
  value = ["${aws_instance.shared-Linux.*.public_ip}"]
}
output "Shared Services Linux Private IP"{
  value = ["${aws_instance.shared-Linux.*.private_ip}"]
}
output "OnPrem Linux Public IP"{
  value = ["${aws_instance.Linux-On-Prem.public_ip}"]
}
output "OnPrem Linux Private IP"{
  value = ["${aws_instance.Linux-On-Prem.private_ip}"]
}


