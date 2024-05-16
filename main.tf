data "aws_subnet" "instance" {
  for_each = toset(var.ec2_subnet_ids)
  id       = each.value
}

#------------------------------------------------------------------------------
# AMI
#------------------------------------------------------------------------------

data "aws_ami" "ubuntu" {
  count = var.os_distro == "ubuntu" && var.ami_id == null ? 1 : 0

  owners      = ["099720109477", "513442679011"]
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

data "aws_ami" "centos" {
  count = var.os_distro == "centos" && var.ami_id == null ? 1 : 0

  owners      = ["679593333241"]
  most_recent = true

  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

data "aws_region" "current" {}

#------------------------------------------------------------------------------
# Cloud
#------------------------------------------------------------------------------

data "cloudinit_config" "cinit" {
  gzip          = true
  base64_encode = true
  part {
    content_type = "text/jinja2"
    content      = "${path.module}/templates/00_init.yaml"
  }
  part {
    content_type = "x-shellscript"
    content      = templatefile("${path.module}/templates/consul_install.sh.tpl", local.user_data_args)
  }
}

module "cloud_init" {
  source = "./modules/cloud_init"
  install_docker_before        = var.install_docker_before
  log_path                     = var.log_path
  cloudwatch_log_group_name    = var.cloudwatch_log_group_name
  cloudwatch_retention_in_days = var.cloudwatch_retention_in_days
  log_forwarding_enabled       = var.log_forwarding_enabled
  product                      = var.product
  cloud                        = var.cloud
  docker_version               = var.docker_version
}

resource "aws_launch_template" "lt" {
  name_prefix            = "${var.friendly_name_prefix}-${var.product}-${var.environment_name}-asg-lt"
  image_id               = coalesce(local.image_id_list...)
  instance_type          = var.instance_size
  key_name               = var.ssh_key_pair
  update_default_version = true
  user_data              = data.cloudinit_config.cinit.rendered


  iam_instance_profile {
    arn = var.iam_instance_profile_arn
  }

  lifecycle {
    create_before_destroy = true
  }

  vpc_security_group_ids = concat(var.launch_template_sg_ids, [var.consul_agent.security_group_id], (var.ingress_gateway.enabled || var.mesh_gateway.enabled ? try([var.ingress_gateway.security_group_id], [var.mesh_gateway.security_group_id]) : []))

  block_device_mappings {
    device_name = local.root_device_name
    ebs {
      volume_type = var.ebs_volumes.volume_type
      volume_size = var.ebs_volumes.volume_size
      iops        = var.ebs_volumes.iops
      encrypted   = var.ebs_volumes.encrypted
      kms_key_id  = var.ebs_volumes.encrypted ? var.kms_key_arn : null
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 2
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      { "Name" = "${var.friendly_name_prefix}-${var.product}-${var.environment_name}-ec2" },
      { "Type" = "autoscaling-group" },
      { "OS_Distro" = var.os_distro },
      { "asg-hook" = var.asg_hook_value },
      var.common_tags
    )
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      { "Name" = "${var.friendly_name_prefix}-${var.product}-${var.environment_name}-vol" },
      { "Type" = "autoscaling-group" },
      { "OS_Distro" = var.os_distro },
      { "asg-hook" = var.asg_hook_value },
      var.common_tags
    )
  }

  tags = merge({
    "asg-hook" = var.asg_hook_value
    },
    var.common_tags
  )
}

#------------------------------------------------------------------------------
# Autoscaling Group
#------------------------------------------------------------------------------
resource "aws_autoscaling_group" "asg" {
  name_prefix               = "${var.friendly_name_prefix}-${var.product}-${var.environment_name}-asg"
  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  desired_capacity          = var.asg_instance_count
  vpc_zone_identifier       = var.ec2_subnet_ids
  health_check_grace_period = var.asg_health_check_grace_period
  health_check_type         = var.asg_health_check_type # They default to EC2 so just making a note while we test
  service_linked_role_arn   = var.asg_custom_role_arn
  wait_for_capacity_timeout = var.asg_capacity_timeout
  wait_for_elb_capacity     = var.asg_min_size

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  initial_lifecycle_hook {
    name                 = var.asg_hook_value
    default_result       = "ABANDON"
    heartbeat_timeout    = 600
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
  }

  target_group_arns = var.lb_tg_arns

  tag {
    key                 = "Name"
    value               = "${var.friendly_name_prefix}-${var.product}-${var.environment_name}-asg"
    propagate_at_launch = true
  }

  tag {
    key                 = "asg-hook"
    value               = var.asg_hook_value
    propagate_at_launch = true
  }
  tag {
    key                 = "Cluster-Version"
    value               = var.consul_cluster_version
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment-Name"
    value               = "${var.environment_name}-consul"
    propagate_at_launch = true
  }

  tag {
    key                 = "consul_cluster_version"
    value               = var.consul_cluster_version
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.common_tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  dynamic "tag" {
    for_each = var.auto_join_tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

#------------------------------------------------------------------------------
# Security Groups
#------------------------------------------------------------------------------

resource "aws_security_group_rule" "ingress_gw" {
  for_each = var.lb_type == "network" && var.ingress_gateway.enabled ? toset(var.ingress_gateway.listener_ports) : []

  type        = "ingress"
  from_port   = each.value
  to_port     = each.value
  protocol    = "tcp"
  cidr_blocks = var.ingress_gateway.ingress_cidrs
  description = "Allow Mesh Gateway traffic to the Consul Ingress Gateways"

  security_group_id = var.ingress_gateway.security_group_id
}

