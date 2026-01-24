#!/bin/bash

# 快速配置国内服务器 Docker 镜像加速器
echo "配置 Docker 镜像加速器..."

# 创建目录
sudo mkdir -p /etc/docker

# 写入配置
sudo tee /etc/docker/daemon.json > /dev/null <<'EOF'
{
  "registry-mirrors": [
    "https://mirror.ccs.tencentyun.com",
    "https://registry.docker-cn.com",
    "https://docker.mirrors.ustc.edu.cn"
  ]
}
EOF

# 重启 Docker
sudo systemctl daemon-reload
sudo systemctl restart docker

echo "Docker 镜像加速器配置完成！"
echo "现在可以运行 bash deploy.sh 了"