locals {
  #### TARGET_GROUP_ATTACHMENT_LIST : aws_lb_target_group_attachment List
  EBS_BLOCK_LIST = flatten([for ec2_instance in var.ec2 : [
    for ebs_block in ec2_instance.ebs_block_device : merge(ebs_block, {
      "ec2_name"          = ec2_instance.ec2_name
      "availability_zone" = ec2_instance.subnet_name
    })
  ] if ec2_instance.ebs_block_device != null])

  subnet_names_optimze        = distinct(var.ec2[*].subnet_name)
  security_group_name_optimze = distinct(flatten(var.ec2[*].security_group_names))
}

data "aws_subnet" "default" {
  for_each = toset(local.subnet_names_optimze)
  tags = {
    Name = each.key
  }
}

data "aws_security_group" "default" {
  for_each = toset(local.security_group_name_optimze)
  tags = {
    Name = each.key
  }
}

#### EC2 ########################################################################################################################
resource "aws_instance" "default" {
  for_each               = { for ec2 in var.ec2 : ec2.tf_identifier => ec2 }
  ami                    = each.value.ami
  instance_type          = each.value.instance_type
  subnet_id              = data.aws_subnet.default[each.value.subnet_name].id
  availability_zone      = data.aws_subnet.default[each.value.subnet_name].availability_zone
  vpc_security_group_ids = [for security_group_name in each.value.security_group_names : data.aws_security_group.default[security_group_name].id]
  private_ip             = each.value.private_ip
  iam_instance_profile   = each.value.iam_instance_profile
  user_data              = each.value.user_data
  key_name               = each.value.key_name
  dynamic "root_block_device" {
    for_each = each.value.root_block_device
    content {
      # volume_type           = root_block_device.value.ebs_block[0]
      # volume_size           = root_block_device.value.ebs_block[1]
      # iops                  = try(root_block_device.value.ebs_block[2], null)
      # throughput            = try(root_block_device.value.ebs_block[3], null)
      # delete_on_termination = try(root_block_device.value.delete_on_termination, null)
      # encrypted             = try(root_block_device.value.ebs_device_encrypted.encrypted, null)
      # kms_key_id            = try(root_block_device.value.ebs_device_encrypted.kms_key_id, null)

      volume_type           = root_block_device.value.volume_type
      volume_size           = root_block_device.value.volume_size
      iops                  = root_block_device.value.iops
      throughput            = root_block_device.value.throughput
      delete_on_termination = root_block_device.value.delete_on_termination
      encrypted             = root_block_device.value.encrypted
      kms_key_id            = root_block_device.value.kms_key_id
    }
  }
  # volume_tags = each.value.root_block_device0[0].tags
  tags = merge({ "Name" = each.value.ec2_name }, each.value.tags)
}

#### EBS ########################################################################################################################
resource "aws_ebs_volume" "default" {
  for_each          = { for EBS_BLOCK_LIST in local.EBS_BLOCK_LIST : "${EBS_BLOCK_LIST.EC2_instance_identifier}_${EBS_BLOCK_LIST.ebs_block[0]}" => EBS_BLOCK_LIST }
  availability_zone = data.aws_subnet.default[each.value.availability_zone].availability_zone
  type              = each.value.ebs_block[1]
  size              = each.value.ebs_block[2]
  iops              = try(each.value.ebs_block[3], null)
  throughput        = try(each.value.ebs_block[4], null)
  encrypted         = each.value.ebs_device_encrypted.encrypted
  kms_key_id        = each.value.ebs_device_encrypted.kms_key_id
}

resource "aws_volume_attachment" "default" {
  for_each    = { for EBS_BLOCK_LIST in local.EBS_BLOCK_LIST : "${EBS_BLOCK_LIST.EC2_instance_identifier}_${EBS_BLOCK_LIST.ebs_block[0]}" => EBS_BLOCK_LIST }
  device_name = each.value.ebs_block[0]
  volume_id   = aws_ebs_volume.default[each.key].id
  instance_id = aws_instance.default[each.value.ec2_name].id
}

#### EIP ########################################################################################################################
resource "aws_eip" "default" {
  for_each                  = { for eip in var.ec2 : eip.tf_identifier => eip if eip.public_ip == true && length(aws_instance.default) != 0 }
  instance                  = aws_instance.default[each.key].id
  associate_with_private_ip = aws_instance.default[each.key].private_ip
  tags                      = merge(each.value.tags)
}


#### ENI ########################################################################################################################
# resource "aws_network_interface" "default" {
#   for_each = { for eni in var.enis : "${eni.instance_identifier}-${eni.device_index}" => eni
#   if eni.instance_identifier != null }
#   subnet_id       = each.value.subnet_id
#   private_ips     = each.value.private_ips
#   security_groups = each.value.security_groups
#   attachment {
#     instance     = aws_instance.default["${each.value.instance_identifier}"].id
#     device_index = each.value.device_index
#   }
# }


