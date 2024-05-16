function install_snapshot_agent {
%{ if snapshot_agent.enabled ~}
mkdir -p /etc/${product}-snapshot.d
cat - <<EOF > /etc/${product}-snapshot.d/${product}-snapshot.json
{
  "snapshot_agent": {
    "http_addr": "https://127.0.0.1:8501",
    "ca_file": "/${product}/config/tls/${product}-agent-ca.pem",
    "token": $${SNAPSHOT_TOKEN},
    "snapshot": {
      "interval": "${snapshot_agent.interval}",
      "retain": ${snapshot_agent.retention},
      "deregister_after": "8h"
    },
    "aws_storage": {
      "s3_region": "${aws_region.name}",
      "s3_bucket": "${snapshot_agent.s3_bucket_name}"
    }
  }
}
EOF

cat - <<EOF > /var/lib/${product}/snapshot-agent.run
#!/usr/bin/env bash
set -eu
/usr/bin/docker rm -f ${product}-snapshot-agent 2> /dev/null || true
/usr/bin/docker run --name ${product}-snapshot-agent \\
  --net "host" \\
  --mount "type=bind,src=/etc/${product}-snapshot.d,dst=/snapshot/config" \\
  --mount "type=bind,src=/etc/${product}.d,dst=/${product}/config" \\
  "${consul_agent.container_image}" snapshot agent -config-dir "/snapshot/config"
EOF

chmod 0770 /var/lib/${product}/snapshot-agent.run

systemctl daemon-reload && systemctl enable --now ${product}@snapshot-agent

%{ else ~}
echo "Snapshot agent disabled - skipping configuration."
%{ endif ~}
}

