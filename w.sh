MY_PORT=12345
MY_EMAIL="einined@gmail.com"
MY_DOMAIN="la.aninja.cc"
MY_PASSWORD="Aa505814."

echo "创建 Trojan-Go 配置文件..."
cat > /etc/trojan-go/config.json << EOF
{
    "run_type": "server",
    "local_addr": "0.0.0.0",
    "local_port": 12345,
    "remote_addr": "127.0.0.1",
    "remote_port": 443,
    "password": [
        "Aa505814."
    ],
    "ssl": {
        "cert": "/etc/trojan-go/fullchain.pem",
        "key": "/etc/trojan-go/privkey.pem",
        "sni": "la.aninja.cc",
        "fallback_addr":"127.0.0.1",
        "fallback_port": 443
    },
    "websocket": {
        "enabled": true,
        "path": "/ws"
    }
}
EOF