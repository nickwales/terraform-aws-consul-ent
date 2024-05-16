
function install_ingress_gateway {
%{ if ingress_gateway.enabled ~}
cat - <<"EOF" > /var/lib/${product}/ingress-gateway.run
#!/usr/bin/env bash
set -euo pipefail
REGION="$(curl -s http://169.254.169.254/latest/meta-data/placement/region)"
INGRESS_GATEWAY_TOKEN=$(aws secretsmanager get-secret-value --secret-id "${consul_secrets_arn}" --region "$REGION" 2>/dev/null | jq -r '.SecretString | fromjson.ingress_gw_token.data')
/usr/bin/docker rm -f ${product}-ingress-gateway 2> /dev/null || true
/usr/bin/docker run \
  --rm \
  --net host \
  --env CONSUL_HTTP_ADDR=https://127.0.0.1:8501 \
  --env CONSUL_HTTP_SSL_VERIFY=false \
  "${consul_agent.container_image}" ${product} connect envoy \
  -gateway=ingress \
  -register \
  -service "${ingress_gateway.service_name}" \
  -address "{{ ds.meta_data.local_ipv4 }}:31000" \
  -token "$INGRESS_GATEWAY_TOKEN" \
  -bootstrap | \
/usr/bin/docker run --name ${product}-ingress-gateway \
  --net host \
  "${ingress_gateway.container_image}" envoy \
  --base-id 0 \
  --config-yaml "$(cat -)"
EOF

chmod 0770 /var/lib/${product}/ingress-gateway.run
systemctl daemon-reload && systemctl enable --now ${product}@ingress-gateway
%{ else ~}
echo "Ingress gateway disabled - skipping configuration."
%{ endif ~}
}
