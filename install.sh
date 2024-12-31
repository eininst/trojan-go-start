#!/bin/bash

# 检查是否以 root 身份运行
if [ "$EUID" -ne 0 ]; then
  echo "请以 root 权限运行脚本！"
  exit
fi

current_dir=$(pwd)

# 请输入域名
while true; do
    read -p "请输入域名：" MY_DOMAIN
    if [ -z "$MY_DOMAIN" ]; then
        echo "域名不能为空，请重新输入！"
    else
        break  # 如果输入有效，跳出循环
    fi
done


read -p "请输入邮箱（默认值为 example@gmail.com）：" MY_EMAIL
MY_EMAIL=${MY_EMAIL:-example@gmail.com}

read -p "请输入密码（默认值为 admin123）：" PASSWORD
PASSWORD=${PASSWORD:-admin123}

read -p "请输入端口（默认值为 12345）：" PORT
PORT=${PORT:-12345}


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
cp trojan-go ${current_dir}

# 配置 Trojan-Go 为系统服务
echo "配置 Trojan-Go 为系统服务..."
cat > /etc/systemd/system/trojan-go.service << EOF
[Unit]
Description=Trojan-Go Service
After=network.target

[Service]
Type=simple
ExecStart=${current_dir}/trojan-go
WorkingDirectory=${current_dir}
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF


echo "创建 Trojan-Go 配置文件..."
cat > ${current_dir}/config.json << EOF
{
  "run_type": "server",
  "local_addr": "0.0.0.0",
  "local_port": ${PORT},
  "remote_addr": "127.0.0.1",
  "remote_port": 443,
  "password": [
    "${PASSWORD}"
  ],
  "ssl": {
    "cert": "${current_dir}/fullchain.pem",
    "key": "${current_dir}/privkey.pem",
    "sni": "",
    "fallback_port": 443,
    "fallback_addr": "127.0.0.1"
  },
  "websocket": {
    "enabled": true,
    "path": "/ws"
  }
}
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

echo "创建 Caddyfile 配置文件..."
cat > ${current_dir}/Caddyfile << EOF
:80 {
    respond "Hello World" 200
}

:443 {
    tls ${current_dir}/fullchain.pem ${current_dir}/privkey.pem
    respond "Hello World SSL 443" 200
}

$MY_DOMAIN {
    tls ${current_dir}/fullchain.pem ${current_dir}/privkey.pem
    respond "Hello World SSL $MY_DOMAIN" 200
}
EOF


systemctl daemon-reload
systemctl enable trojan-go


echo "申请 SSL 证书..."
curl https://get.acme.sh | sh
~/.acme.sh/acme.sh --register-account -m ${MY_EMAIL}
~/.acme.sh/acme.sh --issue --standalone -d ${MY_DOMAIN} --force

~/.acme.sh/acme.sh --install-cert -d ${MY_DOMAIN} \
  --key-file ${current_dir}/privkey.pem \
  --fullchain-file ${current_dir}/fullchain.pem \
  --reloadcmd "systemctl restart trojan-go"

crontab -l


echo "alias start='caddy start && systemctl start trojan-go'" >> ~/.bashrc

echo "alias stop='systemctl stop trojan-go && caddy stop'" >> ~/.bashrc

echo "alias tlog='journalctl -u trojan-go -f'" >> ~/.bashrc

echo "alias clog='journalctl -u caddy -f'" >> ~/.bashrc

echo "alias trun='${current_dir}/trojan-go'" >> ~/.bashrc

echo "alias tstart='systemctl start trojan-go'" >> ~/.bashrc

echo "alias trestart='systemctl restart trojan-go'" >> ~/.bashrc

echo "alias tstop='systemctl stop trojan-go'" >> ~/.bashrc

echo "export MY_DOMAIN=$MY_DOMAIN" >> ~/.bashrc
echo "export MY_EMAIL=$MY_EMAIL" >> ~/.bashrc
echo "export SSL_CERT=${current_dir}/fullchain.pem" >> ~/.bashrc
echo "export SSL_KEY=${current_dir}/privkey.pem" >> ~/.bashrc

echo 'alias help=\"printf "\033[32m %-5s \033[0m|  %-10s\n" "start" "启动caddy和trojan-go" &&
             printf "\033[32m %-5s \033[0m|  %-10s\n" "stop" "停止caddy和trojan-go" &&
             printf "\033[32m %-5s \033[0m|  %-10s\n" "tlog" "查看trojan-go运行日志" &&
             printf "\033[32m %-5s \033[0m|  %-10s\n" "clog" "查看caddy运行日志" &&
             printf "\033[32m %-5s \033[0m|  %-10s\n" "caddy start" "运行caddy " &&
             printf "\033[32m %-5s \033[0m|  %-10s\n" "caddy stop" "停止caddy" &&
             printf "\033[32m %-5s \033[0m|  %-10s\n" "caddy reload" "重启caddy" &&
             printf "\033[32m %-5s \033[0m|  %-10s\n" "tstart" "运行trojan-go" &&
             printf "\033[32m %-5s \033[0m|  %-10s\n" "tstop" "停止trojan-go" &&
             printf "\033[32m %-5s \033[0m|  %-10s\n" "trestart" "重启trojan-go"\"' >> ~/.bashrc


source ~/.bashrc
bash -i -c "source ~/.bashrc"


echo "安装完成！请确保域名已解析到本服务器"

help

echo "The built-in command needs to take effect immediately in this session. Please execute: \033[32msource ~/.bashrc\033[0m"



