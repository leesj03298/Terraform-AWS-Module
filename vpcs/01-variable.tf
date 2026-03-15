variable "vpcs" {
  description = "Create Resource : aws_vpc, aws_internet_gateway"
  type = list(object({
    tf_key                = optional(string, null)
    vpc_name              = optional(string, null)
    cidr_block            = optional(string, null)
    enable_dns_hostnames  = optional(bool, true)
    enable_dns_support    = optional(bool, true)
    instance_tenancy      = optional(string, "default")
    igw_enable            = optional(bool, false)
    internet_gateway_name = optional(string, null)
    tags                  = optional(map(string), null)
    subnets = optional(list(object({
      tf_key                       = optional(string, null)
      subnet_name                  = optional(string, null)
      availability_zone            = optional(string, null)
      cidr_block                   = optional(string, null)
      association_route_table_name = optional(string, null)
      tags                         = optional(map(string), null)
    })), null)
    route_tables = optional(list(object({
      tf_key           = optional(string, null)
      route_table_name = optional(string, null)
      tags             = optional(map(string), null)
    })), null)
  }))

  default = []
}

# variable "subnets" {
#   description = "Create Resource : aws_subnet, aws_route_table_association"
#   type = list(object({
#     tf_key                       = optional(string, null)
#     vpc_name                     = optional(string, null)
#     subnet_name                  = optional(string, null)
#     availability_zone            = optional(string, null)
#     cidr_block                   = optional(string, null)
#     association_route_table_name = optional(string, null)
#     tags                         = optional(map(string), null)
#   }))
#   default = []
# }

# variable "route_tables" {
#   description = "Create Resource : aws_route_table"
#   type = list(object({
#     tf_key           = optional(string, null)
#     vpc_name         = optional(string, null)
#     route_table_name = optional(string, null)
#     tags             = optional(map(string), null)
#   }))
#   default = []
# }