locals {
  optimize_rules = flatten([for sg in var.security_groups :
    [for rule in try(sg.rules, []) : merge(rule, { "tf_key_sg" = sg.tf_key, "sg_name" = sg.sg_name })]
  ])
}

### AWS Security Group #######################################################
resource "aws_security_group" "default" {
  for_each    = { for sg in var.security_groups : sg.tf_key => sg }
  name        = each.value.sg_name
  description = each.value.description
  vpc_id      = each.value.vpc_id
  tags        = merge(each.value.tags, { "Name" = each.value.sg_name })
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

locals {
  sg_id = { for key, sg in aws_security_group.default : key => sg.id }
}

### AWS Security Group Rule (CIDR Source) ####################################
resource "aws_security_group_rule" "sgr_cidr_blocks" {
  for_each          = { for rule in local.optimize_rules :
                        join("_", [rule.sg_name, rule.type, rule.protocol, replace(rule.port_range, "-", "_"), rule.source]) => rule
                        if can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+/[0-9]+$", rule.source)) }
  security_group_id = local.sg_id[each.value.tf_key_sg]
  type              = each.value.type
  protocol          = each.value.protocol
  from_port         = each.value.protocol == "icmp" ? -1 : each.value.protocol == "-1" ? 0 : tonumber(split("-", each.value.port_range)[0])
  to_port           = each.value.protocol == "icmp" ? -1 : each.value.protocol == "-1" ? 0 : can(split("-", each.value.port_range)[1]) ? tonumber(split("-", each.value.port_range)[1]) : tonumber(split("-", each.value.port_range)[0])
  cidr_blocks       = [each.value.source]
  description       = each.value.description
}

### AWS Security Group Rule (Prefix List Source) #############################
resource "aws_security_group_rule" "sgr_prefix_list" {
  for_each          = { for rule in local.optimize_rules :
                        join("_", [rule.sg_name, rule.type, rule.protocol, replace(rule.port_range, "-", "_"), rule.source]) => rule
                        if can(regex("^pl-", rule.source)) }
  security_group_id = local.sg_id[each.value.tf_key_sg]
  type              = each.value.type
  protocol          = each.value.protocol
  from_port         = each.value.protocol == "icmp" ? -1 : each.value.protocol == "-1" ? 0 : tonumber(split("-", each.value.port_range)[0])
  to_port           = each.value.protocol == "icmp" ? -1 : each.value.protocol == "-1" ? 0 : can(split("-", each.value.port_range)[1]) ? tonumber(split("-", each.value.port_range)[1]) : tonumber(split("-", each.value.port_range)[0])
  prefix_list_ids   = [each.value.source]
  description       = each.value.description
}

### AWS Security Group Rule (SG Source) ######################################
resource "aws_security_group_rule" "sgr_source_sg" {
  for_each                 = { for rule in local.optimize_rules :
                               join("_", [rule.sg_name, rule.type, rule.protocol, replace(rule.port_range, "-", "_"), rule.source]) => rule
                               if !can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+/[0-9]+$", rule.source)) && !can(regex("^pl-", rule.source)) }
  security_group_id        = local.sg_id[each.value.tf_key_sg]
  type                     = each.value.type
  protocol                 = each.value.protocol
  from_port                = each.value.protocol == "icmp" ? -1 : each.value.protocol == "-1" ? 0 : tonumber(split("-", each.value.port_range)[0])
  to_port                  = each.value.protocol == "icmp" ? -1 : each.value.protocol == "-1" ? 0 : can(split("-", each.value.port_range)[1]) ? tonumber(split("-", each.value.port_range)[1]) : tonumber(split("-", each.value.port_range)[0])
  source_security_group_id = local.sg_id[each.value.source]
  description              = each.value.description
}
