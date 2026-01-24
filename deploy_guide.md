# 网站部署指南 (Deploy Guide)

## 概述

本文档详细说明如何在服务器上使用 Docker 部署 smart-lab 网站。smart-lab 是一个基于 al-folio 主题的 Jekyll 网站，支持多种功能如博客、项目展示等。本指南涵盖从代码推送 GitHub 到服务器部署、端口管理、自动同步和域名绑定的完整流程。

## 准备工作

### 1. GitHub 仓库
- 创建一个 GitHub 账户（如果没有）。
- 创建新的仓库：
  - 访问 [GitHub](https://github.com) 并点击 "New repository"。
  - 填写仓库名称（如 `my-academic-website`）。
  - 选择公开（Public）或私有（Private）仓库。

**私有仓库 vs 公共仓库的区别：**
- **公共仓库**：任何人都可以查看代码，适合开源项目，无需认证即可克隆。
- **私有仓库**：只有授权用户可以访问，需要 SSH 密钥或个人访问令牌（PAT）进行认证。适合保护敏感信息或私人项目。
- 对于部署而言，两种类型都可以使用，但私有仓库更安全。部署过程基本相同，只是在克隆时需要提供认证。

### 2. 服务器环境
- 确保服务器安装了 Docker 和 Docker Compose。
- 服务器需要网络访问权限（用于克隆 GitHub 仓库）。
- 推荐使用 Ubuntu/Debian 或 CentOS 等 Linux 发行版。
- 确保有 sudo 权限或 root 访问。

### 3. 项目配置
- 确保项目根目录有 `Dockerfile` 和 `docker-compose.yml`（如果需要）。
- 如果没有，需要创建适合 Jekyll 的 Docker 配置。
- 示例 `Dockerfile`（国内服务器优化版）：

```dockerfile
# 国内服务器使用阿里云 Ruby 镜像源
FROM registry.cn-hangzhou.aliyuncs.com/ruby:slim

# 基于项目实际 Dockerfile 的简化版本
WORKDIR /srv/jekyll

COPY Gemfile Gemfile.lock ./

# 使用国内 RubyGems 镜像源加速
RUN gem sources --clear-all && \
    gem sources --add https://gems.ruby-china.com/ && \
    gem install --no-document jekyll bundler && \
    bundle config mirror.https://rubygems.org https://gems.ruby-china.com && \
    bundle install --no-cache

COPY . .

RUN jekyll build

EXPOSE 4000

CMD ["jekyll", "serve", "--host", "0.0.0.0"]
```

**说明：**
- 基于项目的实际 Dockerfile 使用 `ruby:slim` 作为基础镜像（不是预构建的 al-folio 镜像）
- 配置了国内 RubyGems 镜像源加速依赖安装
- 如果仍遇到网络问题，可先配置 Docker 镜像加速器（见下方章节）

**国内服务器加速重要说明：**
国内服务器构建镜像时，需要处理两个层面的加速：
1. **Docker 镜像层**：通过配置 `/etc/docker/daemon.json` 的 `registry-mirrors` 加速基础镜像下载
2. **系统依赖包**：通过在 Dockerfile 中配置国内 APT 源（如阿里云镜像）加速 `apt-get update` 下载

**只有同时处理这两个层面，才能实现全程快速构建。** 单独配置 Docker 镜像加速器只能解决基础镜像下载，无法解决容器内 `apt-get` 的慢速问题。

**为什么推荐这个镜像？** `amirpourmand/al-folio` 是专门为 al-folio 优化的镜像，已包含所有依赖（大小约 1.43GB），避免每次构建时重新下载 Ruby gems。首次拉取后，本地缓存会复用，更新时只需重新构建项目代码。相比 `jekyll/jekyll:latest`，构建速度更快。

## 步骤 1: 推送代码到 GitHub

### 1. 初始化本地仓库
```bash
cd /path/to/your/al-folio/project
git init
git add .
git commit -m "Initial commit"
```

### 2. 添加远程仓库
```bash
# 对于公共仓库
git remote add origin https://github.com/your-username/your-repo-name.git

# 对于私有仓库（使用 SSH，需要先配置 SSH 密钥）
git remote add origin git@github.com:your-username/your-repo-name.git
```

### 3. 推送代码
```bash
git push -u origin main  # 或 master，根据默认分支
```

### 注意事项
- 如果是私有仓库，确保：
  - 配置了 SSH 密钥：`ssh-keygen -t ed25519 -C "your-email@example.com"`，然后添加到 GitHub。
  - 或使用个人访问令牌（PAT）代替密码。

## 步骤 2: 服务器部署

### 1. 连接到服务器
```bash
ssh user@your-server-ip
```

### 2. 克隆仓库
```bash
# 对于公共仓库
git clone https://github.com/your-username/your-repo-name.git

# 对于私有仓库（使用 SSH）
git clone git@github.com:your-username/your-repo-name.git

cd your-repo-name
```

### 3. Docker 构建和运行
```bash
# 构建 Docker 镜像
docker build -t smart-lab-site .

# 运行容器
docker run -d -p 8080:4000 --name smart-lab-container smart-lab-site
```

- `-d`: 后台运行
- `-p 8080:4000`: 将服务器的 8080 端口映射到容器的 4000 端口
- 如果有 `docker-compose.yml`，可以使用 `docker-compose up -d`

### 4. 验证部署
- 访问 `http://your-server-ip:8080` 查看网站。
- 如果无法访问，检查防火墙设置：`sudo ufw allow 8080` 或相应防火墙命令。

## 步骤 3: 处理端口冲突

如果服务器上的端口（如 8080）已被其他 webapp 占用：

### 1. 检查端口使用情况
```bash
# 查看端口使用
sudo netstat -tlnp | grep :8080

# 或使用 lsof
sudo lsof -i :8080
```

### 2. 解决方案
#### 方案 A: 使用不同端口
```bash
# 停止现有容器
docker stop smart-lab-container

# 运行在新端口（如 8081）
docker run -d -p 8081:4000 --name smart-lab-container smart-lab-site

# 更新防火墙
sudo ufw allow 8081
```

#### 方案 B: 使用反向代理（推荐，见步骤 5）
使用 Nginx 等反向代理，可以在同一端口（通常 80 或 443）上运行多个应用，通过域名或路径区分。

## 步骤 4: 自动同步（CI/CD）

当您修改页面并推送代码到 GitHub 时，如何自动同步到服务器？

### 方案 A: 使用 GitHub Actions（推荐）
1. 在项目根目录创建 `.github/workflows/deploy.yml`：

```yaml
name: Deploy to Server

on:
  push:
    branches:
      - main  # 或你的默认分支

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to server
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.SERVER_HOST }}
          username: ${{ secrets.SERVER_USER }}
          key: ${{ secrets.SERVER_SSH_KEY }}
           script: |
            cd /path/to/your/project
            git pull origin main
            docker stop smart-lab-container || true
            docker rm smart-lab-container || true
            docker build -t smart-lab-site .
            docker run -d -p 8080:4000 --name smart-lab-container smart-lab-site
```

2. 在 GitHub 仓库设置中添加 Secrets：
   - `SERVER_HOST`: 服务器 IP
   - `SERVER_USER`: 服务器用户名
   - `SERVER_SSH_KEY`: 服务器的 SSH 私钥

### 方案 B: 使用 Webhook（手动设置）
1. 在服务器上安装 webhook 工具（如 `gohook` 或使用 Node.js 脚本）。
2. 配置 webhook 监听 GitHub 的 push 事件。
3. 当接收到事件时，自动执行更新脚本。

## 步骤 5: 域名绑定和反向代理

是的，即使多个应用都使用端口 8080，您也可以通过反向代理使用域名区分它们。反向代理（如 Nginx）可以在标准端口（80/443）上监听，然后根据域名或路径将请求转发到相应的内部端口。

### 1. 安装 Nginx
```bash
sudo apt update
sudo apt install nginx
```

### 2. 配置 Nginx
创建配置文件 `/etc/nginx/sites-available/smart-lab`：

```nginx
server {
    listen 80;
    server_name smart-lab.top www.smart-lab.top;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 3. 启用配置
```bash
sudo ln -s /etc/nginx/sites-available/smart-lab /etc/nginx/sites-enabled/
sudo nginx -t  # 测试配置
sudo systemctl reload nginx
```

### 4. DNS 配置
- 在域名注册商处，将域名 A 记录指向服务器 IP。
- 等待 DNS 传播（可能需要几小时）。

### 5. SSL 证书（推荐）
使用 Let's Encrypt 获取免费 SSL：
```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d smart-lab.top
```

更新 Nginx 配置为 HTTPS，并重定向 HTTP 到 HTTPS。

### 6. 多应用场景
如果有多个应用，可以配置多个 server 块：
```nginx
server {
    listen 80;
    server_name app1.smart-lab.top;
    location / {
        proxy_pass http://localhost:8080;
    }
}

server {
    listen 80;
    server_name app2.smart-lab.top;
    location / {
        proxy_pass http://localhost:8081;
    }
}
```

## 故障排除

### 常见问题
1. **Docker 构建失败**：检查 Dockerfile 和项目依赖。
2. **端口无法访问**：检查防火墙和 Docker 容器状态。
3. **域名不工作**：检查 DNS 设置和 Nginx 配置。
4. **自动同步失败**：检查 GitHub Actions 日志和服务器权限。

### 日志查看
```bash
# Docker 日志
docker logs smart-lab-container

# Nginx 日志
sudo tail -f /var/log/nginx/error.log
```

## 国内服务器加速

### 1. 配置 Docker 镜像加速器
如果你使用阿里云等国内云服务器，推荐配置 Docker 镜像加速器：

1. **阿里云用户**：
   - 登录阿里云控制台 → 容器镜像服务 → 镜像加速器
   - 获取你的专属加速器地址（如 `https://your-id.mirror.aliyuncs.com`）

2. **配置 Docker**：
```bash
# 创建或编辑 Docker 配置文件
sudo nano /etc/docker/daemon.json
```

添加内容：
```json
{
  "registry-mirrors": [
    "https://your-id.mirror.aliyuncs.com"
  ]
}
```

3. **重启 Docker**：
```bash
sudo systemctl daemon-reload
sudo systemctl restart docker
```

### 2. 其他国内镜像源
除了阿里云，还可以考虑：
- 网易云：`https://hub-mirror.c.163.com`
- 中科大：`https://docker.mirrors.ustc.edu.cn`
- 腾讯云：`https://mirror.ccs.tencentyun.com`

## 常见问题解答 (FAQ)

### Q: 每次运行 deploy.sh 时都要重新下载 base 镜像吗？
A: 不需要。首次运行 `deploy.sh` 时，Docker 会拉取 base 镜像 `amirpourmand/al-folio:latest`（约 1.43GB），包含所有预安装的依赖（如 Ruby、Jekyll、al-folio 主题）。后续运行时，如果 base 镜像存在且未变化，Docker 会使用本地缓存，不会重新下载。只会检查项目代码变化，如果有修改，会重新执行 `COPY` 和 `RUN jekyll build` 来生成新的静态网页。这样可以显著加速构建过程。

### Q: 本地开发时修改页面为什么能自动更新，而服务器部署需要重新构建？
A: 本地开发通常使用 `jekyll serve --watch` 并挂载源代码目录（`-v`），容器会监听文件变化并自动重构站点。服务器部署是生产模式，Dockerfile 在构建时一次性生成静态文件并 serve，不监听变化。更新内容后，需要重新构建镜像以生成新文件。这是为了性能和稳定性（静态文件加载更快，更安全）。

## 总结

通过以上步骤，您可以成功部署 smart-lab 网站，并实现自动更新和域名绑定。关键是理解 Docker 容器化、端口映射和反向代理的概念。如果遇到问题，请检查日志并确保所有权限正确配置。

如有进一步问题，请提供具体错误信息。