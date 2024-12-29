#!/bin/bash

# 检查是否以 root 身份运行
if [ "$EUID" -ne 0 ]; then
  echo "请以 root 权限运行脚本！"
  exit
fi

# 更新系统并安装必要工具
echo "更新系统并安装必要工具..."
#dnf update -y
yum install wget curl unzip socat -y

# 创建 Trojan-Go 工作目录
echo "创建 Trojan-Go 工作目录..."
mkdir -p /etc/trojan-go && cd /etc/trojan-go

# 下载 Trojan-Go 最新版本
echo "下载 Trojan-Go..."
TROJAN_GO_VERSION=$(curl -s "https://api.github.com/repos/p4gefau1t/trojan-go/releases/latest" | grep "tag_name" | cut -d '"' -f 4)
wget -q -O trojan-go.zip "https://github.com/p4gefau1t/trojan-go/releases/download/${TROJAN_GO_VERSION}/trojan-go-linux-amd64.zip"

# 解压文件并设置权限
unzip -o trojan-go.zip && rm -f trojan-go.zip
chmod +x trojan-go

# 创建 Trojan-Go 配置文件
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
        "sni": "sv.aninja.cc",
        "alpn": ["h2", "http/1.1"]
    },
    "websocket": {
        "enabled": true,
        "path": "/ws",
        "host": "sv.aninja.cc"
    },
    "tcp": {
      "enabled": true
    }
}
EOF

# 配置 Trojan-Go 为系统服务
echo "配置 Trojan-Go 为系统服务..."
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

# 安装 acme.sh 并申请 SSL 证书
echo "申请 SSL 证书..."
curl https://get.acme.sh | sh
~/.acme.sh/acme.sh --register-account -m einined@gmail.com
~/.acme.sh/acme.sh --issue --standalone -d sv.aninja.cc --force
~/.acme.sh/acme.sh --install-cert -d sv.aninja.cc \
    --key-file /etc/trojan-go/privkey.pem \
    --fullchain-file /etc/trojan-go/fullchain.pem

# 启动 Trojan-Go 服务
echo "启动 Trojan-Go 服务..."
systemctl daemon-reload
systemctl enable trojan-go
systemctl start trojan-go
systemctl stop trojan-go
echo "Trojan-Go 部署完成！请确保域名已解析到本服务器，并在配置文件中正确设置了域名和密码。"
