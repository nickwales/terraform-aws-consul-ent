locals {
  install_cloud_cli_tools_func = templatefile("${path.module}/templates/functions/${var.cloud}/install_cloud_cli_tools.func", {
    cloud                           = var.cloud
    airgap_install                  = var.product == "tfe" ? var.airgap_install : false
    pkg_repos_reachable_with_airgap = var.product == "tfe" ? var.pkg_repos_reachable_with_airgap : false
    log_forwarding_enabled          = var.log_forwarding_enabled
    cloud_logs_cfg                  = local.cloud_logs_cfg
  })

  cloud_logs_cfg = var.log_forwarding_enabled ? templatefile("${path.module}/templates/files/cloud_logs_cfg.tmpl", {
    log_path                     = var.log_path
    cloudwatch_log_group_name    = var.cloudwatch_log_group_name
    cloudwatch_retention_in_days = var.cloudwatch_retention_in_days
  }) : null

  scrape_vm_info_func = templatefile("${path.module}/templates/functions/${var.cloud}/scrape_vm_info.func", {
  })

  retrieve_file_from_obj_func = templatefile("${path.module}/templates/functions/${var.cloud}/retrieve_file_from_obj.func", {
  })

  install_dependencies = templatefile("${path.module}/templates/functions/install_dependencies.func", {
    cloud                           = var.cloud
    product                         = var.product
    airgap_install                  = var.product == "tfe" ? var.airgap_install : false
    pkg_repos_reachable_with_airgap = var.product == "tfe" ? var.pkg_repos_reachable_with_airgap : false
    docker_version                  = var.docker_version
    install_docker_before           = contains(["tfe", "tfefdo", "consul"], var.product) ? var.install_docker_before : (var.product == "tfe" && var.airgap_install ? var.airgap_install : false)
  })

  get_secrets_func = templatefile("${path.module}/templates/functions/${var.cloud}/get_secrets.func", {
  })

  helpers_func = templatefile("${path.module}/templates/functions/helpers.func", {
    product = var.product
  })

  exit_script_func = templatefile("${path.module}/templates/functions/${var.cloud}/exit_script.func", {
  })

  final_render = templatefile("${path.module}/templates/files/output_object.tmpl", {
    scrape_vm_info_func          = local.scrape_vm_info_func
    retrieve_file_from_obj_func  = local.retrieve_file_from_obj_func
    install_dependencies_func    = local.install_dependencies
    get_secrets_func             = local.get_secrets_func
    exit_script_func             = local.exit_script_func
    helpers_func                 = local.helpers_func
    install_cloud_cli_tools_func = local.install_cloud_cli_tools_func
  })
}
