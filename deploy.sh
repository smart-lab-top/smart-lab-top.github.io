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

# 检查 docker-compose 或 docker compose 是否可用
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
elif docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
else
    echo "错误：未找到 docker-compose 或 docker compose。请先安装 Docker Compose。"
    exit 1
fi

echo "使用命令: $COMPOSE_CMD"

# 停止并移除旧容器（如果存在）
echo "停止并清理旧容器..."
$COMPOSE_CMD down 2>/dev/null || true

# 构建新镜像
echo "构建 Docker 镜像..."
$COMPOSE_CMD build --no-cache

# 启动新容器
echo "启动容器..."
$COMPOSE_CMD up -d

# 检查容器状态
sleep 5  # 等待容器启动
if [ "$($COMPOSE_CMD ps -q)" ]; then
    echo "部署成功！网站运行在 http://localhost:$PORT"
    echo "如果需要外部访问，请确保防火墙允许端口 $PORT"
    echo "查看容器日志: $COMPOSE_CMD logs -f"
else
    echo "部署失败，请检查日志："
    $COMPOSE_CMD logs
    exit 1
fi

echo "部署完成。"