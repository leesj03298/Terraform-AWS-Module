# Security Groups Module

This module creates AWS Security Groups and Security Group Rules.  
Rules are separated into individual `aws_security_group_rule` resources and automatically routed based on the `source` value.

## Resources

- `aws_security_group`
- `aws_security_group_rule` (CIDR / Prefix List / SG Source)

## Usage

```hcl
module "security_groups" {
  source = "../../../Terraform-AWS-Module/securitygroups"

  security_groups = local.securitygroups
}

locals {
  securitygroups = [
    ## CIDR Source
    {
      tf_key      = "scg-an2-lee-dev-ec2-bastion"
      sg_name     = "scg-an2-lee-dev-ec2-bastion"
      description = "Security Group for EC2 Bastion Host"
      vpc_id      = local.vpc_id["vpc-an2-lee-dev-01"]
      rules = [
        { protocol = "tcp", port_range = "22",  source = "0.0.0.0/0",   description = "Allow SSH" },
        { protocol = "tcp", port_range = "443", source = "10.0.0.0/8",  description = "Allow HTTPS from VPC" },
      ]
    },
    ## Prefix List Source
    {
      tf_key      = "scg-an2-lee-dev-eks-cluster"
      sg_name     = "scg-an2-lee-dev-eks-cluster"
      description = "Security Group for EKS Cluster"
      vpc_id      = local.vpc_id["vpc-an2-lee-dev-01"]
      rules = [
        { protocol = "tcp", port_range = "443",       source = "pl-6469726b",              description = "Allow from Prefix List" },
        { protocol = "tcp", port_range = "1025-65535", source = "scg-an2-lee-dev-eks-node", description = "Allow from Node SG" },
      ]
    },
    ## SG Source (동일 모듈 내 tf_key 참조)
    {
      tf_key      = "scg-an2-lee-dev-eks-node"
      sg_name     = "scg-an2-lee-dev-eks-node"
      description = "Security Group for EKS Node Group"
      vpc_id      = local.vpc_id["vpc-an2-lee-dev-01"]
      rules = [
        { protocol = "-1",  port_range = null,  source = "scg-an2-lee-dev-eks-node", description = "Allow Node to Node" },
        { protocol = "tcp", port_range = "443", source = "scg-an2-lee-dev-eks-cluster", description = "Allow from Cluster SG" },
      ]
    },
  ]
}
```

## Rule Source Types

| `source` 값 | 라우팅 리소스 | 예시 |
|---|---|---|
| CIDR 형식 (`x.x.x.x/x`) | `sgr_cidr_blocks` | `"0.0.0.0/0"`, `"10.0.0.0/8"` |
| Prefix List (`pl-` 시작) | `sgr_prefix_list` | `"pl-6469726b"` |
| 그 외 (동일 모듈 내 `tf_key`) | `sgr_source_sg` | `"scg-an2-lee-dev-eks-node"` |

## port_range Format

| 입력값 | from_port | to_port |
|---|---|---|
| `"22"` | 22 | 22 |
| `"1025-65535"` | 1025 | 65535 |
| protocol = `"icmp"` 일 때 `null` | -1 | -1 |
| protocol = `"-1"` 일 때 `null` | 0 | 0 |

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `tf_key` | `string` | `null` | for_each 키 (고유값) |
| `sg_name` | `string` | `null` | Security Group 이름 (Name 태그) |
| `description` | `string` | `"Security Group"` | Security Group 설명 |
| `vpc_id` | `string` | `null` | Security Group을 생성할 VPC ID |
| `tags` | `map(string)` | `null` | 추가 태그 |
| `rules[*].type` | `string` | `"ingress"` | 규칙 방향 (`ingress` / `egress`) |
| `rules[*].protocol` | `string` | `"tcp"` | 프로토콜 (`tcp`, `udp`, `icmp`, `-1`) |
| `rules[*].port_range` | `string` | `null` | 포트 (`"80"` or `"8080-9090"`, icmp·all 은 `null`) |
| `rules[*].source` | `string` | `null` | 소스 (CIDR / Prefix List ID / tf_key) |
| `rules[*].description` | `string` | `null` | 규칙 설명 |

## Outputs

| Name | Description |
|---|---|
| `sg_id` | `map(string)` — tf_key → Security Group ID |
| `sg_name` | `map(string)` — tf_key → Security Group Name |
| `sg_arn` | `map(string)` — tf_key → Security Group ARN |
| `sgr_cidr_id` | `map(string)` — rule key → Rule ID (CIDR source) |
| `sgr_prefix_list_id` | `map(string)` — rule key → Rule ID (Prefix List source) |
| `sgr_source_sg_id` | `map(string)` — rule key → Rule ID (SG source) |

## Notes

- Egress (All Traffic) 규칙은 모든 Security Group에 기본으로 포함됩니다.
- `sgr_source_sg` 는 동일 모듈 호출 내 다른 SG의 `tf_key` 를 `source` 로 참조합니다.
- `sg_name` 은 for_each rule key 생성에 사용되므로 고유해야 합니다.
