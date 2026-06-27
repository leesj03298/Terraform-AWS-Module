output "ec2_id" {
  description = "The ID of the EC2 Instance"
  value       = { for key, ec2 in aws_instance.default : key => ec2.id }
}

output "ec2_arn" {
  description = "The ARN of the EC2 Instance"
  value       = { for key, ec2 in aws_instance.default : key => ec2.arn }
}

output "ec2_name" {
  description = "The Name of the EC2 Instance"
  value       = { for key, ec2 in aws_instance.default : key => ec2.tags["Name"] }
}

output "ec2_private_ip" {
  description = "The Private IP of the EC2 Instance"
  value       = { for key, ec2 in aws_instance.default : key => ec2.private_ip }
}

output "ec2_availability_zone" {
  description = "The Availability Zone of the EC2 Instance"
  value       = { for key, ec2 in aws_instance.default : key => ec2.availability_zone }
}

output "eip_public_ip" {
  description = "The Public IP of the EIP"
  value       = { for key, eip in aws_eip.default : key => eip.public_ip }
}

output "ebs_id" {
  description = "The ID of the EBS Volume"
  value       = { for key, ebs in aws_ebs_volume.default : key => ebs.id }
}
