variable "consul_token" {
  description = "Consul token to use when making the API requests"
  type        = string
}

variable "consul_url" {
  description = "URL for the Consul Cluster to bootstrap the ACLs"
  type        = string
}

variable "consul_secrets_arn" {
  description = "ARN of the Secrets Manager Secret that contains the Consul tokens."
  type        = string
}