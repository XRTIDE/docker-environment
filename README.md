## __构建多架构映像:__
__内容包括:__
- Jupyter
- Python
- Pyenv
- Rust
- C#
- oh-my-zsh
---
新しいビルダーインスタンスを作成し、そのインスタンスを現在の Docker コンテキストとして設定します。
```shell
docker buildx create --use --name=ビルダーインスタンス名前
```
构建docker镜像
```shell
docker buildx build --platform linux/arm64,linux/amd64 -t xrtide/xrtide . --push
```
指定したビルダーインスタンスを現在の Docker コンテキストとして設定します。
```shell
docker buildx create --name mybuilder
docker buildx use mybuilder
```
作成されたビルダーインスタンスの一覧を表示して削除する。
```shell
docker buildx ls
docker buildx rm mybuilder
```

## __启动容器的命令:__
```shell
docker run [OPTIONS] IMAGE [容器加载后执行的命令] [命令参数]
```
### OPTIONS说明:

* `-a stdin`: 指定标准输入输出内容类型，可选 STDIN/STDOUT/STDERR 三项；
* `-d`: 后台运行容器，并返回容器ID；
* `-i`: 以交互模式运行容器，通常与 -t 同时使用；
* `-P`: 随机端口映射，容器内部端口随机映射到主机的端口
* `-p`: 指定端口映射，格式为：主机(宿主)端口:容器端口
* `-t`: 为容器重新分配一个伪输入终端，通常与 -i 同时使用；
* `--name="nginx-lb"`: 为容器指定一个名称；
* `--dns 8.8.8.8`: 指定容器使用的DNS服务器，默认和宿主一致；
* `--dns-search example.com`: 指定容器DNS搜索域名，默认和宿主一致；
* `-h "mars"`: 指定容器的hostname；
* `-e username="ritchie"`: 设置环境变量；
* `--env-file=[]`: 从指定文件读入环境变量；
* `--cpuset="0-2" or --cpuset="0,1,2"`: 绑定容器到指定CPU运行；
* `-m`:设置容器使用内存最大值；
* `--net="bridge"`: 指定容器的网络连接类型，支持 bridge/host/none/container: 四种类型；
* `--link=[]`: 添加链接到另一个容器；
* `--volume , -v`: 绑定一个卷
* `--expose=[]`: 开放一个端口或一组端口；

### 示例
```shell
docker run -p 80:80 -v $(pwd):/code --name="xrtide-container-01" -it xrtide/xrtide:1.0 /bin/bash
```
docker容器运行必须有一个前台进程， 如果没有前台进程执行，容器认为空闲，就会自行退出。所以使用`-dit`参数
```shell
docker run -w /home/chxi -p 80:80 -v $HOME/Desktop/code/:/home/chxi/code --name="xrtide-container" -dit xrtide/xrtide /bin/zsh
```
