## Ported Variables that I need to verify
variable "environment_name" {
  type        = string
  description = "Unique environment name to prefix and disambiguate resources using."
}

variable "consul_cluster_version" {
  type        = string
  description = "SemVer version string representing the cluster's deployent iteration. Must always be incremented when deploying updates (e.g. new AMIs, updated launch config)"
}

#------------------------------------------------------------------------------
# Common
#------------------------------------------------------------------------------
variable "friendly_name_prefix" {
  type        = string
  description = "String value for friendly name prefix for AWS resource names."
}

variable "common_tags" {
  type        = map(string)
  description = "Map of common tags for taggable AWS resources."
  default     = {}
}

variable "cloud" {
  type        = string
  description = "Name of the cloud we are provisioning on. This is used for templating functions and is default to AWS for this module."
  default     = "aws"
}

variable "product" {
  type        = string
  description = "Name of the HashiCorp product that will be installed (tfe, vault, consul)"
  validation {
    condition     = contains(["tfe", "vault", "consul"], var.product)
    error_message = "`var.product` must be \"tfe\", \"vault\", or \"consul\"."
  }
  default = "consul"
}

#------------------------------------------------------------------------------
# Consul Installation Settings
#------------------------------------------------------------------------------


variable "consul_agent" {
  type = object({
    container_image               = optional(string, "hashicorp/consul-enterprise:1.16.0-ent")
    server                        = optional(bool, true)
    domain                        = optional(string, "consul")
    datacenter                    = optional(string, "dc1")
    primary_datacenter            = optional(string, "dc1")
    join_environment              = optional(string, "primary")
    ui                            = optional(bool, false)
    log_level                     = optional(string, "INFO")
    partition                     = optional(string, "")
    auto_reload_config            = optional(bool, true)
    enable_central_service_config = optional(bool, true)
    enable_grpc                   = optional(bool, false)
    security_group_id             = string
  })
  description = "Object map that contains the configuration for the Consul agent that will be deployed on the workloads within the environment."
}

variable "snapshot_agent" {
  type = object({
    enabled        = optional(bool, false)
    interval       = optional(string, "")
    retention      = optional(number, 0)
    s3_bucket_name = optional(string, "")
  })
  description = "Configuration object to enable the Consul snapshot agent."
  default     = {}
}

variable "ingress_gateway" {
  type = object({
    enabled           = optional(bool, false)
    container_image   = optional(string, "")
    service_name      = optional(string, "")
    listener_ports    = optional(list(string), [])
    ingress_cidrs     = optional(list(string), [])
    security_group_id = optional(string, "")
  })
  default     = {}
  description = "Configuration object to deploy a Consul ingress gateway."
}

variable "terminating_gateway" {
  type = object({
    enabled         = optional(bool, false)
    container_image = optional(string, "")
    service_name    = optional(string, "")
  })
  default     = {}
  description = "Configuration object to deploy a Consul terminating gateway."
}

variable "mesh_gateway" {
  type = object({
    enabled           = optional(bool, false)
    container_image   = optional(string, "")
    service_name      = optional(string, "")
    ingress_cidrs     = optional(list(string), [])
    expose_servers    = optional(bool, false)
    internal          = optional(bool, true)
    nlb_address       = optional(string, "")
    security_group_id = optional(string, "")
  })
  default     = {}
  description = "Config object to deploy a mesh gateway."
}

variable "route53_resolver_pool" {
  type = object({
    enabled = optional(bool, false)
  })
  default     = {}
  description = <<DESC
  "Object map that contains the Route53 resolver pool configuration that will be used when creating the endpoints.
  \'lb_arn_suffix\' is required if you do not have the lb_private_ips. The pre-reqs module should output both options for you if you are creating them there
  "
  DESC
}

variable "asg_hook_value" {
  type        = string
  description = "Value for the tag that is associated with the launch template. This is used for the lifecycle hook checkin."
}

variable "ca_bundle_secret_arn" {
  type        = string
  description = "(Required) The ARN of the CA bundle secret in AWS Secrets Manager"
}

variable "cert_secret_arn" {
  type        = string
  description = "(Required) The ARN of the signed certificate secret in AWS Secrets Manager"
}

variable "private_key_secret_arn" {
  type        = string
  description = "(Required) The ARN of the signed certificate secret in AWS Secrets Manager"
}

variable "consul_secrets_arn" {
  type        = string
  description = "(Required) The ARN of the secrets in json format in AWS Secrets Manager"
}

variable "consul_config_directory" {
  type        = string
  description = "Directory on the EC2 instance where the configuration for Consul will be stored."
  default     = "/etc/consul.d"
}

variable "consul_data_directory" {
  type        = string
  description = "(optional) The data directory for the Consul data"
  default     = "/var/lib/consul"
}

variable "consul_systemd_directory" {
  type        = string
  description = "(optional) The directory for the systemd unit"
  default     = "/etc/systemd/system/"
}

variable "consul_additional_config" {
  type        = any
  default     = {}
  description = "Additional config overrides for the Consul agent. Options set here will override those in the default config."
}

variable "autopilot_health_enabled" {
  type        = bool
  default     = true
  description = "Whether autopilot upgrade migration validation is performed for server nodes at boot-time"
}

variable "server_redundancy_zones" {
  type        = bool
  default     = false
  description = "Whether Consul Enterprise Redundancy Zones should be enabled. Requires an even number of server nodes spread across 3+ availability zones."
}

variable "auto_join_tags" {
  type        = map(string)
  description = "Map containing a single tag which will be used by Vault to join other nodes to the cluster. If left blank, the module will use the first entry in `tags`"
  default     = {}
}

variable "packer_image" {
  type        = string
  description = "(optional) The packer image to use"
  default     = null
}


#------------------------------------------------------------------------------
# Network
#------------------------------------------------------------------------------
variable "ec2_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to use for the EC2 instance. Private subnets is the best practice."
}

variable "lb_type" {
  type        = string
  description = "String indicating whether the load balancer deployed is an Application Load Balancer (alb) or Network Load Balancer (nlb)."
  default     = "network"
}

variable "log_forwarding_enabled" {
  type        = bool
  description = "Boolean to enable log forwarding at the OS level."
  default     = false
}

variable "cloudwatch_log_group_name" {
  type        = string
  description = "Name of CloudWatch Log Group to configure as log forwarding destination. `log_forwarding_enabled` must also be `true`."
  default     = ""
}

#------------------------------------------------------------------------------
# Security
#------------------------------------------------------------------------------

variable "launch_template_sg_ids" {
  type        = list(string)
  description = "List of Security Group IDs to associate with the AWS Launch Template"
  default     = []
}

variable "kms_key_arn" {
  type        = string
  description = "ARN of KMS key to use with Consul."
  default     = ""
}

variable "ssh_key_pair" {
  type        = string
  description = "Name of existing SSH key pair to attach to the EC2 instance."
  default     = ""
}

variable "install_docker_before" {
  type        = bool
  description = "Boolean to install docker before Consul install script is called."
  default     = true
}

variable "docker_version" {
  type        = string
  description = "Version of docker to install as a part of the pre-reqs"
  default     = "24.0.4"
}

#------------------------------------------------------------------------------
# Compute
#------------------------------------------------------------------------------
variable "os_distro" {
  type        = string
  description = "Linux OS distribution for the EC2 instance. Choose from `amzn2`, `ubuntu`, `rhel`, `centos`."
  default     = "ubuntu"

  validation {
    condition     = contains(["amzn2", "ubuntu", "rhel", "centos"], var.os_distro)
    error_message = "Supported values are `amzn2`, `ubuntu`, `rhel` or `centos`."
  }
}

variable "asg_instance_count" {
  type        = number
  description = "Desired number of EC2 instances to run in Autoscaling Group."
  default     = 3
}

variable "asg_max_size" {
  type        = number
  description = "Max number of EC2 instances to run in Autoscaling Group."
  default     = 5
}

variable "asg_min_size" {
  type        = number
  description = "Min number of EC2 instances to run in Autoscaling Group."
  default     = 1
}

variable "asg_health_check_grace_period" {
  type        = number
  description = "The amount of time to wait for a new instance to be healthy. If this threshold is breached, the ASG will terminate the instance and launch a new one."
  default     = 900
}

variable "asg_health_check_type" {
  type        = string
  description = "Health check type for the ASG to use when determining if an endpoint is healthy"
  default     = "EC2"
  validation {
    condition     = contains(["ELB", "EC2"], var.asg_health_check_type)
    error_message = "Value must be \"ELB\" or \"EC2\"."
  }
}

variable "asg_capacity_timeout" {
  type        = string
  description = "Maximum duration that Terraform should wait for ASG instances to be healthy before timing out"
  default     = "10m"
}

variable "asg_custom_role_arn" {
  type        = string
  description = "Custom role ARN that will be assigned to the autoscaling group (if specified). Defaults to the AWS native role."
  default     = null
}

variable "ami_id" {
  type        = string
  description = "Custom AMI ID for the EC2 Launch Template. If specified, value of `os_distro` must coincide with this custom AMI OS distro."
  default     = null

  validation {
    condition     = try((length(var.ami_id) > 4 && substr(var.ami_id, 0, 4) == "ami-"), var.ami_id == null)
    error_message = "The ami_id value must start with \"ami-\"."
  }
}

variable "instance_size" {
  type        = string
  description = "EC2 instance type for the Launch Template."
  default     = "m5.large"
}


variable "ebs_volumes" {
  type = object({
    volume_type = optional(string, "io2")
    volume_size = optional(number, 100)
    iops        = optional(number, 5000)
    encrypted   = optional(bool, true)
  })
  description = "Disk parameters to use for the cluster nodes' block devices."
  default     = {}
}


#------------------------------------------------------------------------------
# External Services - RDS
#------------------------------------------------------------------------------

variable "lb_tg_arns" {
  type        = list(any)
  default     = []
  description = "List of Target Group ARNs associated with the Load Balancer"
}

variable "iam_instance_profile_arn" {
  type        = string
  description = "ARN of AWS IAM Instance Profile for the EC2 Instance"
}

variable "skip_install_tools" {
  type        = bool
  description = "(optional) Skips installing required packages (unzip, jq, wget)"
  default     = false
}

# TLS variables
variable "log_path" {
  type        = string
  description = "Log path glob pattern to capture log files with logging agent"
  default     = "/var/log/*"
}

variable "cloudwatch_retention_in_days" {
  type        = number
  description = "Days to retain CloudWatch logs"
  default     = 14
}