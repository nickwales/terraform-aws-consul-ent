function install_mesh_gateway {
%{ if mesh_gateway.enabled ~}
cat - <<"EOF" > /var/lib/${product}/mesh-gateway.run
#!/usr/bin/env bash
set -euo pipefail
REGION="$(curl -s http://169.254.169.254/latest/meta-data/placement/region)"
MESH_GATEWAY_TOKEN=$(aws secretsmanager get-secret-value --secret-id "${consul_secrets_arn}" --region "$REGION" 2>/dev/null | jq -r '.SecretString | fromjson.mesh_gw_token.data')
/usr/bin/docker rm -f ${product}-mesh-gateway 2> /dev/null || true
/usr/bin/docker run \
  --rm \
  --net host \
  --env CONSUL_HTTP_ADDR=https://127.0.0.1:8501 \
  --env CONSUL_HTTP_SSL_VERIFY=false \
  "${consul_agent.container_image}" ${product} connect envoy \
  -gateway=mesh \
  -register \
  -service "${mesh_gateway.service_name}" \
  -address "{{ ds.meta_data.local_ipv4 }}:8443" \
  -wan-address "${nlb_address}:443" \
  %{ if mesh_gateway.expose_servers }-expose-servers%{ endif } \
  -admin-bind "127.0.0.1:19002" \
  -token "$MESH_GATEWAY_TOKEN" \
  -bootstrap | \
/usr/bin/docker run --name ${product}-mesh-gateway \
  --net host \
  "${mesh_gateway.container_image}" envoy \
  --base-id 2 \
  --config-yaml "$(cat -)"
EOF

chmod 0770 /var/lib/${product}/mesh-gateway.run
systemctl daemon-reload && systemctl enable --now ${product}@mesh-gateway
%{ else ~}
echo "Mesh gateway diabled - skipping configuration."
%{ endif ~}
}