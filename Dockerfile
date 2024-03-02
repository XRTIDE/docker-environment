# 拉取ubuntu的arm64v8镜像
FROM arm64v8/ubuntu:latest

# 更新apt源
RUN apt update && apt upgrade -y
# 允许root用户通过SSH登录
RUN mkdir /run/sshd
RUN apt install -y openssh-server
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
# 设置root登陆密码
RUN echo 'root:0000' | chpasswd

# 安装zsh
RUN apt install -y zsh
# 更改默认shell为zsh
RUN chsh -s /bin/zsh

# 新建非root用户
RUN useradd --create-home --no-log-init --shell /bin/zsh chxi \
    && adduser chxi sudo \
    && echo 'chxi:0000' | chpasswd
# 安装sudo
RUN apt install -y sudo
# 设置sudo免密
RUN echo "chxi ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
# 设置当前目录为/home/chxi
WORKDIR /home/chxi
# 以下命令切换到chxi用户执行
USER chxi:chxi
# 更改/home/chxi所属权为chxi
RUN sudo chown -R chxi:chxi /home/chxi

# 安装C++环境
RUN sudo apt install -y build-essential
RUN sudo apt install -y cmake
RUN sudo apt install -y gdb

# 安装curl
RUN sudo apt install -y curl
# 安装wget
RUN sudo apt install -y wget
# 安装git
RUN sudo apt install -y git

# 安装Pyenv依赖
RUN sudo apt install -y build-essential zlib1g-dev libffi-dev libssl-dev libbz2-dev libreadline-dev libsqlite3-dev liblzma-dev
# 安装Pyenv
RUN sudo curl https://pyenv.run | sh
ENV PATH="/home/chxi/.pyenv/bin:$PATH"

# 初始化Pyenv
RUN eval "$(pyenv init -)" \
    # 安装Python3.12
    && pyenv install 3.12 \
    # 更新Pyenv数据库
    && pyenv rehash \
    # 设置当前目录及子目录的Python
    && pyenv local 3.12 \
    # 安装Jupyter环境
    && pip3 install jupyter \
    && pip3 install ipykernel \
    # 添加3.12内核
    && python3 -m ipykernel install --user \
    # 取消当前目录及子目录的Python
    && pyenv local --unset

# 安装Rust
RUN sudo curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
# Rust環境変数を設定
ENV PATH="/home/chxi/.cargo/bin:$PATH"
# jupyter安装rust内核
RUN cargo install evcxr_jupyter
RUN evcxr_jupyter --install

# 安装Dotnet
RUN sudo wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
# Dotnet环境变量设置
ENV PATH="/home/chxi/.dotnet/tools:/home/chxi/.dotnet:$PATH"
# 停止向微软发送数据
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1
# 给予dotnet-install.sh执行权限
RUN sudo chmod +x ./dotnet-install.sh \
    # 安装Dotnet SDK和Runtime
    && ./dotnet-install.sh \
    && ./dotnet-install.sh --runtime dotnet \
    && ./dotnet-install.sh --runtime aspnetcore \
    # 删除dotnet-install.sh
    && sudo rm ./dotnet-install.sh \
    # 安装Dotnet tools
    && dotnet tool install --global Microsoft.dotnet-interactive
# 安装Jupyter内核
# && dotnet interactive jupyter install # 无法安装


# Ubuntu安装oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# oh-my-zsh安装插件
#zsh-autosuggestions 命令行命令键入时的历史命令建议
RUN sudo git clone https://github.com/zsh-users/zsh-autosuggestions /home/chxi/.oh-my-zsh/custom/plugins/zsh-autosuggestions
#zsh-syntax-highlighting 命令行语法高亮插件
RUN sudo git clone https://gitee.com/Annihilater/zsh-syntax-highlighting.git /home/chxi/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# 修改.zshrc文件
# 设置主题
RUN sudo sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/g' /home/chxi/.zshrc
# 配置oh-my-zsh使用的插件
RUN sudo sed -i 's/plugins=(git)/plugins=( git extract zsh-autosuggestions zsh-syntax-highlighting)/g' /home/chxi/.zshrc

# 启动zsh时加载的预设(另一个文件)
RUN cat > /home/chxi/.zshenv <<EOF

# 别名

# Python
alias pe=pyenv
alias py=python3
alias pp=pip3

# Jupyter
alias ju=jupyter

# Rust
alias cg=cargo
alias ru=rustup

# C#
alias dn=dotnet


# 防止中文乱码
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# 启动错误命令自动更正
ENABLE_CORRECTION="true"

# 在命令执行的过程中，使用小红点进行提示
COMPLETION_WAITING_DOTS="true"

# 初始化Pyenv
eval "\$(pyenv init -)"

EOF

# 将.zshenv文件追加到.zshrc文件中
RUN cat >> /home/chxi/.zshrc <<EOF
source /home/chxi/.zshenv
EOF

# 安装字体
RUN sudo git clone https://github.com/keyding/Operator-Mono.git /usr/share/fonts/operatorMono
RUN sudo apt install -y fontconfig && fc-cache -f -v

# 设置时区
RUN sudo apt install -y language-pack-en
RUN sudo update-locale

# 创建工作空间
RUN sudo mkdir /home/chxi/code

# 启动ssh服务
CMD ["/usr/sbin/sshd", "-D"]
