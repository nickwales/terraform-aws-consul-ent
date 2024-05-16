output "user_data_script" {
  value       = data.cloudinit_config.cinit.rendered
  description = "base64 decoded user data script that is attached to the launch template"
}

output "launch_template_name" {
  value       = aws_launch_template.lt.name
  description = "Name of the AWS launch template that was created during the run"
}

output "asg_name" {
  value       = aws_autoscaling_group.asg.name
  description = "Name of the AWS autoscaling group that was created during the run."
}

output "asg_healthcheck_type" {
  value       = aws_autoscaling_group.asg.health_check_type
  description = "Type of health check that is associated with the AWS autoscaling group."
}

output "asg_target_group_arns" {
  value       = aws_autoscaling_group.asg.target_group_arns
  description = "List of the target group ARNs that are used for the AWS autoscaling group"
}

output "join_environment" {
  value       = try(local.user_data_args.consul_agent.join_environment, null)
  description = "Join environment that should be used for joining an existing Consul cluster"
}