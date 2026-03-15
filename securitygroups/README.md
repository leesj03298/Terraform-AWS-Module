# Security Groups Module

This module creates AWS Security Groups with dynamic ingress and egress rules.

## Resources

- `aws_security_group`

## Usage

```hcl
module "security_groups" {
  source = "../../Module/securitygroups"

  security_groups = [
    {
      tf_key = "web-sg"
      name   = "web-sg"
      vpc_id = "vpc-123456"
      ingress_rules = [
        {
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }
  ]
}
```
