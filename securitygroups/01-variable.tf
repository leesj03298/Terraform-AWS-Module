variable "security_groups" {
  description = "Create Resource : aws_security_group, aws_security_group_rule"
  type = list(object({
    tf_key      = optional(string, null)
    sg_name     = optional(string, null)
    description = optional(string, "Security Group")
    vpc_id      = optional(string, null)
    tags        = optional(map(string), null)
    ## Security Group Rule
    rules = optional(list(object({
      ## for_each Key : join("_", [sg_name, type, protocol, port_range, source])
      ## Example: sg-62726f6479_egress_tcp_8000_8000_pl-6469726b
      type        = optional(string, "ingress")
      protocol    = optional(string, "tcp")
      port_range  = optional(string, null)
      source      = optional(string, null)
      description = optional(string, null)
    })), null)
  }))
  default = []
}
