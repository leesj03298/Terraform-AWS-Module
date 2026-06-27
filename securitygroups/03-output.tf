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

output "sgr_cidr_id" {
  description = "The ID of the Security Group Rule (CIDR source)"
  value       = { for key, rule in aws_security_group_rule.sgr_cidr_blocks : key => rule.id }
}

output "sgr_prefix_list_id" {
  description = "The ID of the Security Group Rule (Prefix List source)"
  value       = { for key, rule in aws_security_group_rule.sgr_prefix_list : key => rule.id }
}

output "sgr_source_sg_id" {
  description = "The ID of the Security Group Rule (SG source)"
  value       = { for key, rule in aws_security_group_rule.sgr_source_sg : key => rule.id }
}
