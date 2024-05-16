provider "consul" {
  datacenter = "dc1"
  address    = var.consul_url
  token      = var.consul_token
  scheme     = "https"
  ca_file    = "../../consul-agent-ca.pem"
}

provider "aws" {
}
