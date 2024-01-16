#!/bin/bash

# 定义保存节点名称的文件路径
NODE_NAME_FILE=/root/node_names.txt
LOG_FILE=/var/log/deployment.log

# 错误处理函数
handle_error() {
  local error_message="$1"
  echo "Error: $error_message" >&2
  echo "Error: $error_message" >> $LOG_FILE
  exit 1
}

# 日志记录函数
log_message() {
  local message="$1"
  echo "$message" >> $LOG_FILE
}

# 获取节点数量
read -p "请输入节点数量: " count
log_message "用户输入节点数量: $count"

# 获取节点名称并写入文件
for ((i=1; i<=$count; i++)); do
  read -p "请输入节点名称 $i: " node_name
  node_name=${node_name// /}
  echo $node_name >> $NODE_NAME_FILE || handle_error "无法写入节点名称到文件"
  log_message "节点名称 $i: $node_name"
done

# 打开防火墙端口
open_firewall_ports() {
  local ports=(20222 8086 8087 30333 30334)
  for port in "${ports[@]}"; do
    sudo ufw allow "$port" || handle_error "无法打开防火墙端口 $port"
    log_message "已打开防火墙端口: $port"
  done
  sudo ufw status | log_message
}

open_firewall_ports

# 安装 Docker
install_docker() {
  curl -fsSL https://get.docker.com -o get-docker.sh || handle_error "无法下载Docker安装脚本"
  sudo sh get-docker.sh || handle_error "Docker安装失败"
  log_message "Docker安装完成"
}

install_docker

# 检查docker命令是否可用
docker_cmd=$(which docker)

if ! command -v $docker_cmd &> /dev/null; then
  handle_error "Docker命令不可用"
fi

# 等待一段时间，确保Docker安装完成
sleep 10

# 循环运行指定数量的容器
deploy_containers() {
  for ((i=1; i<=$count; i++)); do
    name=$(sed -n "${i}p" $NODE_NAME_FILE)  # 从文件中读取节点名称
    log_message "启动容器 $name 中..."
    sudo docker pull btclayer2/bevm:v0.1.1 || handle_error "无法拉取Docker镜像"
    sudo docker run -d -v /var/lib/node_bevm_test_storage:/root/.local/share/bevm --name $name btclayer2/bevm:v0.1.1 bevm --chain=testnet --name="$name" --pruning=archive --telemetry-url "wss://telemetry.bevm.io/submit 0" || handle_error "无法运行容器 $name"
    log_message "容器 $name 启动完成"
  done
}

deploy_containers

# 输出部署完成的消息以及节点列表
echo "部署完成,节点列表:"
cat $NODE_NAME_FILE | log_message
