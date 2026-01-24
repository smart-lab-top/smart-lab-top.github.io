#!/bin/bash

# smart-lab 网站一键部署脚本
# 使用方法：在服务器上运行 bash deploy.sh
# 前提：服务器已安装 Docker 和 Git

# 配置变量
REPO_URL="https://github.com/your-username/your-repo-name.git"  # 替换为你的 GitHub 仓库 URL
PROJECT_DIR="smart-lab"
IMAGE_NAME="smart-lab-site"
CONTAINER_NAME="smart-lab-container"
PORT="8080"

echo "开始部署 smart-lab 网站..."

# 检查项目目录是否存在
if [ ! -d "$PROJECT_DIR" ]; then
    echo "克隆仓库..."
    git clone "$REPO_URL" "$PROJECT_DIR"
else
    echo "更新代码..."
    cd "$PROJECT_DIR"
    git pull origin main  # 假设默认分支是 main
    cd ..
fi

# 进入项目目录
cd "$PROJECT_DIR"

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
docker run -d -p "$PORT":4000 --name "$CONTAINER_NAME" "$IMAGE_NAME"

# 检查容器状态
if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
    echo "部署成功！网站运行在 http://localhost:$PORT"
    echo "如果需要外部访问，请确保防火墙允许端口 $PORT"
else
    echo "部署失败，请检查日志："
    docker logs "$CONTAINER_NAME"
    exit 1
fi

echo "部署完成。"