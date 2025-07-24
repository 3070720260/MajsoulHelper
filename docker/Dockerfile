# Use Ubuntu 24.04 as base image for newer GLIBC
FROM ubuntu:24.04

# Set non-interactive frontend for apt-get to avoid prompts
ENV DEBIAN_FRONTEND=noninteractive

# Set working directory
WORKDIR /app

# Allow passing proxy as build arguments
ARG HTTP_PROXY
ARG HTTPS_PROXY

# Set environment variables for proxy
ENV HTTP_PROXY=$HTTP_PROXY
ENV HTTPS_PROXY=$HTTPS_PROXY

# Configure APT to use Aliyun mirrors for Ubuntu 24.04 (Noble Numbat)
RUN echo "deb http://mirrors.aliyun.com/ubuntu/ noble main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/ubuntu/ noble-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/ubuntu/ noble-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/ubuntu/ noble-security main restricted universe multiverse" >> /etc/apt/sources.list

# Install base dependencies, Python 3, and pip
# On Ubuntu 24.04, python3 is python3.12
RUN apt-get update && \
    apt-get install -y curl git ca-certificates gnupg python3 python3-pip unzip && \
    rm -rf /var/lib/apt/lists/*

# Install Node.js 22 using NodeSource setup script
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install bun
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:$PATH"

# Configure git to use proxy
RUN git config --global http.proxy ${HTTP_PROXY} && \
    git config --global https.proxy ${HTTPS_PROXY}

# Configure pip to use Tsinghua mirror
RUN pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

# Copy requirements.txt and install python dependencies
COPY docker/requirements.txt .
RUN pip install --no-cache-dir --break-system-packages -r requirements.txt

# Install Git LFS
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
    apt-get update && \
    apt-get install -y git-lfs && \
    git lfs install && \
    rm -rf /var/lib/apt/lists/*

# Clone repositories
RUN git clone https://github.com/zhuozhiyongde/Akagi.git && \
    git clone https://github.com/zhuozhiyongde/AkagiFrontend.git && \
    git clone https://github.com/zhuozhiyongde/MajsoulMax.git

# Install specific protobuf versions
RUN cd Akagi && pip install --target ./vendor protobuf==5.29.3 --no-dependencies && cd ..
RUN cd MajsoulMax && pip install --target ./vendor protobuf==3.20.1 --no-dependencies && cd ..

# Build frontend
RUN cd AkagiFrontend && bun install && bun run build

# Copy entrypoint script
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Unset proxy environment variables
ENV HTTP_PROXY=
ENV HTTPS_PROXY=

ENTRYPOINT ["entrypoint.sh"]
CMD ["--help"]