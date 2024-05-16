## Public Consul Enterprise single site with an NLB Example

This module showcases an example of utilizing the root module of this repository to build out the following high level components for a Consul Enterprise **5 node** deployment inside of AWS in a **specific region**:  

**Root Module**  
-  AWS Auto Scaling Group
-  AWS Auto Scaling Lifecycle hook
-  AWS Launch Template for ASG
-  AWS Security Group rules for EC2 (if ingress_gateway is specified)
---
## Getting Started

### Dependencies

* Terraform or Terraform Cloud for seeding

### Deployment of Prerequisite AWS Infrastructure  

Note that this module requires specific infrastructure to be available prior to launching.  This includes but is not limited to:

* Load Balancer, Listeners, and Target Groups
* KMS Encryption Keys
* Log Groups for Vault Enterprise
* DNS Record for Vault Enterprise
* S3 buckets
* Secrets Manager Secrets (for License, Consul Tokens,  TLS Certificate, CA Bundle, and Private Key)
* SSH KeyPair for Vault Enterprise (if not using SSM)
* VPC Endpoints (if using Private Networking)
* VPC with internet access 
* EC2 Instance Profile with access to:  
  * Consul Enterprise Snapshot S3 Bucket  
  * Secrets Manager (Consul secrets)
  * Consul Enterprise KMS Keys (EBS Encryption)
  * Consul Enterprise Log Group (Cloudwatch Log Forwarding)
* Security groups with the required ports open for Consul to function. (See public-consul-byo-5-node-sg-nlb example. This uses our security group module to build all of the required rulesets for you.)

If you require any or all of this infrastructure, please refer to our `terraform-aws-consul-prerequisites` module.  This module is designed to create the necessary pre-requisite infrastructure within AWS to prepare for the deployment of Consul on EC2.  

An example of creating the required prerequisite infrastructure for Consul on AWS can be found within the [terraform-aws-consul-prerequisites](https://github.com/hashicorp-modules/terraform-aws-consul-prerequisites/tree/main) module under `/examples/`.  

We are **NOT** building security groups in the deployment module. These need to be provided by the user or you need to utilize the `sg` module.

---

### Executing program

Modify the `terraform.auto.tfvars.example` file with parameters pertinent to your environment and rename it to `terraform.auto.tfvars`.

Once this is updated, authenticate to AWS then run through the standard Terraform Workflow:  

``` hcl
terraform init
terraform plan
terraform apply
```
---

##### Bootstrap the ACL system

Once the cluster is up and running, you can now bootstrap the ACL system. Under the `supplemental-modules` folder, there is an example of bootstrapping the environment using Terraform. You will need the following values to bootstrap the ACL system. 

#### 📝 Note
>By default, we are using the Consul certificates to interact with the API via the module. If you don't have access to the certificates you can change the `providers.tf` file to include `insecure_https = true`. Please see the provider docs [here](https://registry.terraform.io/providers/hashicorp/consul/latest/docs#insecure_https). You can also change the inputs to the module call to have `skip_tls_verify = true` to disable the SSL verification on the API calls with terracurl. 

#### Export method
Here are the bash commands you can run to export the required values in order to use the module.

Notice below that for `TF_VAR_consul_url` you need to supply the url for Consul. This needs to be reachable from where you are running Terraform.

```bash
export TF_VAR_consul_secrets_arn=$(grep "consul_secrets_arn " "terraform.auto.tfvars" | awk -F '=' '{print $2}' | sed 's/^[ \t]*//;s/[ \t]*$//' | tr -d '"')
export AWS_REGION=$(echo $TF_VAR_consul_secrets_arn | awk -F: '{print $4}')
export TF_VAR_consul_url="YOUR-CONSUL-IP-OR-URL:8501"
export TF_VAR_consul_token=$(aws secretsmanager get-secret-value --secret-id $TF_VAR_consul_secrets_arn --region $AWS_REGION | jq -r .SecretString | jq .acl_token.data | {{.SED_CMD}} 's/"//g')
```

Now `cd` into `supplemental-modules/consul-acl-init` and verify the content in `main.tf`. We have the certificates that it will use as static inputs. If you have them somewhere else, please edit them accordingly.

Once you verify everything is all set, just do:

``` hcl
terraform init
terraform plan
terraform apply
```
---

#### Manual method

If you can't (or won't) use the exports, Here is what you need to do
1. `grep "consul_secrets_arn " "terraform.auto.tfvars" | awk -F '=' '{print $2}' | sed 's/^[ \t]*//;s/[ \t]*$//' | tr -d '"'`
2. `aws secretsmanager get-secret-value --secret-id <<YOUR-SECRET-ARN-FROM-STEP-1>> --region <<YOUR-AWS-REGION>> | jq -r .SecretString | jq .acl_token.data | sed 's/"//g'`

This should give you the following information:
```bash
└─ ❯ terraform output -raw consul_secrets_arn
arn:aws:secretsmanager:us-east-2:441170333099:secret:hashicat-c73ded-consul-9hlOof

└─ ❯ aws secretsmanager get-secret-value --secret-id arn:aws:secretsmanager:us-east-2:441170333099:secret:hashicat-c73ded-consul-9hlOof --region us-east-2| jq -r .SecretString | jq .acl_token.data | sed 's/"//g'
1499fc0b-461b-7051-5448-b34b99cccf2e
```

1. Now take these values and `cd` into `supplemental-modules/consul-acl-init` and uncomment the variable values in `terraform.auto.tfvars.example`. 
2. Paste the values you have from above.
3. Fill in the value for `consul_url` 
4. Rename `terraform.auto.tfvars.example` to `terraform.auto.tfvars`
5. Check the certificate paths in `main.tf`. See the note above the section for steps to take if you do not have the certificates. If those are all set do the following: 

``` hcl
terraform init
terraform plan
terraform apply
```
---

#### Retrieve the initial management token
You can login to secrets manager and pull the secret via the UI. If you want to do this in more of an automated manner, you can use the following commands below:


```bash
consul_secrets_arn=$(grep "consul_secrets_arn =" "terraform.auto.tfvars" | awk -F '=' '{print $2}' | sed 's/^[ \t]*//;s/[ \t]*$//' | tr -d '"')
AWS_REGION=$(echo $consul_secrets_arn | awk -F: '{print $4}')
aws secretsmanager get-secret-value --secret-id $consul_secrets_arn --region $AWS_REGION | jq -r .SecretString | jq .acl_token.data | sed 's/"//g'
```

---

## Authors

* Kalen Arndt  
* Sean Doyle  


## Acknowledgments

HashiCorp PS and HashiCorp Engineering have been huge inspirations for this effort

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=4.55.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 4.0.4 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_agent"></a> [agent](#module\_agent) | ../../ | n/a |
| <a name="module_consul"></a> [consul](#module\_consul) | ../../ | n/a |
| <a name="module_tgw"></a> [tgw](#module\_tgw) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_asg_hook_value"></a> [asg\_hook\_value](#input\_asg\_hook\_value) | Value for the tag that is associated with the launch template. This is used for the lifecycle hook checkin. | `string` | n/a | yes |
| <a name="input_ca_bundle_secret_arn"></a> [ca\_bundle\_secret\_arn](#input\_ca\_bundle\_secret\_arn) | ARN of AWS Secrets Manager secret for private/custom CA bundles. New lines must be replaced by `<br>` character prior to storing as a plaintext secret. | `string` | n/a | yes |
| <a name="input_cert_secret_arn"></a> [cert\_secret\_arn](#input\_cert\_secret\_arn) | ARN of AWS Secrets Manager secret for the server certificate in PEM format. | `string` | n/a | yes |
| <a name="input_consul_agent"></a> [consul\_agent](#input\_consul\_agent) | Object map that contains the configuration for the Consul agent that will be deployed on the workloads within the environment. | <pre>object({<br>    container_image               = optional(string, "hashicorp/consul-enterprise:1.16.0-ent")<br>    server                        = optional(bool, false)<br>    domain                        = optional(string, "consul")<br>    datacenter                    = optional(string, "dc1")<br>    primary_datacenter            = optional(string, "dc1")<br>    join_environment              = optional(string, "primary")<br>    ui                            = optional(bool, false)<br>    log_level                     = optional(string, "INFO")<br>    partition                     = optional(string, "")<br>    auto_reload_config            = optional(bool, true)<br>    enable_central_service_config = optional(bool, true)<br>    enable_grpc                   = optional(bool, false)<br>    security_group_id             = string<br>  })</pre> | n/a | yes |
| <a name="input_consul_agent_cluster_version"></a> [consul\_agent\_cluster\_version](#input\_consul\_agent\_cluster\_version) | SemVer version string representing the cluster's deployent iteration. Must always be incremented when deploying updates (e.g. new AMIs, updated launch config) | `string` | n/a | yes |
| <a name="input_consul_agent_environment_name"></a> [consul\_agent\_environment\_name](#input\_consul\_agent\_environment\_name) | Unique environment name to prefix and disambiguate resources using. | `string` | n/a | yes |
| <a name="input_consul_gateway_cluster_version"></a> [consul\_gateway\_cluster\_version](#input\_consul\_gateway\_cluster\_version) | SemVer version string representing the cluster's deployent iteration. Must always be incremented when deploying updates (e.g. new AMIs, updated launch config) | `string` | n/a | yes |
| <a name="input_consul_gateway_environment_name"></a> [consul\_gateway\_environment\_name](#input\_consul\_gateway\_environment\_name) | Unique environment name to prefix and disambiguate resources using. | `string` | n/a | yes |
| <a name="input_consul_secrets_arn"></a> [consul\_secrets\_arn](#input\_consul\_secrets\_arn) | The ARN of the Consul secrets in AWS Secrets Manager | `string` | n/a | yes |
| <a name="input_consul_server_agent"></a> [consul\_server\_agent](#input\_consul\_server\_agent) | Object map that contains the configuration for the Consul agent that will be deployed on the workloads within the environment. | <pre>object({<br>    container_image               = optional(string, "hashicorp/consul-enterprise:1.16.0-ent")<br>    server                        = optional(bool, true)<br>    domain                        = optional(string, "consul")<br>    datacenter                    = optional(string, "dc1")<br>    primary_datacenter            = optional(string, "dc1")<br>    join_environment              = optional(string, "primary")<br>    ui                            = optional(bool, false)<br>    log_level                     = optional(string, "INFO")<br>    partition                     = optional(string, "")<br>    auto_reload_config            = optional(bool, true)<br>    enable_central_service_config = optional(bool, true)<br>    enable_grpc                   = optional(bool, false)<br>    security_group_id             = string<br>  })</pre> | n/a | yes |
| <a name="input_consul_server_cluster_version"></a> [consul\_server\_cluster\_version](#input\_consul\_server\_cluster\_version) | SemVer version string representing the cluster's deployent iteration. Must always be incremented when deploying updates (e.g. new AMIs, updated launch config) | `string` | n/a | yes |
| <a name="input_consul_server_environment_name"></a> [consul\_server\_environment\_name](#input\_consul\_server\_environment\_name) | Unique environment name to prefix and disambiguate resources using. | `string` | n/a | yes |
| <a name="input_ec2_subnet_ids"></a> [ec2\_subnet\_ids](#input\_ec2\_subnet\_ids) | List of subnet IDs to use for the EC2 instance. Private subnets is the best practice. | `list(string)` | n/a | yes |
| <a name="input_friendly_name_prefix"></a> [friendly\_name\_prefix](#input\_friendly\_name\_prefix) | Friendly name prefix used for tagging and naming AWS resources. | `string` | n/a | yes |
| <a name="input_iam_instance_profile_arn"></a> [iam\_instance\_profile\_arn](#input\_iam\_instance\_profile\_arn) | ARN of AWS IAM Instance Profile for the Consul EC2 Instance | `string` | n/a | yes |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN of KMS key to encrypt S3 and  EBS | `string` | n/a | yes |
| <a name="input_lb_tg_arns"></a> [lb\_tg\_arns](#input\_lb\_tg\_arns) | List of Target Group ARNs associated with the Consul Load Balancer | `list(any)` | n/a | yes |
| <a name="input_lb_type"></a> [lb\_type](#input\_lb\_type) | String indicating whether the load balancer deployed is an Application Load Balancer (alb) or Network Load Balancer (nlb). | `string` | n/a | yes |
| <a name="input_private_key_secret_arn"></a> [private\_key\_secret\_arn](#input\_private\_key\_secret\_arn) | ARN of AWS Secrets Manager secret for the private key in PEM format and base64 encoded. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#input\_cloudwatch\_log\_group\_name) | Name of CloudWatch Log Group to configure as log forwarding destination. `log_forwarding_enabled` must also be `true`. | `string` | `""` | no |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Map of common tags for all taggable AWS resources. | `map(string)` | `{}` | no |
| <a name="input_consul_agent_launch_template_sg_ids"></a> [consul\_agent\_launch\_template\_sg\_ids](#input\_consul\_agent\_launch\_template\_sg\_ids) | List of additional Security Group IDs to associate with the AWS Launch Template | `list(string)` | `[]` | no |
| <a name="input_consul_server_launch_template_sg_ids"></a> [consul\_server\_launch\_template\_sg\_ids](#input\_consul\_server\_launch\_template\_sg\_ids) | List of additional Security Group IDs to associate with the AWS Launch Template | `list(string)` | `[]` | no |
| <a name="input_ingress_gateway"></a> [ingress\_gateway](#input\_ingress\_gateway) | Configuration object to deploy a Consul ingress gateway. | <pre>object({<br>    enabled           = optional(bool, false)<br>    container_image   = optional(string, "")<br>    service_name      = optional(string, "")<br>    listener_ports    = optional(list(string), [])<br>    ingress_cidrs     = optional(list(string), [])<br>    security_group_id = optional(string, "")<br>  })</pre> | `{}` | no |
| <a name="input_log_forwarding_enabled"></a> [log\_forwarding\_enabled](#input\_log\_forwarding\_enabled) | Boolean that when true, will enable log forwarding to Cloud Watch | `bool` | `true` | no |
| <a name="input_route53_resolver_pool"></a> [route53\_resolver\_pool](#input\_route53\_resolver\_pool) | "Object map that contains the Route53 resolver pool configuration that will be used when creating the endpoints.<br>  \'consul\_domain\' is utilized for the route53 resolver domain and defaults to `dc1.consul`. Please adjust this domain if you are using a different datacenter or custom domain for Consul.<br>  " | <pre>object({<br>    enabled       = optional(bool, false)<br>    consul_domain = optional(string, "dc1.consul")<br>  })</pre> | `{}` | no |
| <a name="input_snapshot_agent"></a> [snapshot\_agent](#input\_snapshot\_agent) | Configuration object to enable the Consul snapshot agent. | <pre>object({<br>    enabled        = optional(bool, false)<br>    interval       = optional(string, "")<br>    retention      = optional(number, 0)<br>    s3_bucket_name = optional(string, "")<br>  })</pre> | `{}` | no |
| <a name="input_ssh_keypair_name"></a> [ssh\_keypair\_name](#input\_ssh\_keypair\_name) | Name of the SSH public key to associate with the instances. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_server_asg_healthcheck_type"></a> [server\_asg\_healthcheck\_type](#output\_server\_asg\_healthcheck\_type) | Type of health check that is associated with the AWS autoscaling group. |
| <a name="output_server_asg_name"></a> [server\_asg\_name](#output\_server\_asg\_name) | Name of the AWS autoscaling group that was created during the run. |
| <a name="output_server_asg_target_group_arns"></a> [server\_asg\_target\_group\_arns](#output\_server\_asg\_target\_group\_arns) | List of the target group ARNs that are used for the AWS autoscaling group |
| <a name="output_server_launch_template_name"></a> [server\_launch\_template\_name](#output\_server\_launch\_template\_name) | Name of the AWS launch template that was created during the run |
| <a name="output_server_security_group_ids"></a> [server\_security\_group\_ids](#output\_server\_security\_group\_ids) | List of security groups that have been created during the run. |
| <a name="output_server_user_data_script"></a> [server\_user\_data\_script](#output\_server\_user\_data\_script) | base64 decoded user data script that is attached to the launch template |
<!-- END_TF_DOCS -->