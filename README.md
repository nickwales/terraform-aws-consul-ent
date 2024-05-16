# Consul on AWS Deployment Module

This Terraform module is intended to deploy Consul Enterprise on AWS. Every environment is different, and so this module may not be all-encompassing for every situation.

---

## Purpose
These modules are currently for [hyper-specialized tier partners](https://www.hashicorp.com/partners/find-a-partner?category=systems-integrators), internal use, and HashiCorp Professional Services. Please reach out in #team-ent-deployment-modules if you want to use this with your customers.
Each example has a README with instructions and additional information, please refer to them prior to use.

## Usage
Take a look at the examples folder. Select and exmaple that works for your deployment

1. Rename the `terraform.auto.tfvars.example` to `terraform.auto.tfvars`
2. Modify the `terraform.auto.tfvars` file to be specific to your environment
3. `terraform init`
4. `terraform plan`
5. `terraform apply`

An overview of the module architecture is provided in [LucidChart](https://lucid.app/lucidchart/9bf9c5f3-cfbf-4262-9990-f965fb7a138d/edit?invitationId=inv_56f1eba4-910f-418a-97e6-5ff4036db164&page=0_0) .

Each example has a README with instructions and additional information, please refer to those prior to execution

## Support
Please be aware that HashiCorp does not provide official support for the deployment modules. Product-level support falls within the scope of your support package, the module code itself does not include any support or guarantee.

---

# 📝 Note
If you don't have the prerequisites created, please see the other repository for the examples that focus on the deployment of the prerequisites required for the product.

| Example | Description |
| ------- | ----------- |
| [private-consul-5-node-route53-nlb](https://github.com/hashicorp-modules/terraform-aws-consul-prerequisites/tree/main/examples/private-consul-5-node-route53-nlb)  | Builds all prerequisite infrastructure with an NLB, Route53 resolver, in private subnets. |
| [public-consul-5-node-nlb](https://github.com/hashicorp-modules/terraform-aws-consul-prerequisites/tree/main/examples/public-consul-5-node-nlb)  | Builds all prerequisite infrastructure with a public NLB |
| [public-consul-byo-sg-5-node-nlb](https://github.com/hashicorp-modules/terraform-aws-consul-prerequisites/tree/main/examples/public-consul-5-node-nlb)  | Use the public-consul-5-node-nlb example |
--- 
 
## 📂 Example scenarios and structure

The Git repository contains the following directories under `examples` and should be used as references when consuming the module

```sh
📁 examples                                                # Root example folder
# ├─📁 hvd-consul                                          # Waiting on HVD team
├─📁 private-consul-5-node-route53-nlb                     # Deployment of a private 5 node Consul cluster with snapshot agents, and an ASG for example agents with an NLB 
├─📁 public-consul-5-node-nlb                              # Deployment of a public 5 node Consul cluster with snapshot agents,example agent ASG, and Ingress Gateway ASG, with an NLB
├─📁 public-consul-byo-sg-5-node-nlb                       # Deployment of a public 5 node Consul cluster with snapshot agents,example agent ASG, and Ingress Gateway ASG, with an NLB
                                                           # This builds the security groups and rules as a part of the example instead of the prereqs
```

---

## Submodules in use:

- [terraform-null-cloudinit-function-template](https://github.com/hashicorp-modules/terraform-null-cloudinit-function-template)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.22.0 |
| <a name="requirement_cloudinit"></a> [cloudinit](#requirement\_cloudinit) | >= 2.2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.22.0 |
| <a name="provider_cloudinit"></a> [cloudinit](#provider\_cloudinit) | >= 2.2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloud_init"></a> [cloud\_init](#module\_cloud\_init) | github.com/hashicorp-modules/terraform-null-cloudinit-function-template | v0.2.0 |

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.asg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_launch_template.lt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_security_group_rule.ingress_gw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_ami.centos](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ami.ubuntu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_subnet.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [cloudinit_config.cinit](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_asg_hook_value"></a> [asg\_hook\_value](#input\_asg\_hook\_value) | Value for the tag that is associated with the launch template. This is used for the lifecycle hook checkin. | `string` | n/a | yes |
| <a name="input_ca_bundle_secret_arn"></a> [ca\_bundle\_secret\_arn](#input\_ca\_bundle\_secret\_arn) | (Required) The ARN of the CA bundle secret in AWS Secrets Manager | `string` | n/a | yes |
| <a name="input_cert_secret_arn"></a> [cert\_secret\_arn](#input\_cert\_secret\_arn) | (Required) The ARN of the signed certificate secret in AWS Secrets Manager | `string` | n/a | yes |
| <a name="input_consul_agent"></a> [consul\_agent](#input\_consul\_agent) | Object map that contains the configuration for the Consul agent that will be deployed on the workloads within the environment. | <pre>object({<br>    container_image               = optional(string, "hashicorp/consul-enterprise:1.16.0-ent")<br>    server                        = optional(bool, true)<br>    domain                        = optional(string, "consul")<br>    datacenter                    = optional(string, "dc1")<br>    primary_datacenter            = optional(string, "dc1")<br>    join_environment              = optional(string, "primary")<br>    ui                            = optional(bool, false)<br>    log_level                     = optional(string, "INFO")<br>    partition                     = optional(string, "")<br>    auto_reload_config            = optional(bool, true)<br>    enable_central_service_config = optional(bool, true)<br>    enable_grpc                   = optional(bool, false)<br>    security_group_id             = string<br>  })</pre> | n/a | yes |
| <a name="input_consul_cluster_version"></a> [consul\_cluster\_version](#input\_consul\_cluster\_version) | SemVer version string representing the cluster's deployent iteration. Must always be incremented when deploying updates (e.g. new AMIs, updated launch config) | `string` | n/a | yes |
| <a name="input_consul_secrets_arn"></a> [consul\_secrets\_arn](#input\_consul\_secrets\_arn) | (Required) The ARN of the secrets in json format in AWS Secrets Manager | `string` | n/a | yes |
| <a name="input_ec2_subnet_ids"></a> [ec2\_subnet\_ids](#input\_ec2\_subnet\_ids) | List of subnet IDs to use for the EC2 instance. Private subnets is the best practice. | `list(string)` | n/a | yes |
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | Unique environment name to prefix and disambiguate resources using. | `string` | n/a | yes |
| <a name="input_friendly_name_prefix"></a> [friendly\_name\_prefix](#input\_friendly\_name\_prefix) | String value for friendly name prefix for AWS resource names. | `string` | n/a | yes |
| <a name="input_iam_instance_profile_arn"></a> [iam\_instance\_profile\_arn](#input\_iam\_instance\_profile\_arn) | ARN of AWS IAM Instance Profile for the EC2 Instance | `string` | n/a | yes |
| <a name="input_private_key_secret_arn"></a> [private\_key\_secret\_arn](#input\_private\_key\_secret\_arn) | (Required) The ARN of the signed certificate secret in AWS Secrets Manager | `string` | n/a | yes |
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | Custom AMI ID for the EC2 Launch Template. If specified, value of `os_distro` must coincide with this custom AMI OS distro. | `string` | `null` | no |
| <a name="input_asg_capacity_timeout"></a> [asg\_capacity\_timeout](#input\_asg\_capacity\_timeout) | Maximum duration that Terraform should wait for ASG instances to be healthy before timing out | `string` | `"10m"` | no |
| <a name="input_asg_custom_role_arn"></a> [asg\_custom\_role\_arn](#input\_asg\_custom\_role\_arn) | Custom role ARN that will be assigned to the autoscaling group (if specified). Defaults to the AWS native role. | `string` | `null` | no |
| <a name="input_asg_health_check_grace_period"></a> [asg\_health\_check\_grace\_period](#input\_asg\_health\_check\_grace\_period) | The amount of time to wait for a new instance to be healthy. If this threshold is breached, the ASG will terminate the instance and launch a new one. | `number` | `900` | no |
| <a name="input_asg_health_check_type"></a> [asg\_health\_check\_type](#input\_asg\_health\_check\_type) | Health check type for the ASG to use when determining if an endpoint is healthy | `string` | `"EC2"` | no |
| <a name="input_asg_instance_count"></a> [asg\_instance\_count](#input\_asg\_instance\_count) | Desired number of EC2 instances to run in Autoscaling Group. | `number` | `3` | no |
| <a name="input_asg_max_size"></a> [asg\_max\_size](#input\_asg\_max\_size) | Max number of EC2 instances to run in Autoscaling Group. | `number` | `5` | no |
| <a name="input_asg_min_size"></a> [asg\_min\_size](#input\_asg\_min\_size) | Min number of EC2 instances to run in Autoscaling Group. | `number` | `1` | no |
| <a name="input_auto_join_tags"></a> [auto\_join\_tags](#input\_auto\_join\_tags) | Map containing a single tag which will be used by Vault to join other nodes to the cluster. If left blank, the module will use the first entry in `tags` | `map(string)` | `{}` | no |
| <a name="input_autopilot_health_enabled"></a> [autopilot\_health\_enabled](#input\_autopilot\_health\_enabled) | Whether autopilot upgrade migration validation is performed for server nodes at boot-time | `bool` | `true` | no |
| <a name="input_cloud"></a> [cloud](#input\_cloud) | Name of the cloud we are provisioning on. This is used for templating functions and is default to AWS for this module. | `string` | `"aws"` | no |
| <a name="input_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#input\_cloudwatch\_log\_group\_name) | Name of CloudWatch Log Group to configure as log forwarding destination. `log_forwarding_enabled` must also be `true`. | `string` | `""` | no |
| <a name="input_cloudwatch_retention_in_days"></a> [cloudwatch\_retention\_in\_days](#input\_cloudwatch\_retention\_in\_days) | Days to retain CloudWatch logs | `number` | `14` | no |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Map of common tags for taggable AWS resources. | `map(string)` | `{}` | no |
| <a name="input_consul_additional_config"></a> [consul\_additional\_config](#input\_consul\_additional\_config) | Additional config overrides for the Consul agent. Options set here will override those in the default config. | `any` | `{}` | no |
| <a name="input_consul_config_directory"></a> [consul\_config\_directory](#input\_consul\_config\_directory) | Directory on the EC2 instance where the configuration for Consul will be stored. | `string` | `"/etc/consul.d"` | no |
| <a name="input_consul_data_directory"></a> [consul\_data\_directory](#input\_consul\_data\_directory) | (optional) The data directory for the Consul data | `string` | `"/var/lib/consul"` | no |
| <a name="input_consul_systemd_directory"></a> [consul\_systemd\_directory](#input\_consul\_systemd\_directory) | (optional) The directory for the systemd unit | `string` | `"/etc/systemd/system/"` | no |
| <a name="input_docker_version"></a> [docker\_version](#input\_docker\_version) | Version of docker to install as a part of the pre-reqs | `string` | `"24.0.4"` | no |
| <a name="input_ebs_volumes"></a> [ebs\_volumes](#input\_ebs\_volumes) | Disk parameters to use for the cluster nodes' block devices. | <pre>object({<br>    volume_type = optional(string, "io2")<br>    volume_size = optional(number, 100)<br>    iops        = optional(number, 5000)<br>    encrypted   = optional(bool, true)<br>  })</pre> | `{}` | no |
| <a name="input_ingress_gateway"></a> [ingress\_gateway](#input\_ingress\_gateway) | Configuration object to deploy a Consul ingress gateway. | <pre>object({<br>    enabled           = optional(bool, false)<br>    container_image   = optional(string, "")<br>    service_name      = optional(string, "")<br>    listener_ports    = optional(list(string), [])<br>    ingress_cidrs     = optional(list(string), [])<br>    security_group_id = optional(string, "")<br>  })</pre> | `{}` | no |
| <a name="input_install_docker_before"></a> [install\_docker\_before](#input\_install\_docker\_before) | Boolean to install docker before Consul install script is called. | `bool` | `true` | no |
| <a name="input_instance_size"></a> [instance\_size](#input\_instance\_size) | EC2 instance type for the Launch Template. | `string` | `"m5.large"` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN of KMS key to use with Consul. | `string` | `""` | no |
| <a name="input_launch_template_sg_ids"></a> [launch\_template\_sg\_ids](#input\_launch\_template\_sg\_ids) | List of Security Group IDs to associate with the AWS Launch Template | `list(string)` | `[]` | no |
| <a name="input_lb_tg_arns"></a> [lb\_tg\_arns](#input\_lb\_tg\_arns) | List of Target Group ARNs associated with the Load Balancer | `list(any)` | `[]` | no |
| <a name="input_lb_type"></a> [lb\_type](#input\_lb\_type) | String indicating whether the load balancer deployed is an Application Load Balancer (alb) or Network Load Balancer (nlb). | `string` | `"network"` | no |
| <a name="input_log_forwarding_enabled"></a> [log\_forwarding\_enabled](#input\_log\_forwarding\_enabled) | Boolean to enable log forwarding at the OS level. | `bool` | `false` | no |
| <a name="input_log_path"></a> [log\_path](#input\_log\_path) | Log path glob pattern to capture log files with logging agent | `string` | `"/var/log/*"` | no |
| <a name="input_mesh_gateway"></a> [mesh\_gateway](#input\_mesh\_gateway) | Config object to deploy a mesh gateway. | <pre>object({<br>    enabled           = optional(bool, false)<br>    container_image   = optional(string, "")<br>    service_name      = optional(string, "")<br>    ingress_cidrs     = optional(list(string), [])<br>    expose_servers    = optional(bool, false)<br>    internal          = optional(bool, true)<br>    nlb_address       = optional(string, "")<br>    security_group_id = optional(string, "")<br>  })</pre> | `{}` | no |
| <a name="input_os_distro"></a> [os\_distro](#input\_os\_distro) | Linux OS distribution for the EC2 instance. Choose from `amzn2`, `ubuntu`, `rhel`, `centos`. | `string` | `"ubuntu"` | no |
| <a name="input_packer_image"></a> [packer\_image](#input\_packer\_image) | (optional) The packer image to use | `string` | `null` | no |
| <a name="input_product"></a> [product](#input\_product) | Name of the HashiCorp product that will be installed (tfe, vault, consul) | `string` | `"consul"` | no |
| <a name="input_route53_resolver_pool"></a> [route53\_resolver\_pool](#input\_route53\_resolver\_pool) | "Object map that contains the Route53 resolver pool configuration that will be used when creating the endpoints.<br>  \'lb\_arn\_suffix\' is required if you do not have the lb\_private\_ips. The pre-reqs module should output both options for you if you are creating them there<br>  " | <pre>object({<br>    enabled = optional(bool, false)<br>  })</pre> | `{}` | no |
| <a name="input_server_redundancy_zones"></a> [server\_redundancy\_zones](#input\_server\_redundancy\_zones) | Whether Consul Enterprise Redundancy Zones should be enabled. Requires an even number of server nodes spread across 3+ availability zones. | `bool` | `false` | no |
| <a name="input_skip_install_tools"></a> [skip\_install\_tools](#input\_skip\_install\_tools) | (optional) Skips installing required packages (unzip, jq, wget) | `bool` | `false` | no |
| <a name="input_snapshot_agent"></a> [snapshot\_agent](#input\_snapshot\_agent) | Configuration object to enable the Consul snapshot agent. | <pre>object({<br>    enabled        = optional(bool, false)<br>    interval       = optional(string, "")<br>    retention      = optional(number, 0)<br>    s3_bucket_name = optional(string, "")<br>  })</pre> | `{}` | no |
| <a name="input_ssh_key_pair"></a> [ssh\_key\_pair](#input\_ssh\_key\_pair) | Name of existing SSH key pair to attach to the EC2 instance. | `string` | `""` | no |
| <a name="input_terminating_gateway"></a> [terminating\_gateway](#input\_terminating\_gateway) | Configuration object to deploy a Consul terminating gateway. | <pre>object({<br>    enabled         = optional(bool, false)<br>    container_image = optional(string, "")<br>    service_name    = optional(string, "")<br>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_asg_healthcheck_type"></a> [asg\_healthcheck\_type](#output\_asg\_healthcheck\_type) | Type of health check that is associated with the AWS autoscaling group. |
| <a name="output_asg_name"></a> [asg\_name](#output\_asg\_name) | Name of the AWS autoscaling group that was created during the run. |
| <a name="output_asg_target_group_arns"></a> [asg\_target\_group\_arns](#output\_asg\_target\_group\_arns) | List of the target group ARNs that are used for the AWS autoscaling group |
| <a name="output_join_environment"></a> [join\_environment](#output\_join\_environment) | Join environment that should be used for joining an existing Consul cluster |
| <a name="output_launch_template_name"></a> [launch\_template\_name](#output\_launch\_template\_name) | Name of the AWS launch template that was created during the run |
| <a name="output_user_data_script"></a> [user\_data\_script](#output\_user\_data\_script) | base64 decoded user data script that is attached to the launch template |
<!-- END_TF_DOCS -->