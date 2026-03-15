locals {
  iam_role_policy_attachment = flatten([for role in var.roles : [for policy in role.policys :
    {
      role_name   = role.name
      policy_name = policy
  }]])
}

data "aws_iam_policy" "default" {
  for_each = toset(distinct(local.iam_role_policy_attachment[*].policy_name))
  name     = each.key
}

resource "aws_iam_role" "default" {
  for_each           = { for role in var.roles : role.name => role }
  name               = each.value.name
  assume_role_policy = each.value.assume_role_policy
  description        = each.value.description
  tags               = merge({ "Name" = each.value.name }, each.value.tags)
}

resource "aws_iam_role_policy_attachment" "default" {
  for_each   = { for attachment in local.iam_role_policy_attachment : "${attachment.role_name}_${attachment.policy_name}" => attachment }
  role       = each.value.role_name
  policy_arn = data.aws_iam_policy.default[each.value.policy_name].arn
  depends_on = [aws_iam_role.default]
}

resource "aws_iam_instance_profile" "default" {
  for_each = { for role in var.roles : role.name => role if strcontains(role.assume_role_policy, "ec2.amazonaws.com") }
  name     = each.value.name
  role     = each.value.name
}