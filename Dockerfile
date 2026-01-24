# 使用官方镜像 + Docker 镜像加速器
FROM ruby:slim

# 在国内服务器上，Docker 会自动使用配置的镜像加速器
# 请确保已配置 /etc/docker/daemon.json 中的 registry-mirrors

# uncomment these if you are having this issue with the build:
# /usr/local/bundle/gems/jekyll-4.3.4/lib/jekyll/site.rb:509:in `initialize': Permission denied @ rb_sysopen - /srv/jekyll/.jekyll-cache/.gitignore (Errno::EACCES)
# ARG GROUPID=901
# ARG GROUPNAME=ruby
# ARG USERID=901
# ARG USERNAME=jekyll

ENV DEBIAN_FRONTEND noninteractive

LABEL authors="Amir Pourmand,George Araújo" \
      description="Docker image for al-folio academic template" \
      maintainer="Amir Pourmand"

# uncomment these if you are having this issue with the build:
# /usr/local/bundle/gems/jekyll-4.3.4/lib/jekyll/site.rb:509:in `initialize': Permission denied @ rb_sysopen - /srv/jekyll/.jekyll-cache/.gitignore (Errno::EACCES)
# add a non-root user to the image with a specific group and user id to avoid permission issues
# RUN groupadd -r $GROUPNAME -g $GROUPID && \
#     useradd -u $USERID -m -g $GROUPNAME $USERNAME

# configure APT sources for faster downloads in China
RUN echo "deb https://mirrors.aliyun.com/debian/ trixie main" > /etc/apt/sources.list && \
    echo "deb https://mirrors.aliyun.com/debian/ trixie-updates main" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.aliyun.com/debian-security/ trixie-security main" >> /etc/apt/sources.list && \
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

# set the locale
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

# copy the Gemfile and Gemfile.lock to the image
ADD Gemfile.lock /srv/jekyll
ADD Gemfile /srv/jekyll

# set the working directory
WORKDIR /srv/jekyll

# install jekyll and dependencies
RUN gem install --no-document jekyll bundler

# pre-download jekyll-terser manually if network fails
RUN gem install --no-document https://github.com/RobertoJBeltran/jekyll-terser/releases/download/v0.2.0/jekyll-terser-0.2.0.gem || \
    echo "Manual download failed, will try git clone during bundle install"

# configure Gemfile to use China mirrors
RUN sed -i 's|https://rubygems.org|https://gems.ruby-china.com|g' /srv/jekyll/Gemfile && \
    sed -i 's|.*jekyll-terser.*git.*|# gem '\''jekyll-terser'\'' # installed manually|g' /srv/jekyll/Gemfile

# configure network mirrors for China
RUN gem sources --clear-all && \
    gem sources --add https://gems.ruby-china.com/ && \
    bundle config set mirror.https://rubygems.org https://gems.ruby-china.com/ && \
    git config --global url."https://hub.fastgit.xyz/".insteadOf "https://github.com/" && \
    git config --global url."https://mirror.ghproxy.com/https://github.com/".insteadOf "git@github.com:" && \
    git config --global url."https://gitclone.github.com/".insteadOf "https://git@github.com:" && \
    git config --global http.postBuffer 524288000 && \
    git config --global http.maxRequestBuffer 100M && \
    git config --global core.compression 0 && \
    git config --global http.lowSpeedLimit 0 && \
    git config --global http.lowSpeedTime 999999 && \
    git config --global http.proxy "" && \
    git config --global https.proxy ""

# install dependencies with network optimization
RUN bundle install --no-cache

EXPOSE 8080

COPY bin/entry_point.sh /tmp/entry_point.sh

# uncomment this if you are having this issue with the build:
# /usr/local/bundle/gems/jekyll-4.3.4/lib/jekyll/site.rb:509:in `initialize': Permission denied @ rb_sysopen - /srv/jekyll/.jekyll-cache/.gitignore (Errno::EACCES)
# set the ownership of the jekyll site directory to the non-root user
# USER $USERNAME

CMD ["/tmp/entry_point.sh"]
