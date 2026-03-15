output "aws_iam_roles" {
  description = "Map of AWS IAM Roles"
  value       = aws_iam_role.default
}

output "aws_iam_role_policy_attachments" {
  description = "Map of AWS IAM Role Policy Attachments"
  value       = aws_iam_role_policy_attachment.default
}

output "aws_iam_role_count" {
  description = "Count of AWS IAM Roles created"
  value       = length(aws_iam_role.default)
}

output "aws_iam_role_policy_attachment_count" {
  description = "Count of AWS IAM Role Policy Attachments created"
  value       = length(aws_iam_role_policy_attachment.default)
}

output "iam_role_policy_counts" {
  description = "Map of IAM Role names to the count of associated managed policies."
  value = {
    for role_key, value in aws_iam_role.default : role_key => length([
      for attach_key in keys(aws_iam_role_policy_attachment.default) : split("_", attach_key) if strcontains(attach_key, role_key)
    ])
    # for key, value in aws_iam_role_policy_attachment.default : split("_", key)[0] => split("_", key)[1]...
  }
}

output "iam_role_policy_names" {
  description = "Map of IAM Role names to a list of associated managed policy ARNs."
  value = {
    # for role_key, value in aws_iam_role.default : role_key => [
    #   for attach_key in keys(aws_iam_role_policy_attachment.default) : split("_", attach_key) if strcontains(attach_key, role_key)
    # ]
    for key, value in aws_iam_role_policy_attachment.default : split("_", key)[0] => split("_", key)[1]...
  }
}
