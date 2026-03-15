
variable "roles" {
  type = list(object({
    name               = optional(string, null)
    assume_role_policy = optional(string, null)
    description        = optional(string, null)
    policys            = optional(list(string), [])
    tags               = optional(map(string), {})
  }))
}