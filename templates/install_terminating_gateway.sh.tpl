function install_terminating_gateway {
%{ if terminating_gateway.enabled ~}
cat - <<"EOF" > /var/lib/${product}/terminating-gateway.run
#!/usr/bin/env bash
set -euo pipefail
REGION="$(curl -s http://169.254.169.254/latest/meta-data/placement/region)"
TERMINATING_GATEWAY_TOKEN=$(aws secretsmanager get-secret-value --secret-id "${consul_secrets_arn}" --region "$REGION" 2>/dev/null | jq -r '.SecretString | fromjson.terminating_gw_token.data')
/usr/bin/docker rm -f ${product}-terminating-gateway 2> /dev/null || true
/usr/bin/docker run \
  --rm \
  --net host \
  --env CONSUL_HTTP_ADDR=https://127.0.0.1:8501 \
  --env CONSUL_HTTP_SSL_VERIFY=false \
  "${consul_agent.container_image}" ${product} connect envoy \
  -gateway=terminating \
  -register \
  -service "${terminating_gateway.service_name}" \
  -address "{{ ds.meta_data.local_ipv4 }}:21000" \
  -admin-bind "127.0.0.1:19001" \
  -token "$TERMINATING_GATEWAY_TOKEN" \
  -bootstrap | \
/usr/bin/docker run --name ${product}-terminating-gateway \
  --net host \
  "${terminating_gateway.container_image}" envoy \
  --base-id 1 \
  --config-yaml "$(cat -)"
EOF

chmod 0770 /var/lib/${product}/terminating-gateway.run
systemctl daemon-reload && systemctl enable --now ${product}@terminating-gateway
%{ else ~}
echo "Terminating gateway disabled - skipping configuration."
%{ endif ~}
}
