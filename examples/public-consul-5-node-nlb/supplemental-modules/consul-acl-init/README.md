# consul-acl-init

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
README.md updated successfully
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.4.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=4.55.0 |
| <a name="requirement_consul"></a> [consul](#requirement\_consul) | >= 2.18.0 |
| <a name="requirement_terracurl"></a> [terracurl](#requirement\_terracurl) | >=1.1.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acl_init"></a> [acl\_init](#module\_acl\_init) | github.com/hashicorp-modules/terraform-aws-consul-acl-init | v1.0.1 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_consul_secrets_arn"></a> [consul\_secrets\_arn](#input\_consul\_secrets\_arn) | ARN of the Secrets Manager Secret that contains the Consul tokens. | `string` | n/a | yes |
| <a name="input_consul_token"></a> [consul\_token](#input\_consul\_token) | Consul token to use when making the API requests | `string` | n/a | yes |
| <a name="input_consul_url"></a> [consul\_url](#input\_consul\_url) | URL for the Consul Cluster to bootstrap the ACLs | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->