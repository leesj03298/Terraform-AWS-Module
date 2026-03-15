# Terraform AWS Module
- Terraform Repo URL : https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc

## Example Template
```HCL
module "vpc_subnet" {
  source = "../../../../terraform-aws-module_new//vpc"
  vpcs = [
    {
      tf_identifier         = "eks-app-01"
      vpc_name              = "vpc-an2-eks-dev-app-01"
      cidr_block            = "10.10.0.0/23"
      igw_enable            = true
      internet_gateway_name = "igw-an2-eks-dev-app-01"
    },
  ]
  subnets = [
    {
      tf_identifier                = "eks-app-lb-01a"
      vpc_name                     = "vpc-an2-eks-dev-app-01"
      subnet_name                  = "sub-an2-eks-dev-app-lb-01a"
      availability_zone            = "a"
      cidr_block                   = "10.10.0.0/27"
      association_route_table_name = "rtb-an2-eks-dev-app-lb-01a"
    },
    {
      tf_identifier                = "eks-app-lb-01c"
      vpc_name                     = "vpc-an2-eks-dev-app-01"
      subnet_name                  = "sub-an2-eks-dev-app-lb-01c"
      availability_zone            = "c"
      cidr_block                   = "10.10.0.32/27"
      association_route_table_name = "rtb-an2-eks-dev-app-lb-01a"
    }
  ]

  route_tables = [
    {
      tf_identifier = "eks-app-lb-01"
      vpc_name      = "vpc-an2-eks-dev-app-01" 
      route_table_name = "rtb-an2-eks-dev-app-lb-01a"
    }
  ]
}

```