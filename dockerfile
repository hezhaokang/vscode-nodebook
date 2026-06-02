# 基础镜像
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. 使用阿里云 apt 源
RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak && \
    sed -i 's@http://archive.ubuntu.com@http://mirrors.aliyun.com@g' /etc/apt/sources.list && \
    sed -i 's@http://security.ubuntu.com@http://mirrors.aliyun.com@g' /etc/apt/sources.list

# 2. 安装基础依赖并清理缓存
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    git \
    vim \
    python3 \
    python3-pip \
    python3-venv \
    tini \
    && rm -rf /var/lib/apt/lists/*

# 3. 安装 Node.js 20
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get update && apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# 4. pip 使用清华源
RUN pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

# 5. 安装 code-server
COPY code-server_4.102.2_amd64.deb /tmp/
RUN dpkg -i /tmp/code-server_4.102.2_amd64.deb && \
    apt-get install -f -y && \
    rm -f /tmp/code-server_4.102.2_amd64.deb

# 6. 安装 Jupyter Lab 和 Notebook
RUN pip3 install --no-cache-dir notebook jupyterlab

# 7. 创建非 root 用户并设置目录
RUN useradd -m coder && mkdir -p /workspace && chown coder:coder /workspace
USER coder
WORKDIR /workspace

# 8. 启动脚本
COPY --chown=coder:coder start.sh /start.sh
RUN chmod +x /start.sh

# 9. 开放端口
EXPOSE 7001 7002

# 10. tini 管理进程
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/start.sh"]
