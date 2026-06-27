locals {
  optimize_ebs_volumes = flatten([for ec2 in var.ec2s :
    [for vol in try(ec2.ebs_volumes, []) : merge(vol, { "tf_key_ec2" = ec2.tf_key })]
  ])
}

### AWS EC2 Instance #########################################################
resource "aws_instance" "default" {
  for_each               = { for ec2 in var.ec2s : ec2.tf_key => ec2 }
  ami                    = each.value.ami
  instance_type          = each.value.instance_type
  subnet_id              = each.value.subnet_id
  vpc_security_group_ids = each.value.security_group_ids
  private_ip             = each.value.private_ip
  iam_instance_profile   = each.value.iam_instance_profile
  user_data              = each.value.user_data
  key_name               = each.value.key_name
  tags                   = merge(each.value.tags, { "Name" = each.value.ec2_name })

  dynamic "root_block_device" {
    for_each = each.value.root_block_device != null ? [each.value.root_block_device] : []
    content {
      volume_type           = root_block_device.value.volume_type
      volume_size           = root_block_device.value.volume_size
      iops                  = root_block_device.value.iops
      throughput            = root_block_device.value.throughput
      delete_on_termination = root_block_device.value.delete_on_termination
      encrypted             = root_block_device.value.encrypted
      kms_key_id            = root_block_device.value.kms_key_id
      tags                  = root_block_device.value.tags
    }
  }
}

locals {
  ec2_id = { for key, ec2 in aws_instance.default : key => ec2.id }
}

### AWS EIP ##################################################################
resource "aws_eip" "default" {
  for_each = { for ec2 in var.ec2s : ec2.tf_key => ec2 if ec2.public_ip == true }
  instance = local.ec2_id[each.key]
  tags     = merge(each.value.tags, { "Name" = each.value.ec2_name })
}

### AWS EBS Volume ###########################################################
resource "aws_ebs_volume" "default" {
  for_each          = { for vol in local.optimize_ebs_volumes : "${vol.tf_key_ec2}_${vol.tf_key}" => vol }
  availability_zone = aws_instance.default[each.value.tf_key_ec2].availability_zone
  type              = each.value.volume_type
  size              = each.value.volume_size
  iops              = each.value.iops
  throughput        = each.value.throughput
  encrypted         = each.value.encrypted
  kms_key_id        = each.value.kms_key_id
  tags              = merge(each.value.tags, { "Name" = "${each.value.tf_key_ec2}-${each.value.tf_key}" })
}

### AWS EBS Volume Attachment ################################################
resource "aws_volume_attachment" "default" {
  for_each    = { for vol in local.optimize_ebs_volumes : "${vol.tf_key_ec2}_${vol.tf_key}" => vol }
  device_name = each.value.device_name
  volume_id   = aws_ebs_volume.default[each.key].id
  instance_id = local.ec2_id[each.value.tf_key_ec2]
}
