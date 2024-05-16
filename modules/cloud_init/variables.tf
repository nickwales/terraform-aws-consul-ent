variable "cloud" {
  type        = string
  description = "Name of the cloud we are provisioning on. This is used for templating functions and is default to AWS for this module."
  default     = "aws"
}

variable "product" {
  type        = string
  description = "Name of the HashiCorp product that will consume this service (tfe, tfefdo, vault, consul, nomad, boundary)"
  validation {
    condition     = contains(["tfe", "tfefdo", "vault", "consul", "boundary", "nomad"], var.product)
    error_message = "`var.product` must be \"tfe\", \"tfefdo\", \"vault\", \"consul\", \"nomad\", or \"boundary\"."
  }
}

variable "docker_version" {
  type        = string
  description = "Version of docker to install as a part of the pre-reqs"
  default     = "24.0.4"
}

variable "airgap_install" {
  type        = bool
  description = "TFE ONLY - Boolean for TFE installation method to be airgap."
  default     = false
}

variable "pkg_repos_reachable_with_airgap" {
  type        = bool
  description = "TFE ONLY - Boolean to install prereq software dependencies if airgapped. Only valid when `airgap_install` is `true`."
  default     = false
}

variable "install_docker_before" {
  type        = bool
  description = "TFE ONLY - Boolean to install docker before TFE install script is called."
  default     = false
}

variable "log_path" {
  type        = string
  description = "Log path glob pattern to capture log files with logging agent"
  default     = "/var/log/*"
}

variable "cloudwatch_log_group_name" {
  type        = string
  description = "Log Group name in CloudWatch to send logs to"
  default     = "foo"
}

variable "cloudwatch_retention_in_days" {
  type        = number
  description = "Days to retain CloudWatch logs"
  default     = 14
}

variable "log_forwarding_enabled" {
  type        = bool
  description = "Forward logs to a log destination"
  default     = false
}
