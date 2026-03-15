







## Sample Code
### `main.tf`
```HCL
module "iam_role" {
  source = "../../../Terraform-AWS-Module/iamroles"
  roles = [
    {
      name               = "iam-role-lsj-dev-ec2-ssm"
      description        = "EC2 Default Seesion Manageer Role"
      assume_role_policy = templatefile("./policy-assumerole/default.json", { SERVICE = "ec2.amazonaws.com" })
      policys            = ["AmazonSSMManagedInstanceCore"]
    }
  ]
}
```

### 'output.tf'
```HCL
output "sample_iam_role_policy_counts" {
  description = "Map of sample IAM Role names to the count of associated managed policies."
  value       = module.iam_role.iam_role_policy_counts
}

output "sample_iam_role_policy_names" {
  description = "Map of sample IAM Role names to a list of associated managed policy ARNs."
  value       = module.iam_role.iam_role_policy_names
}
```