#!/bin/bash
# 更新系统
#sudo yum update -y
# 安装依赖包
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
# 添加 Docker 官方仓库
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
# 安装 Docker
sudo yum install -y docker-ce docker-ce-cli containerd.io
# 启动 Docker 服务并设置开机启动
sudo systemctl start docker
sudo systemctl enable docker
# 检查 Docker 版本
docker --version
# 测试 Docker 是否正常工作
sudo docker run hello-world
