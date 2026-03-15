variable "security_groups" {
  description = "Create Resource : aws_security_group"
  type = list(object({
    tf_key      = string
    name        = string
    description = optional(string, "Managed by Terraform")
    vpc_id      = string
    tags        = optional(map(string), {})

    ingress_rules = optional(list(object({
      description      = optional(string, null)
      from_port        = number
      to_port          = number
      protocol         = string
      cidr_blocks      = optional(list(string), [])
      ipv6_cidr_blocks = optional(list(string), [])
      security_groups  = optional(list(string), [])
      self             = optional(bool, false)
    })), [])

    egress_rules = optional(list(object({
      description      = optional(string, null)
      from_port        = number
      to_port          = number
      protocol         = string
      cidr_blocks      = optional(list(string), ["0.0.0.0/0"])
      ipv6_cidr_blocks = optional(list(string), ["::/0"])
      security_groups  = optional(list(string), [])
      self             = optional(bool, false)
    })), [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ])
  }))
  default = []
}
