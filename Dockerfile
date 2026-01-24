# 直接从国内镜像站拉取基础镜像，绕过 Docker Hub 超时问题
FROM docker.m.daocloud.io/library/ruby:3.1.2-slim

ENV DEBIAN_FRONTEND noninteractive

# 使用标准的 Debian Bullseye 源，这是最稳定的
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    sed -i 's/security.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list

# 安装系统依赖
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        git \
        imagemagick \
        inotify-tools \
        locales \
        nodejs \
        procps \
        python3-pip \
        zlib1g-dev && \
    pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple && \
    pip --no-cache-dir install --upgrade nbconvert

# 清理缓存
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# 设置语言环境
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    JEKYLL_ENV=production

WORKDIR /srv/jekyll

# 复制 Gemfile
COPY Gemfile* /srv/jekyll/

# 配置 RubyGems 国内镜像并安装
RUN gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/ && \
    gem install bundler && \
    bundle config set mirror.https://rubygems.org https://gems.ruby-china.com && \
    git config --global url."https://ghp.ci/https://github.com/".insteadOf "https://github.com/" && \
    bundle install --no-cache

EXPOSE 4000

COPY bin/entry_point.sh /tmp/entry_point.sh
RUN chmod +x /tmp/entry_point.sh

CMD ["/tmp/entry_point.sh"]