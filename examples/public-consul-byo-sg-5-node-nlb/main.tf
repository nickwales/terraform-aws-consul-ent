module "sg" {
  source               = "../../../terraform-aws-consul-prerequisites/modules/sg"
  security_group_rules = var.security_group_rules
  friendly_name_prefix = var.friendly_name_prefix
  common_tags          = var.common_tags
  product              = var.product
  vpc_id               = var.vpc_id
}

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
  consul_agent = {
    auto_reload_config = var.consul_server_agent.auto_reload_config
    server             = var.consul_server_agent.server
    ui                 = var.consul_server_agent.ui
    join_environment   = var.consul_server_agent.join_environment
    security_group_id  = module.sg.server_security_group_id
  }
  snapshot_agent         = var.snapshot_agent
  environment_name       = var.consul_server_environment_name
  consul_cluster_version = var.consul_server_cluster_version
  route53_resolver_pool  = var.route53_resolver_pool
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
  consul_agent = {
    auto_reload_config = var.consul_agent.auto_reload_config
    server             = var.consul_agent.server
    ui                 = var.consul_agent.ui
    join_environment   = var.consul_agent.join_environment
    security_group_id  = module.sg.agent_security_group_id
  }
  environment_name       = var.consul_agent_environment_name
  consul_cluster_version = var.consul_agent_cluster_version
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
  consul_agent = {
    auto_reload_config = var.consul_agent.auto_reload_config
    server             = var.consul_agent.server
    ui                 = var.consul_agent.ui
    join_environment   = var.consul_agent.join_environment
    security_group_id  = module.sg.agent_security_group_id
  }
  environment_name       = var.consul_gateway_environment_name
  consul_cluster_version = var.consul_gateway_cluster_version
  ingress_gateway = {
    enabled           = var.ingress_gateway.enabled
    container_image   = var.ingress_gateway.container_image
    service_name      = var.ingress_gateway.service_name
    listener_ports    = var.ingress_gateway.listener_ports
    ingress_cidrs     = var.ingress_gateway.ingress_cidrs
    security_group_id = module.sg.gateway_security_group_id
  }
}
