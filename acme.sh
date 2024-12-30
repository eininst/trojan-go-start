#!/bin/bash

MY_EMAIL="einined@gmail.com"
MY_DOMAIN="$1"
current_dir=$(pwd)


echo "申请 SSL 证书..."
curl https://get.acme.sh | sh
~/.acme.sh/acme.sh --register-account -m ${MY_EMAIL}
~/.acme.sh/acme.sh --issue --standalone -d ${MY_DOMAIN} --force

~/.acme.sh/acme.sh --install-cert -d ${MY_DOMAIN} \
  --key-file /etc/trojan-go/privkey.pem \
  --fullchain-file /etc/trojan-go/fullchain.pem \
  --reloadcmd "systemctl restart trojan-go"


echo "export MY_DOMAIN=$MY_DOMAIN" >> ~/.bashrc
echo "export MY_EMAIL=$MY_EMAIL" >> ~/.bashrc
source ~/.bashrc