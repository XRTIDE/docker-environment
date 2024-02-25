# 拉取ubuntu的arm64v8镜像
FROM arm64v8/ubuntu:latest

# 更新apt源
RUN apt update && apt upgrade -y

# 安装C++环境
RUN apt install -y build-essential
RUN apt install -y cmake
RUN apt install -y gdb

# 安装Python环境
RUN apt install -y python3
RUN apt install -y python3-pip

# 安装Jupyter环境
RUN pip3 install jupyter
RUN pip3 install ipykernel
RUN python3 -m ipykernel install

# 安装curl
RUN apt install -y curl
# Rustをインストール
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
# Rust環境変数を設定
ENV PATH="/root/.cargo/bin:$PATH"
# jupyter安装rust内核
RUN cargo install evcxr_jupyter
RUN evcxr_jupyter --install

# Ubuntu安装oh-my-zsh
RUN apt install -y zsh
RUN apt install -y git
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# oh-my-zsh安装插件
#zsh-autosuggestions 命令行命令键入时的历史命令建议
RUN git clone https://github.com/zsh-users/zsh-autosuggestions root/.oh-my-zsh/custom/plugins/zsh-autosuggestions
#zsh-syntax-highlighting 命令行语法高亮插件
RUN git clone https://gitee.com/Annihilater/zsh-syntax-highlighting.git root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# 启动zsh时加载的预设
RUN cat > /root/.zshenv <<EOF

# 别名
# Python
alias py=python3
alias pp=pip3
# Jupyter
alias ju=jupyter
# Rust
alias cg=cargo

# 防止中文乱码
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
# oh-my-zsh的安装路径（zsh的配置路径）
ZSH="/root/.oh-my-zsh"
# 设置主题
ZSH_THEME="agnoster" 

# 启动错误命令自动更正
ENABLE_CORRECTION="true"

# 在命令执行的过程中，使用小红点进行提示
COMPLETION_WAITING_DOTS="true"

# 配置oh-my-zsh使用的插件
plugins=(
        git
        extract
        zsh-autosuggestions
        zsh-syntax-highlighting
)
# 重启oh-my-zsh
source \$ZSH/oh-my-zsh.sh
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

# 允许root用户通过SSH登录
RUN apt install -y openssh-server
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

# 设置root登陆密码
RUN echo 'root:0000' | chpasswd

# 启动ssh服务
CMD ["/usr/sbin/sshd", "-D"]
