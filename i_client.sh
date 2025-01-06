#!/bin/bash

# 检查是否以 root 身份运行
if [ "$EUID" -ne 0 ]; then
  echo "请以 root 权限运行脚本！"
  exit 1
fi

current_dir=$(pwd)


# 请输入域名
while true; do
    read -p "$(echo -e "\033[36m请输入域名：\033[0m")" MY_DOMAIN
    if [ -z "$MY_DOMAIN" ]; then
        echo "域名不能为空，请重新输入！"
    else
        break  # 如果输入有效，跳出循环
    fi
done

read -p "$(echo -e "\033[36m请输入密码（默认值为 admin123）：\033[0m")" PASSWORD
PASSWORD=${PASSWORD:-admin123}

read -p "$(echo -e "\033[36m请输入端口（默认值为 443）：\033[0m")" PORT
PORT=${PORT:-443}



echo "下载 Trojan-Go..."
wget -q -O trojan-go https://fastworks.oss-rg-china-mainland.aliyuncs.com/trojan-go-linux-amd64
chmod +x trojan-go

echo "创建 Trojan-Go 配置文件..."
cat > ${current_dir}/config.json << EOF
{
  "run_type": "client",
  "local_addr": "127.0.0.1",
  "local_port": 7080,
  "remote_addr": "${MY_DOMAIN}",
  "remote_port": ${PORT},
  "password": ["${PASSWORD}"]
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
ExecStart=${current_dir}/trojan-go -config ${current_dir}/config.json
WorkingDirectory=${current_dir}
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable trojan-go


echo "alias start='systemctl start trojan-go'" >> ~/.bashrc
echo "alias stop='systemctl stop trojan-go'" >> ~/.bashrc
echo "alias log='journalctl -u trojan-go -f'" >> ~/.bashrc
echo "alias run='${current_dir}/trojan-go ${current_dir}/client.json'" >> ~/.bashrc
echo "alias restart='systemctl restart trojan-go'" >> ~/.bashrc

echo "alias proxy='export https_proxy=http://127.0.0.1:${PORT} http_proxy=http://127.0.0.1:${PORT} all_proxy=socks5://127.0.0.1:${PORT}'" >> ~/.bashrc
echo "alias show_proxy='echo $https_proxy && echo $http_proxy && echo $ALL_PROXY'"  >> ~/.bashrc
echo "alias noproxy='unset https_proxy && unset http_proxy && unset ALL_PROXY'" >> ~/.bashrc


source ~/.bashrc

printf "Trojan-go客户端安装完成！\n"