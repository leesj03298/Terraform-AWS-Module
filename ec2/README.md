# EC2 Module

This module creates AWS EC2 instances with optional EIP, root block device, and additional EBS volumes.  
EBS volumes are nested within each EC2 definition and flattened into individual resources.

## Resources

- `aws_instance`
- `aws_eip` (`public_ip = true` 인 경우)
- `aws_ebs_volume` (`ebs_volumes` 정의 시)
- `aws_volume_attachment`

## Usage

```hcl
module "ec2" {
  source = "../../../Terraform-AWS-Module/ec2"

  ec2s = local.ec2s
}

locals {
  ec2s = [
    ## 기본 EC2 (CIDR Ingress)
    {
      tf_key             = "ec2-an2-lee-dev-bastion"
      ec2_name           = "ec2-an2-lee-dev-bastion"
      ami                = "ami-0c9c942bd7bf113a2"
      instance_type      = "t3.micro"
      subnet_id          = module.vpc.sub_id["pub-sub-an2a-lee-dev-01"]
      security_group_ids = [module.security_groups.sg_id["scg-an2-lee-dev-ec2-bastion"]]
      key_name           = "lee-dev-key"
      public_ip          = true
      tags               = { "Env" = "dev" }
      root_block_device = {
        volume_type = "gp3"
        volume_size = 20
        encrypted   = true
      }
    },
    ## EC2 + 추가 EBS
    {
      tf_key             = "ec2-an2-lee-dev-app"
      ec2_name           = "ec2-an2-lee-dev-app"
      ami                = "ami-0c9c942bd7bf113a2"
      instance_type      = "t3.small"
      subnet_id          = module.vpc.sub_id["pri-sub-an2a-lee-dev-01"]
      security_group_ids = [module.security_groups.sg_id["scg-an2-lee-dev-ec2-app"]]
      iam_instance_profile = "ec2-ssm-profile"
      root_block_device = {
        volume_type = "gp3"
        volume_size = 30
        encrypted   = true
      }
      ebs_volumes = [
        { tf_key = "data", device_name = "/dev/xvdf", volume_type = "gp3", volume_size = 100, encrypted = true },
        { tf_key = "log",  device_name = "/dev/xvdg", volume_type = "gp3", volume_size = 50,  encrypted = true },
      ]
    },
  ]
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `tf_key` | `string` | `null` | for_each 키 (고유값) |
| `ec2_name` | `string` | `null` | EC2 이름 (Name 태그) |
| `ami` | `string` | `null` | AMI ID |
| `instance_type` | `string` | `"t3.micro"` | 인스턴스 타입 |
| `subnet_id` | `string` | `null` | 배치할 Subnet ID |
| `security_group_ids` | `list(string)` | `null` | Security Group ID 목록 |
| `iam_instance_profile` | `string` | `null` | IAM Instance Profile 이름 |
| `user_data` | `string` | `null` | User Data 스크립트 |
| `key_name` | `string` | `null` | Key Pair 이름 |
| `public_ip` | `bool` | `false` | `true` 시 EIP 생성 |
| `private_ip` | `string` | `null` | 고정 Private IP |
| `tags` | `map(string)` | `null` | 추가 태그 |
| `root_block_device.volume_type` | `string` | `"gp3"` | Root 볼륨 타입 |
| `root_block_device.volume_size` | `number` | `8` | Root 볼륨 크기 (GiB) |
| `root_block_device.iops` | `number` | `null` | Root 볼륨 IOPS |
| `root_block_device.throughput` | `number` | `null` | Root 볼륨 Throughput (MiB/s) |
| `root_block_device.encrypted` | `bool` | `false` | Root 볼륨 암호화 여부 |
| `root_block_device.kms_key_id` | `string` | `null` | Root 볼륨 KMS Key ID |
| `root_block_device.delete_on_termination` | `bool` | `true` | 인스턴스 종료 시 삭제 여부 |
| `ebs_volumes[*].tf_key` | `string` | `null` | EBS 볼륨 식별자 (for_each 키에 사용) |
| `ebs_volumes[*].device_name` | `string` | `"/dev/xvdf"` | 디바이스 이름 |
| `ebs_volumes[*].volume_type` | `string` | `"gp3"` | 볼륨 타입 |
| `ebs_volumes[*].volume_size` | `number` | `20` | 볼륨 크기 (GiB) |
| `ebs_volumes[*].iops` | `number` | `null` | IOPS |
| `ebs_volumes[*].throughput` | `number` | `null` | Throughput (MiB/s) |
| `ebs_volumes[*].encrypted` | `bool` | `false` | 암호화 여부 |
| `ebs_volumes[*].kms_key_id` | `string` | `null` | KMS Key ID |
| `ebs_volumes[*].delete_on_termination` | `bool` | `true` | 인스턴스 종료 시 삭제 여부 |

## Outputs

| Name | Description |
|---|---|
| `ec2_id` | `map(string)` — tf_key → EC2 Instance ID |
| `ec2_arn` | `map(string)` — tf_key → EC2 Instance ARN |
| `ec2_name` | `map(string)` — tf_key → EC2 Name 태그 |
| `ec2_private_ip` | `map(string)` — tf_key → Private IP |
| `ec2_availability_zone` | `map(string)` — tf_key → Availability Zone |
| `eip_public_ip` | `map(string)` — tf_key → EIP Public IP |
| `ebs_id` | `map(string)` — `{tf_key_ec2}_{tf_key}` → EBS Volume ID |

## Notes

- `public_ip = true` 로 설정하면 EIP가 생성되어 인스턴스에 연결됩니다.
- `ebs_volumes` for_each 키 형식: `{tf_key_ec2}_{tf_key}` (예: `ec2-an2-lee-dev-app_data`)
- `subnet_id`, `security_group_ids` 는 모듈 output을 직접 참조합니다. data source 조회를 하지 않습니다.
