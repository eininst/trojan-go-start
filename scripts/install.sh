#!/bin/bash

MY_DOMAIN="$1"
current_dir=$(pwd)

# 检查是否以 root 身份运行
if [ "$EUID" -ne 0 ]; then
  echo "请以 root 权限运行脚本！"
  exit
fi

# 更新系统并安装必要工具
echo "更新系统并安装必要工具..."
#dnf update -y
yum install wget curl unzip tar socat yum-utils make -y

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

# 配置 Trojan-Go 为系统服务
echo "配置 Trojan-Go 为系统服务..."
cat > /etc/systemd/system/trojan-go.service << EOF
[Unit]
Description=Trojan-Go Service
After=network.target

[Service]
Type=simple
ExecStart=/etc/trojan-go/trojan-go -config ${current_dir}/configs/${MY_DOMAIN}.json
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

sudo rm -rf /etc/trojan-go/caddy.tar.gz

echo "export MY_DOMAIN=$MY_DOMAIN" >> ~/.bashrc
echo "export MY_EMAIL=$MY_EMAIL" >> ~/.bashrc
source ~/.bashrc

sh ${current_dir}/scripts/acme.sh ${MY_DOMAIN}

systemctl daemon-reload


echo "安装完成！请确保域名已解析到本服务器"