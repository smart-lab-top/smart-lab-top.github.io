#!/bin/bash

IMAGE_NAME="smart-lab-site"
CONTAINER_NAME="smart-lab-container"
PORT="8080"

echo "开始部署 smart-lab 网站..."

# 1. 更新代码
git config --global filter.lfs.clean ''
git config --global filter.lfs.smudge ''
git config --global filter.lfs.process ''
git pull origin main

# 2. 配置 Docker 镜像加速器 (针对中国环境优化)
echo "更新 Docker 镜像加速器..."
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "registry-mirrors": [
    "https://dockerproxy.net",
    "https://docker.m.daocloud.io",
    "https://docker.udayun.com",
    "https://docker.anyhub.us.kg",
    "https://dockerhub.jobcher.com"
  ]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
sleep 3

# 3. 清理旧容器
echo "清理旧容器..."
docker stop "$CONTAINER_NAME" 2>/dev/null || true
docker rm "$CONTAINER_NAME" 2>/dev/null || true

# 4. 构建镜像 (添加重试逻辑)
echo "构建 Docker 镜像..."
MAX_RETRIES=3
COUNT=0
while [ $COUNT -lt $MAX_RETRIES ]; do
    if docker build -t "$IMAGE_NAME" .; then
        echo "镜像构建成功！"
        break
    else
        COUNT=$((COUNT + 1))
        echo "构建失败，重试 ($COUNT/$MAX_RETRIES)..."
        sleep 5
    fi
    if [ $COUNT -eq $MAX_RETRIES ]; then
        echo "错误：镜像构建多次失败，请检查网络。"
        exit 1
    fi
done

# 5. 启动容器
echo "启动容器..."
docker run -d \
    -p "$PORT":4000 \
    -v "$(pwd)":/srv/jekyll \
    --name "$CONTAINER_NAME" \
    --restart unless-stopped \
    "$IMAGE_NAME"

# 6. 验证
sleep 5
if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
    echo "------------------------------------------------"
    echo "部署成功！"
    echo "网站地址: http://47.93.91.76:$PORT"
    echo "日志查看: docker logs -f $CONTAINER_NAME"
    echo "------------------------------------------------"
else
    echo "部署失败，详情请看日志："
    docker logs "$CONTAINER_NAME"
    exit 1
fi