variable "region" {
  type        = string
  description = "AWS Region"
}

variable "friendly_name_prefix" {
  type        = string
  description = "Friendly name prefix used for tagging and naming AWS resources."
}

variable "common_tags" {
  type        = map(string)
  description = "Map of common tags for all taggable AWS resources."
  default     = {}
}
#------------------------------------------------------------------------------
# Networking
#------------------------------------------------------------------------------
variable "ec2_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to use for the EC2 instance. Private subnets is the best practice."
}

variable "route53_resolver_pool" {
  type = object({
    enabled       = optional(bool, false)
    consul_domain = optional(string, "dc1.consul")
  })
  default     = {}
  description = <<DESC
  "Object map that contains the Route53 resolver pool configuration that will be used when creating the endpoints.
  \'consul_domain\' is utilized for the route53 resolver domain and defaults to `dc1.consul`. Please adjust this domain if you are using a different datacenter or custom domain for Consul.
  "
  DESC
}

variable "consul_server_launch_template_sg_ids" {
  type        = list(string)
  description = "List of additional Security Group IDs to associate with the AWS Launch Template"
  default     = []
}


variable "consul_agent_launch_template_sg_ids" {
  type        = list(string)
  description = "List of additional Security Group IDs to associate with the AWS Launch Template"
  default     = []
}

#------------------------------------------------------------------------------
# Loadbalancing
#------------------------------------------------------------------------------
variable "lb_type" {
  type        = string
  description = "String indicating whether the load balancer deployed is an Application Load Balancer (alb) or Network Load Balancer (nlb)."
}

variable "lb_tg_arns" {
  type        = list(any)
  description = "List of Target Group ARNs associated with the Consul Load Balancer"
}

#------------------------------------------------------------------------------
# Secret Manager
#------------------------------------------------------------------------------

variable "cert_secret_arn" {
  type        = string
  description = "ARN of AWS Secrets Manager secret for the server certificate in PEM format."
}

variable "ca_bundle_secret_arn" {
  type        = string
  description = "ARN of AWS Secrets Manager secret for private/custom CA bundles. New lines must be replaced by `\n` character prior to storing as a plaintext secret."
}

variable "private_key_secret_arn" {
  type        = string
  description = "ARN of AWS Secrets Manager secret for the private key in PEM format and base64 encoded."
}

variable "consul_secrets_arn" {
  type        = string
  description = "The ARN of the Consul secrets in AWS Secrets Manager"
}

#------------------------------------------------------------------------------
# Consul Configuration
#------------------------------------------------------------------------------

variable "consul_agent_cluster_version" {
  type        = string
  description = "SemVer version string representing the cluster's deployent iteration. Must always be incremented when deploying updates (e.g. new AMIs, updated launch config)"
}

variable "consul_agent_environment_name" {
  type        = string
  description = "Unique environment name to prefix and disambiguate resources using."
}

variable "consul_gateway_cluster_version" {
  type        = string
  description = "SemVer version string representing the cluster's deployent iteration. Must always be incremented when deploying updates (e.g. new AMIs, updated launch config)"
}

variable "consul_gateway_environment_name" {
  type        = string
  description = "Unique environment name to prefix and disambiguate resources using."
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

variable "consul_server_agent" {
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

variable "consul_agent" {
  type = object({
    container_image               = optional(string, "hashicorp/consul-enterprise:1.16.0-ent")
    server                        = optional(bool, false)
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

variable "consul_server_cluster_version" {
  type        = string
  description = "SemVer version string representing the cluster's deployent iteration. Must always be incremented when deploying updates (e.g. new AMIs, updated launch config)"
}

variable "consul_server_environment_name" {
  type        = string
  description = "Unique environment name to prefix and disambiguate resources using."
}

variable "ssh_keypair_name" {
  type        = string
  description = "Name of the SSH public key to associate with the instances."
  default     = null
}

variable "asg_hook_value" {
  type        = string
  description = "Value for the tag that is associated with the launch template. This is used for the lifecycle hook checkin."
}


#------------------------------------------------------------------------------
# KMS
#------------------------------------------------------------------------------

variable "kms_key_arn" {
  type        = string
  description = "ARN of KMS key to encrypt S3 and  EBS"
}

#------------------------------------------------------------------------------
# IAM
#------------------------------------------------------------------------------

variable "iam_instance_profile_arn" {
  type        = string
  description = "ARN of AWS IAM Instance Profile for the Consul EC2 Instance"
}

#------------------------------------------------------------------------------
# Logging
#------------------------------------------------------------------------------

variable "cloudwatch_log_group_name" {
  type        = string
  description = "Name of CloudWatch Log Group to configure as log forwarding destination. `log_forwarding_enabled` must also be `true`."
  default     = ""
}

variable "log_forwarding_enabled" {
  type        = bool
  description = "Boolean that when true, will enable log forwarding to Cloud Watch"
  default     = true
}
