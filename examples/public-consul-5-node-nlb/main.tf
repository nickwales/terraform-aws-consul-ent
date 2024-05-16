

module "consul" {
  source                    = "../../"
  ssh_key_pair              = var.ssh_keypair_name
  kms_key_arn               = var.kms_key_arn
  iam_instance_profile_arn  = var.iam_instance_profile_arn
  asg_max_size              = 5
  asg_instance_count        = 5
  asg_hook_value            = var.asg_hook_value
  lb_type                   = var.lb_type
  ec2_subnet_ids            = var.ec2_subnet_ids
  lb_tg_arns                = var.lb_tg_arns
  cloudwatch_log_group_name = var.cloudwatch_log_group_name
  log_forwarding_enabled    = var.log_forwarding_enabled
  friendly_name_prefix      = var.friendly_name_prefix
  launch_template_sg_ids    = var.consul_server_launch_template_sg_ids
  ca_bundle_secret_arn      = var.ca_bundle_secret_arn
  cert_secret_arn           = var.cert_secret_arn
  private_key_secret_arn    = var.private_key_secret_arn
  consul_secrets_arn        = var.consul_secrets_arn
  common_tags               = var.common_tags
  consul_agent              = var.consul_server_agent
  snapshot_agent            = var.snapshot_agent
  environment_name          = var.consul_server_environment_name
  consul_cluster_version    = var.consul_server_cluster_version
  route53_resolver_pool     = var.route53_resolver_pool
}

module "agent" {
  source                    = "../../"
  ssh_key_pair              = var.ssh_keypair_name
  kms_key_arn               = var.kms_key_arn
  iam_instance_profile_arn  = var.iam_instance_profile_arn
  asg_max_size              = 1
  asg_instance_count        = 1
  asg_hook_value            = var.asg_hook_value
  ec2_subnet_ids            = var.ec2_subnet_ids
  cloudwatch_log_group_name = var.cloudwatch_log_group_name
  log_forwarding_enabled    = var.log_forwarding_enabled
  friendly_name_prefix      = var.friendly_name_prefix
  launch_template_sg_ids    = var.consul_agent_launch_template_sg_ids
  ca_bundle_secret_arn      = var.ca_bundle_secret_arn
  cert_secret_arn           = var.cert_secret_arn
  private_key_secret_arn    = var.private_key_secret_arn
  consul_secrets_arn        = var.consul_secrets_arn
  common_tags               = var.common_tags
  consul_agent              = var.consul_agent
  environment_name          = var.consul_agent_environment_name
  consul_cluster_version    = var.consul_agent_cluster_version
}

module "tgw" {
  source                    = "../../"
  ssh_key_pair              = var.ssh_keypair_name
  kms_key_arn               = var.kms_key_arn
  iam_instance_profile_arn  = var.iam_instance_profile_arn
  asg_max_size              = 1
  asg_instance_count        = 1
  asg_hook_value            = var.asg_hook_value
  ec2_subnet_ids            = var.ec2_subnet_ids
  cloudwatch_log_group_name = var.cloudwatch_log_group_name
  log_forwarding_enabled    = var.log_forwarding_enabled
  friendly_name_prefix      = var.friendly_name_prefix
  launch_template_sg_ids    = var.consul_agent_launch_template_sg_ids
  ca_bundle_secret_arn      = var.ca_bundle_secret_arn
  cert_secret_arn           = var.cert_secret_arn
  private_key_secret_arn    = var.private_key_secret_arn
  consul_secrets_arn        = var.consul_secrets_arn
  common_tags               = var.common_tags
  consul_agent              = var.consul_agent
  environment_name          = var.consul_gateway_environment_name
  consul_cluster_version    = var.consul_gateway_cluster_version
  ingress_gateway           = var.ingress_gateway
}
