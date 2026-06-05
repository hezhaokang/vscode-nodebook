# syntax=docker/dockerfile:1

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai \
    PIP_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple \
    NODE_MAJOR=20 \
    CODE_SERVER_VERSION=4.102.2

# 使用国内源 + 安装依赖
RUN sed -i 's@archive.ubuntu.com@mirrors.aliyun.com@g' /etc/apt/sources.list && \
    sed -i 's@security.ubuntu.com@mirrors.aliyun.com@g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        wget \
        ca-certificates \
        git \
        vim \
        tini \
        python3 \
        python3-pip \
        python3-venv \
        gnupg && \
    rm -rf /var/lib/apt/lists/*

# 安装 Node.js（国内镜像）
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR}.x | bash - && \
    apt-get update && \
    apt-get install -y --no-install-recommends nodejs && \
    npm config set registry https://registry.npmmirror.com && \
    rm -rf /var/lib/apt/lists/*

# pip 配置
RUN mkdir -p /root/.pip && \
    echo "[global]\nindex-url=${PIP_INDEX_URL}" > /root/.pip/pip.conf

# 安装 code-server（避免直连 github）
RUN wget -O /tmp/code-server.deb \
https://ghproxy.com/https://github.com/coder/code-server/releases/download/v${CODE_SERVER_VERSION}/code-server_${CODE_SERVER_VERSION}_amd64.deb && \
    apt-get update && \
    dpkg -i /tmp/code-server.deb || apt-get install -fy && \
    rm -rf \
        /tmp/*.deb \
        /var/lib/apt/lists/*

# 安装 Jupyter
RUN pip3 install --no-cache-dir \
    notebook \
    jupyterlab

# 创建用户
RUN useradd \
    --create-home \
    --shell /bin/bash \
    coder && \
    mkdir -p /workspace && \
    chown -R coder:coder \
    /workspace

COPY start.sh /usr/local/bin/start.sh

RUN chmod +x /usr/local/bin/start.sh

USER coder
WORKDIR /workspace

EXPOSE 7001
EXPOSE 7002

ENTRYPOINT ["/usr/bin/tini","--"]

CMD ["/usr/local/bin/start.sh"]