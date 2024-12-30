cat > /etc/systemd/system/caddy.service << EOF
[Unit]
Description=Caddy Service
After=network.target

[Service]
Type=simple
Environment="MY_DOMAIN=la.aninja.cc"
ExecStart=caddy start
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

