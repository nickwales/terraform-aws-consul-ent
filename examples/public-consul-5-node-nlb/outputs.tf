
#------------------------------------------------------------------------------
# Consul Server Outputs
#------------------------------------------------------------------------------
output "server_user_data_script" {
  value       = try(module.consul.user_data_script, null)
  description = "base64 decoded user data script that is attached to the launch template"
}

output "server_launch_template_name" {
  value       = try(module.consul.launch_template_name, null)
  description = "Name of the AWS launch template that was created during the run"
}

output "server_asg_name" {
  value       = try(module.consul.asg_name, null)
  description = "Name of the AWS autoscaling group that was created during the run."
}

output "server_asg_healthcheck_type" {
  value       = try(module.consul.asg_healthcheck_type, null)
  description = "Type of health check that is associated with the AWS autoscaling group."
}

output "server_asg_target_group_arns" {
  value       = try(module.consul.asg_target_group_arns, null)
  description = "List of the target group ARNs that are used for the AWS autoscaling group"
}

output "server_security_group_ids" {
  value       = try(module.consul.security_group_ids, null)
  description = "List of security groups that have been created during the run."
}

