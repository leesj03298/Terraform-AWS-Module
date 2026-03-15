data "aws_region" "current" {}

locals {
  optimize_subnets = flatten([for network in var.vpcs :
    [for subnet in try(network.subnets, []) : merge(subnet, { "tf_key_vpc" = network.tf_key })]
  ])
  optimize_routetables = flatten([for network in var.vpcs :
    [for routetable in try(network.route_tables, []) : merge(routetable, { "tf_key_vpc" = network.tf_key })]
  ])
}
### AWS VPC ##################################################################################################################################
resource "aws_vpc" "default" {
  for_each             = { for vpc in var.vpcs : vpc.tf_key => vpc }
  cidr_block           = each.value.cidr_block
  enable_dns_hostnames = each.value.enable_dns_hostnames
  enable_dns_support   = each.value.enable_dns_support
  instance_tenancy     = each.value.instance_tenancy
  tags                 = merge(each.value.tags, { "Name" = each.value.vpc_name })
}

locals {
  vpc_id = { for key, vpc in aws_vpc.default : key => vpc.id }
}

### AWS Internet Gateway #####################################################################################################################
resource "aws_internet_gateway" "default" {
  for_each   = { for igw in var.vpcs : igw.tf_key => igw if igw.igw_enable }
  vpc_id     = local.vpc_id[each.value.tf_key]
  tags       = merge(each.value.tags, { "Name" = each.value.internet_gateway_name })
  depends_on = [aws_vpc.default]
}

### AWS Subnet ###############################################################################################################################
resource "aws_subnet" "default" {
  for_each          = { for sub in local.optimize_subnets : sub.tf_key => sub }
  vpc_id            = local.vpc_id[each.value.tf_key_vpc]
  availability_zone = each.value.availability_zone
  cidr_block        = each.value.cidr_block
  tags              = merge(each.value.tags, { "Name" = each.value.subnet_name })
}

locals {
  subnet_id = { for key, subnet in aws_subnet.default : key => subnet.id }
}

### AWS Route Table ##########################################################################################################################
resource "aws_route_table" "default" {
  for_each = { for rtb in local.optimize_routetables : rtb.tf_key => rtb }
  vpc_id   = local.vpc_id[each.value.tf_key_vpc]
  tags     = merge(each.value.tags, { "Name" = each.value.route_table_name })
}
locals {
  route_table_id = { for key, route_table in aws_route_table.default : route_table.tags["Name"] => route_table.id }
}

### AWS Route Table Assocation Subnet ########################################################################################################
resource "aws_route_table_association" "default" {
  for_each = { for sub in local.optimize_subnets : sub.tf_key => sub
  if contains(keys(local.route_table_id), sub.association_route_table_name) && contains(keys(local.subnet_id), sub.tf_key) }
  route_table_id = local.route_table_id[each.value.association_route_table_name]
  subnet_id      = local.subnet_id[each.value.tf_key]
}