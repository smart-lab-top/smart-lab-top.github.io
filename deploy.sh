#!/bin/bash

# smart-lab 网站一键部署脚本
# 使用方法：在服务器上运行 bash deploy.sh
# 前提：服务器已安装 Docker 和 Git

# 配置变量
IMAGE_NAME="smart-lab-site"
CONTAINER_NAME="smart-lab-container"
PORT="8080"

echo "开始部署 smart-lab 网站..."

# 更新代码，假设脚本在项目根目录运行
git pull origin main  # 更新代码，假设默认分支是 main

# 检查 Docker 是否配置了镜像加速器
if [ ! -f "/etc/docker/daemon.json" ]; then
    echo "警告：未检测到 Docker 镜像加速器配置，建议先配置以加速下载。"
    echo "请运行以下命令配置阿里云加速器："
    echo "sudo mkdir -p /etc/docker"
    echo "sudo tee /etc/docker/daemon.json > /dev/null <<EOF"
    echo "{"
    echo "  \"registry-mirrors\": [\"https://your-id.mirror.aliyuncs.com\"]"
    echo "}"
    echo "EOF"
    echo "sudo systemctl daemon-reload"
    echo "sudo systemctl restart docker"
    echo ""
    echo "请将 your-id 替换为你的阿里云加速器 ID，然后重新运行 deploy.sh"
    exit 1
fi

# 停止并移除旧容器（如果存在）
echo "停止并清理旧容器..."
docker stop "$CONTAINER_NAME" 2>/dev/null || true
docker rm "$CONTAINER_NAME" 2>/dev/null || true

# 移除旧镜像（可选，避免占用空间）
docker rmi "$IMAGE_NAME" 2>/dev/null || true

# 构建新镜像
echo "构建 Docker 镜像..."
docker build -t "$IMAGE_NAME" .

# 运行新容器
echo "启动容器..."
docker run -d \
    -p "$PORT":4000 \
    -v "$(pwd)":/srv/jekyll \
    --name "$CONTAINER_NAME" \
    "$IMAGE_NAME"

# 检查容器状态
if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
    echo "部署成功！网站运行在 http://localhost:$PORT"
    echo "如果需要外部访问，请确保防火墙允许端口 $PORT"
    echo "查看容器日志: docker logs -f $CONTAINER_NAME"
else
    echo "部署失败，请检查日志："
    docker logs "$CONTAINER_NAME"
    exit 1
fi

echo "部署完成。"