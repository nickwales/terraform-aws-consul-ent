module "acl_init" {
  source             = "../../../../act_init"
  consul_token       = var.consul_token
  consul_url         = var.consul_url
  consul_secrets_arn = var.consul_secrets_arn
  consul_ca_file     = "../../consul-agent-ca.pem"
  consul_cert_file   = "../../consul-server-public.pem"
  consul_key_file    = "../../consul-server-private.pem"
}