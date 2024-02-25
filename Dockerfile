# 基本イメージとしてUbuntuのarm64版を使用
FROM arm64v8/ubuntu:latest


# 更新
RUN apt update && apt upgrade -y
# 安装C++
RUN apt install -y build-essential
RUN apt install -y cmake
RUN apt install -y gdb
# 安装Python3
RUN apt install -y python3

# 安装curl
RUN apt install -y curl
# Rustをインストール
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
# Rust環境変数を設定
ENV PATH="/root/.cargo/bin:${PATH}"

# VS Codeがコンテナに接続するために必要なSSHサーバをインストール
RUN apt install -y openssh-server
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

# 设置密码
RUN echo 'root:0000' | chpasswd

# SSHサーバを起動するためのエントリーポイントを設定
CMD ["/usr/sbin/sshd", "-D"]
