output "sg_id" {
  description = "The ID of the Security Group"
  value       = { for key, sg in aws_security_group.default : key => sg.id }
}

output "sg_name" {
  description = "The Name of the Security Group"
  value       = { for key, sg in aws_security_group.default : key => sg.name }
}

output "sg_arn" {
  description = "The ARN of the Security Group"
  value       = { for key, sg in aws_security_group.default : key => sg.arn }
}
