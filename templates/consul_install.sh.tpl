## template: jinja
#! /bin/bash
set -euo pipefail

CONFIG_DIRECTORY="${config_directory}"
LICENSE_DIRECTORY="$CONFIG_DIRECTORY/license"
TLS_DIRECTORY="$CONFIG_DIRECTORY/tls"
DATA_DIRECTORY="${data_directory}"
LOGFILE="/var/log/${product}-cloud-init.log"
REQUIRED_PACKAGES="jq wget curl unzip"
PRODUCT_USER=100
PRODUCT_GROUP=1000
PRODUCT_HOME_DIRECTORY="${config_directory}"
# Product Specific
LICENSE_PATH="$LICENSE_DIRECTORY/${product}.hclic"
CONSUL_TLSPUBLIC_PATH="$TLS_DIRECTORY/consul-server-public.pem"
CONSUL_TLSPRIVATE_PATH="$TLS_DIRECTORY/consul-server-private.pem"
CONSUL_TLSCABUNDLE_PATH="$TLS_DIRECTORY/consul-agent-ca.pem"
SYSTEMD_DIRECTORY="${consul_systemd_directory}"
ENABLED_SERVICES=""

${general_cloudinit_funcs}

function fetch_tls_certificates {
  log "[INFO] Fetching TLS certificates..."
  # Retrieve CA certificate
  get_secrets ${ca_bundle_secret_arn} > $CONSUL_TLSCABUNDLE_PATH
  get_secrets ${cert_secret_arn} > $CONSUL_TLSPUBLIC_PATH
  get_secrets ${private_key_secret_arn} > $CONSUL_TLSPRIVATE_PATH
  chmod 400 $TLS_DIRECTORY/*
  chown $PRODUCT_USER:$PRODUCT_GROUP $TLS_DIRECTORY/*
  log "[INFO] Done fetching TLS certificates."
}

function fetch_${product}_license {
  log "[INFO] Retreiving ${product} license..."
  get_secrets "${consul_secrets_arn}" | jq .license.data | tr -d '"' > $LICENSE_PATH
  chmod 400 $LICENSE_PATH
  chown $PRODUCT_USER:$PRODUCT_GROUP $LICENSE_PATH
}

function fetch_${product}_tokens {
  log "[INFO] [Consul Enterprise] Retrieving Agent Token."
  AGENT_TOKEN=$(get_secrets "${consul_secrets_arn}" | jq .agent_token.data | tr -d '"')

  log "[INFO] [Consul Enterprise] Retrieving Gossip key."
  GOSSIP_KEY=$(get_secrets "${consul_secrets_arn}" | jq .gossip_key.data | tr -d '"')

  log "[INFO] [Consul Enterprise] Retrieving Replication Token."
  REPLICATION_TOKEN=$(get_secrets "${consul_secrets_arn}" | jq .replication_token.data)

  log "[INFO] [Consul Enterprise] Retrieving Snapshot Token."
  SNAPSHOT_TOKEN=$(get_secrets "${consul_secrets_arn}" | jq .snapshot_token.data)

  log "[INFO] [Consul Enterprise] Retrieving Initial Management Token."
  ACL_TOKEN=$(get_secrets "${consul_secrets_arn}" | jq .acl_token.data | tr -d '"')
}

function generate_${product}_config {
  cat - <<EOF > "$CONFIG_DIRECTORY/${product}.json"
${consul_agent_data}
EOF
}

function user_group_create {
  log "[INFO] Creating consul user and group..."
  if getent group "$PRODUCT_GROUP" &>/dev/null; then
    log "[INFO] Group exists...skipping creation"
  else
    groupadd --system "$PRODUCT_GROUP"
  fi
  if id "$PRODUCT_USER" &>/dev/null; then
    log "[INFO] User exists...skipping creation"
  else
    useradd --system -m -d "$PRODUCT_HOME_DIRECTORY" -g "$PRODUCT_GROUP" "$PRODUCT_USER"
  fi
}

function directory_create {
  log "[INFO] Creating necessary directories..."
  directories=( $PRODUCT_HOME_DIRECTORY $DATA_DIRECTORY $TLS_DIRECTORY $LICENSE_DIRECTORY)
  for directory in "$${directories[@]}"; do
    if [[ ! -d $directory ]]; then
      mkdir -p $directory
      chown $PRODUCT_USER:$PRODUCT_GROUP $directory
      echo "Created $directory"
    else
      echo "$directory exists...skipping"
    fi
  done
}

function check_server_health {
  max_retries=30
  retry_interval=10
  retry_count=0

  while [ $retry_count -lt $max_retries ]; do
    if curl -ksfS --connect-timeout $retry_interval -o /dev/null "https://$EC2_PRIVATE_IP:8501/v1/catalog/service/consul" -H "X-Consul-Token: $ACL_TOKEN"; then
      echo
      echo "Consul service is healthy."
      exit_script 0
    else
      echo
      echo "Service check failed. Retrying in $retry_interval seconds..."
      sleep $retry_interval
      retry_count=$((retry_count + 1))
    fi
  done

  if [ $retry_count -eq $max_retries ]; then
      echo "Service check failed after $max_retries retries. Exiting."
      exit_script 1
  fi
}

function check_agent_health {
  if systemctl is-active --quiet consul@agent; then
    log "Consul Agent is running"
    exit_script 0
  else
    log "Consul Agent is not running"
    exit_script 1
  fi
}

${install_ingress_gateway}

${install_mesh_gateway}

${install_snapshot_agent}

${install_systemd_config}

${install_terminating_gateway}

function main {
  scrape_vm_info
%{ if !skip_install_tools ~}
  install_dependencies
%{ endif ~}
  install_cloud_cli_tools
  user_group_create
  directory_create
  fetch_${product}_license
  fetch_${product}_tokens
  fetch_tls_certificates

  # Product Specific
  generate_${product}_config
  install_systemd_unit
  install_ingress_gateway
  install_mesh_gateway
  install_terminating_gateway
  install_snapshot_agent
%{ if consul_agent.server }
  check_server_health
%{ else }
  check_agent_health
%{ endif }
}

main "$@"