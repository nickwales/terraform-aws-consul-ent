locals {
  enable_grpc = var.ingress_gateway.enabled || var.terminating_gateway.enabled || var.mesh_gateway.enabled || var.consul_agent.enable_grpc
  base_config = {
    server                        = var.consul_agent.server
    node_name                     = "{{ v1.local_hostname }}"
    enable_central_service_config = true
    encrypt                       = "$GOSSIP_KEY"
    domain                        = var.consul_agent.domain
    datacenter                    = var.consul_agent.datacenter
    primary_datacenter            = var.consul_agent.primary_datacenter
    license_path                  = var.consul_agent.server ? "/consul/config/license/consul.hclic" : null
    tls = {
      defaults = {
        ca_file         = "/consul/config/tls/consul-agent-ca.pem"
        cert_file       = var.consul_agent.server ? "/consul/config/tls/consul-server-public.pem" : ""
        key_file        = var.consul_agent.server ? "/consul/config/tls/consul-server-private.pem" : ""
        verify_incoming = false
        verify_outgoing = true
      }

      grpc = {
        use_auto_cert = false
      }

      internal_rpc = {
        verify_incoming        = true
        verify_server_hostname = true
      }
    }

    client_addr = var.consul_agent.server ? "0.0.0.0" : "127.0.0.1"

    bootstrap_expect = var.consul_agent.server ? var.asg_instance_count : 0
    retry_join       = ["provider=aws tag_key=Environment-Name tag_value=${var.consul_agent.join_environment}-consul"]

    acl = {
      enabled                  = true
      default_policy           = "deny"
      down_policy              = "extend-cache"
      enable_token_replication = true
      enable_token_persistence = true
      tokens = var.consul_agent.server ? {
        initial_management = "$ACL_TOKEN"
        agent              = "$AGENT_TOKEN"
        } : {
        agent = "$AGENT_TOKEN"
      }
    }

    auto_encrypt = var.consul_agent.server ? { allow_tls = true } : { tls = true }

    autopilot = { for k, v in {
      upgrade_version_tag = "consul_cluster_version"
      redundancy_zone_tag = var.server_redundancy_zones ? "availability_zone" : ""
      min_quorum          = var.asg_instance_count
    } : k => v if var.consul_agent.server }

    connect = {
      enabled                            = true
      enable_mesh_gateway_wan_federation = var.consul_agent.server
    }

    node_meta = {
      consul_cluster_version = var.consul_cluster_version
      availability_zone      = "{{ v1.availability_zone }}"
    }

    performance = {
      raft_multiplier = 1
    }

    ports = {
      http     = -1
      https    = 8501
      grpc     = local.enable_grpc ? 8502 : -1
      grpc_tls = local.enable_grpc ? 8503 : -1
      dns      = var.route53_resolver_pool.enabled ? 8600 : -1
    }

    addresses = {
      dns = var.route53_resolver_pool.enabled ? "0.0.0.0" : "127.0.0.1"
    }

    ui_config = {
      enabled = var.consul_agent.ui
    }
  }

  consul_config = jsonencode(merge(local.base_config, var.consul_additional_config))

  install_vars = {
    consul_agent        = var.consul_agent
    product             = var.product
    consul_config       = local.consul_config
    consul_secrets_arn  = var.consul_secrets_arn
    ingress_gateway     = var.ingress_gateway
    terminating_gateway = var.terminating_gateway
    mesh_gateway        = var.mesh_gateway
    nlb_address         = var.mesh_gateway.enabled ? var.mesh_gateway.nlb_address : ""
  }
  # tflint-ignore: terraform_unused_declarations
  verify_vars = {
    autopilot_health_enabled = var.autopilot_health_enabled
    consul_agent             = var.consul_agent
    total_nodes              = var.asg_max_size
    total_voters             = var.server_redundancy_zones ? length(toset([for i in data.aws_subnet.instance : i.availability_zone])) : var.asg_max_size
    consul_cluster_version   = var.consul_cluster_version
    asg_name                 = local.asg_name
  }

  snapshot_vars = {
    consul_agent       = var.consul_agent
    consul_secrets_arn = var.consul_secrets_arn
    snapshot_agent     = var.snapshot_agent
    aws_region         = data.aws_region.current
    product            = var.product
  }
  template_name = "${var.environment_name}-${var.product}"
  asg_name      = "${local.template_name}-${var.consul_cluster_version}"

  image_id_list    = tolist([var.ami_id, join("", data.aws_ami.ubuntu[*].image_id), join("", data.aws_ami.centos[*].image_id)])
  root_device_name = lookup({ "ubuntu" = "/dev/sda1", "centos" = "/dev/sda1" }, var.os_distro, "/dev/sda1")

  user_data_args = {
    consul_secrets_arn          = var.consul_secrets_arn
    ca_bundle_secret_arn        = var.ca_bundle_secret_arn
    cert_secret_arn             = var.cert_secret_arn
    private_key_secret_arn      = var.private_key_secret_arn
    config_directory            = var.consul_config_directory
    home_directory              = var.consul_config_directory
    data_directory              = var.consul_data_directory
    using_packer_image          = var.packer_image == null ? false : true,
    skip_install_tools          = var.skip_install_tools,
    kms_data                    = var.kms_key_arn
    auto_join_tag_key           = length(var.auto_join_tags) >= 1 ? keys(var.auto_join_tags)[0] : try(keys(var.common_tags)[0], null)
    auto_join_tag_value         = length(var.auto_join_tags) >= 1 ? values(var.auto_join_tags)[0] : try(values(var.common_tags)[0], null)
    general_cloudinit_funcs     = module.cloud_init.template_output
    product                     = var.product
    cloud                       = var.cloud
    consul_systemd_directory    = var.consul_systemd_directory
    consul_agent                = var.consul_agent
    consul_agent_data           = local.consul_config
    install_ingress_gateway     = templatefile("${path.module}/templates/install_ingress_gateway.sh.tpl", local.install_vars)
    install_mesh_gateway        = templatefile("${path.module}/templates/install_mesh_gateway.sh.tpl", local.install_vars)
    install_snapshot_agent      = templatefile("${path.module}/templates/install_snapshot_agent.sh.tpl", local.snapshot_vars)
    install_systemd_config      = templatefile("${path.module}/templates/install_systemd_config.sh.tpl", local.install_vars)
    install_terminating_gateway = templatefile("${path.module}/templates/install_terminating_gateway.sh.tpl", local.install_vars)
  }

}

