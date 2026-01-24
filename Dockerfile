# 使用官方镜像 + Docker 镜像加速器
FROM ruby:3.1.2-slim

# 在国内服务器上，Docker 会自动使用配置的镜像加速器
# 请确保已配置 /etc/docker/daemon.json 中的 registry-mirrors

ENV DEBIAN_FRONTEND noninteractive

LABEL authors="Amir Pourmand,George Araújo" \
      description="Docker image for al-folio academic template" \
      maintainer="Amir Pourmand"

# configure APT sources for faster downloads in China
RUN echo "deb https://mirrors.aliyun.com/debian/ bullseye main" > /etc/apt/sources.list && \
    echo "deb https://mirrors.aliyun.com/debian/ bullseye-updates main" >> /etc/apt/sources.list && \
    rm -f /etc/apt/sources.list.d/* || true

# install system dependencies
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
    pip --no-cache-dir install --upgrade --break-system-packages nbconvert

# clean up
RUN apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*  /tmp/*

# set locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen

# set environment variables
ENV EXECJS_RUNTIME=Node \
    JEKYLL_ENV=production \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# create a directory for the jekyll site
RUN mkdir /srv/jekyll

# copy Gemfile and Gemfile.lock to the image
COPY Gemfile.lock /srv/jekyll
COPY Gemfile /srv/jekyll

# set working directory
WORKDIR /srv/jekyll

# install jekyll and dependencies
RUN gem install --no-document jekyll bundler

# configure Gemfile to use stable gem sources
RUN gem sources --clear-all && \
    gem sources --add https://rubygems.org/ && \
    bundle config set mirror.https://rubygems.org https://gems.ruby-china.com/

# install dependencies
RUN bundle install --no-cache

EXPOSE 4000

COPY bin/entry_point.sh /tmp/entry_point.sh

CMD ["/tmp/entry_point.sh"]