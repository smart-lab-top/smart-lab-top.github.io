# 使用 Daocloud 镜像加速
FROM docker.m.daocloud.io/library/ruby:3.1.2-slim

ENV DEBIAN_FRONTEND noninteractive

# 使用标准的 Debian Bullseye 阿里云源
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    sed -i 's/security.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list

# 安装系统依赖，特别是编译 sass-embedded 所需的库
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
        zlib1g-dev \
        libffi-dev \
        libyaml-dev && \
    pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple && \
    pip --no-cache-dir install --upgrade nbconvert

# 设置语言环境
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    JEKYLL_ENV=production

WORKDIR /srv/jekyll

# 复制 Gemfile（不带 lockfile，防止版本锁定冲突）
COPY Gemfile /srv/jekyll/

# 关键：升级 RubyGems 和 Bundler 以修复 JSON::Fragment 报错
RUN gem update --system && \
    gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/ && \
    gem install bundler && \
    bundle config set mirror.https://rubygems.org https://gems.ruby-china.com && \
    # 配置 GitHub 代理以安装 jekyll-terser
    git config --global url."https://ghproxy.net/https://github.com/".insteadOf "https://github.com/" && \
    bundle install --no-cache

EXPOSE 4000

COPY bin/entry_point.sh /tmp/entry_point.sh
RUN chmod +x /tmp/entry_point.sh

CMD ["/tmp/entry_point.sh"]