#!/bin/bash

# 检查是否以 root 身份运行
if [ "$EUID" -ne 0 ]; then
  echo "请以 root 权限运行此脚本！"
  exit
fi

# 更新系统并安装必要工具
echo "更新系统并安装必要工具..."
#dnf update -y
yum install -y curl wget unzip tar socat yum-utils

# 安装 Trojan-Go
echo "安装 Trojan-Go..."
mkdir -p /etc/trojan-go
TROJAN_GO_VERSION=$(curl -s "https://api.github.com/repos/p4gefau1t/trojan-go/releases/latest" | grep "tag_name" | cut -d '"' -f 4)
wget -q -O trojan-go.zip "https://github.com/p4gefau1t/trojan-go/releases/download/${TROJAN_GO_VERSION}/trojan-go-linux-amd64.zip"
unzip -o trojan-go.zip -d /etc/trojan-go
chmod +x /etc/trojan-go/trojan-go
rm -f trojan-go.zip

# 配置 Trojan-Go
echo "配置 Trojan-Go..."
cat > /etc/trojan-go/config.json << EOF
{
    "run_type": "server",
    "local_addr": "127.0.0.1",
    "local_port": 12345,
    "remote_addr": "127.0.0.1",
    "remote_port": 80,
    "password": [
        "Aa505814."
    ],
    "websocket": {
        "enabled": true,
        "path": "/ws",
        "host": "sv.aninja.cc"
    }
}
EOF

# 配置 Trojan-Go 为系统服务
echo "配置 Trojan-Go 服务..."
cat > /etc/systemd/system/trojan-go.service << EOF
[Unit]
Description=Trojan-Go Service
After=network.target

[Service]
Type=simple
ExecStart=/etc/trojan-go/trojan-go -config /etc/trojan-go/config.json
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# 安装 Caddy
echo "安装 Caddy..."
# 下载最新版本 Caddy
curl -o caddy.tar.gz -L "https://github.com/caddyserver/caddy/releases/download/v2.7.4/caddy_2.7.4_linux_amd64.tar.gz"

# 解压文件
tar -zxvf caddy.tar.gz

# 将 Caddy 移动到系统路径
sudo mv caddy /usr/local/bin/

# 赋予执行权限
sudo chmod +x /usr/local/bin/caddy


sudo mkdir -p /etc/caddy
sudo touch /etc/caddy/Caddyfile

# 配置 Caddyfile
echo "配置 Caddyfile..."
cat > /etc/caddy/Caddyfile << EOF
:80 {
    respond "Hello World" 200
}
sv.aninja.cc {
    respond "Hello World"
    tls einined@gmail.com

    reverse_proxy 127.0.0.1:12345
}
EOF

# 配置防火墙
#echo "配置防火墙..."
#firewall-cmd --permanent --add-service=http
#firewall-cmd --permanent --add-service=https
#firewall-cmd --reload

# 启动 Trojan-Go 和 Caddy
echo "启动 Trojan-Go 和 Caddy 服务..."
systemctl daemon-reload
systemctl enable trojan-go
systemctl start trojan-go
systemctl enable caddy
systemctl start caddy

# 检查服务状态
echo "检查服务状态..."
systemctl status trojan-go
systemctl status caddy

echo "Caddy 和 Trojan-Go 部署完成！"
echo "确保域名已解析到本服务器，并在客户端配置中使用以下信息："
echo "  域名: your-domain.com"
echo "  密码: your-password"
echo "  WebSocket 路径: /ws"
echo "  端口: 443"