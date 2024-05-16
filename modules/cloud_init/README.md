# terraform-null-cloudinit-function-template

## Purpose
These modules are currently for [hyper-specialized tier partners](https://www.hashicorp.com/partners/find-a-partner?category=systems-integrators), internal use, and HashiCorp Implementation Services. Please reach out in #team-ent-deployment-modules if you want to use this with your customers.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_product"></a> [product](#input\_product) | Name of the HashiCorp product that will consume this service (tfe, tfefdo, vault, consul, nomad, boundary) | `string` | n/a | yes |
| <a name="input_airgap_install"></a> [airgap\_install](#input\_airgap\_install) | TFE ONLY - Boolean for TFE installation method to be airgap. | `bool` | `false` | no |
| <a name="input_cloud"></a> [cloud](#input\_cloud) | Name of the cloud we are provisioning on. This is used for templating functions and is default to AWS for this module. | `string` | `"aws"` | no |
| <a name="input_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#input\_cloudwatch\_log\_group\_name) | Log Group name in CloudWatch to send logs to | `string` | `"foo"` | no |
| <a name="input_cloudwatch_retention_in_days"></a> [cloudwatch\_retention\_in\_days](#input\_cloudwatch\_retention\_in\_days) | Days to retain CloudWatch logs | `number` | `14` | no |
| <a name="input_docker_version"></a> [docker\_version](#input\_docker\_version) | Version of docker to install as a part of the pre-reqs | `string` | `"24.0.4"` | no |
| <a name="input_install_docker_before"></a> [install\_docker\_before](#input\_install\_docker\_before) | TFE ONLY - Boolean to install docker before TFE install script is called. | `bool` | `false` | no |
| <a name="input_log_forwarding_enabled"></a> [log\_forwarding\_enabled](#input\_log\_forwarding\_enabled) | Forward logs to a log destination | `bool` | `false` | no |
| <a name="input_log_path"></a> [log\_path](#input\_log\_path) | Log path glob pattern to capture log files with logging agent | `string` | `"/var/log/*"` | no |
| <a name="input_pkg_repos_reachable_with_airgap"></a> [pkg\_repos\_reachable\_with\_airgap](#input\_pkg\_repos\_reachable\_with\_airgap) | TFE ONLY - Boolean to install prereq software dependencies if airgapped. Only valid when `airgap_install` is `true`. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_template_output"></a> [template\_output](#output\_template\_output) | Final render of the templated output based on the input variables. |
<!-- END_TF_DOCS -->
