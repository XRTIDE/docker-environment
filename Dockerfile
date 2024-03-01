# 拉取ubuntu的arm64v8镜像
FROM arm64v8/ubuntu:latest

# 更新apt源
RUN apt update && apt upgrade -y

# 安装C++环境
RUN apt install -y build-essential
RUN apt install -y cmake
RUN apt install -y gdb

# 安装curl
RUN apt install -y curl
# 安装wget
RUN apt install -y wget
# 安装git
RUN apt install -y git

# 安装Python环境
RUN apt install -y python3.11
RUN apt install -y python3-pip

# 安装Pyenv
RUN curl https://pyenv.run | bash
ENV PATH="/root/.pyenv/bin:$PATH"

# 安装Jupyter环境
RUN pip3 install --upgrade pip
RUN pip3 install jupyter
RUN pip3 install ipykernel
# 添加Python内核
RUN python3 -m ipykernel install --user --name py3.11_default --display-name "py3.11_default"

# 安装Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
# Rust環境変数を設定
ENV PATH="/root/.cargo/bin:$PATH"
# jupyter安装rust内核
RUN cargo install evcxr_jupyter
RUN evcxr_jupyter --install

# 安装Dotnet
RUN wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
RUN chmod +x ./dotnet-install.sh \
    && ./dotnet-install.sh \
    && ./dotnet-install.sh --runtime dotnet \
    && ./dotnet-install.sh --runtime aspnetcore \
    && rm ./dotnet-install.sh
# Dotnet环境变量设置
ENV PATH="/root/.dotnet:$PATH"
# 安装Dotnet tools
RUN dotnet tool install --global Microsoft.dotnet-interactive
# Dotnet tools环境变量设置
ENV PATH="/root/.dotnet/tools:$PATH"
# 安装C#内核
# RUN dotnet interactive jupyter install    # 无法安装
# 停止向微软发送数据
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1


# Ubuntu安装oh-my-zsh
RUN apt install -y zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# oh-my-zsh安装插件
#zsh-autosuggestions 命令行命令键入时的历史命令建议
RUN git clone https://github.com/zsh-users/zsh-autosuggestions root/.oh-my-zsh/custom/plugins/zsh-autosuggestions
#zsh-syntax-highlighting 命令行语法高亮插件
RUN git clone https://gitee.com/Annihilater/zsh-syntax-highlighting.git root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# 修改.zshrc文件
# 设置主题
RUN sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/g' /root/.zshrc
# 配置oh-my-zsh使用的插件
RUN sed -i 's/plugins=(git)/plugins=( git extract zsh-autosuggestions zsh-syntax-highlighting)/g' /root/.zshrc

# 启动zsh时加载的预设(另一个文件)
RUN cat > /root/.zshenv <<EOF

# 别名
# Python
alias py=python3
alias pp=pip3
# Jupyter
alias ju=jupyter
# Rust
alias cg=cargo
# C#
alias cs=dotnet

# 防止中文乱码
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# 启动错误命令自动更正
ENABLE_CORRECTION="true"

# 在命令执行的过程中，使用小红点进行提示
COMPLETION_WAITING_DOTS="true"

EOF

# 将.zshenv文件追加到.zshrc文件中
RUN cat >> /root/.zshrc <<EOF
source /root/.zshenv
EOF

# 更改默认shell为zsh
RUN chsh -s /bin/zsh
# 安装字体
RUN git clone https://github.com/keyding/Operator-Mono.git /usr/share/fonts/operatorMono
RUN apt install -y fontconfig && fc-cache -f -v

# 设置时区
RUN apt install -y language-pack-en
RUN update-locale

# 允许root用户通过SSH登录
RUN mkdir /run/sshd
RUN apt install -y openssh-server
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

# 设置root登陆密码
RUN echo 'root:0000' | chpasswd
# 创建工作空间
RUN mkdir /root/code

# 启动ssh服务
CMD ["/usr/sbin/sshd", "-D"]
