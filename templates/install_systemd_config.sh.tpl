function install_systemd_unit {
cat - <<EOF > /etc/systemd/system/${product}@.service
[Unit]
Description="Consul Agent"

After=network-online.target docker.service
Requires=docker.service

[Service]
LimitNOFILE=65535
ExecStart=/usr/bin/env /var/lib/${product}/%i.run
ExecStop=-/usr/bin/docker stop ${product}-%i
KillMode=none
Restart=on-failure
RestartSec=15s
TimeoutStartSec=120
TimeoutStopSec=120

[Install]
WantedBy=network-online.target
EOF

BIND_INT=$(ip route | grep default | awk '{print $5}')
cat - <<EOF > /var/lib/${product}/agent.run
#!/usr/bin/env bash
set -eu
/usr/bin/docker rm -f ${product}-agent 2> /dev/null || true
/usr/bin/docker run \\
  --name ${product}-agent \\
  --net "host" \\
  --env "CONSUL_BIND_INTERFACE=$BIND_INT" \\
  --mount "type=bind,src=/var/lib/${product},dst=/${product}/data" \\
  --mount "type=bind,src=/etc/${product}.d,dst=/${product}/config" \\
  "${consul_agent.container_image}" agent
EOF

chmod 0770 /var/lib/${product}/agent.run
systemctl daemon-reload && systemctl enable --now ${product}@agent

}