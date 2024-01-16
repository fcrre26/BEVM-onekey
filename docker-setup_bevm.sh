#!/bin/bash

LOG_FILE="/root/deploy.log"
NODE_NAME_FILE="/root/node_names.txt"

# 错误处理函数
handle_error() {
  local error_message="$1"
  echo "$error_message" >> "$LOG_FILE"
  exit 1
}

# 日志记录函数
log_message() {
  local message="$1"
  echo "$message" >> "$LOG_FILE"
}

# 获取节点数量
read -p "请输入节点数量: " node_count
log_message "用户输入节点数量: $node_count"

# 获取节点名称并写入文件
> "$NODE_NAME_FILE"  # 清空节点名称文件
for ((i=1; i<=$node_count; i++)); do
  read -p "请输入节点名称 $i: " node_name
  node_name=${node_name// /}  # 移除空格
  echo "$node_name" >> "$NODE_NAME_FILE"
  log_message "添加节点名称: $node_name"
done

# 安装 Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 打开防火墙端口
ports=(30333 30334 20222 8086 8087)
for port in "${ports[@]}"; do
  sudo ufw allow "$port" || handle_error "无法打开防火墙端口: $port"
  log_message "已打开防火墙端口: $port"
done

# 拉取Docker镜像并运行容器
for ((i=1; i<=$node_count; i++)); do
  name=$(sed -n "${i}p" "$NODE_NAME_FILE")  # 从文件中读取节点名称
  log_message "启动容器 $name 中..."
  sudo docker pull btclayer2/bevm:v0.1.1 || handle_error "无法拉取Docker镜像"
  log_message "成功拉取Docker镜像: btclayer2/bevm:v0.1.1"
  sudo docker run -d -v /var/lib/node_bevm_test_storage:/root/.local/share/bevm --name "$name" btclayer2/bevm:v0.1.1 bevm --chain=testnet --name="$name" --pruning=archive --telemetry-url "wss://telemetry.bevm.io/submit" || handle_error "无法运行容器: $name"
  log_message "成功运行容器: $name"
  if [ $i -lt $node_count ]; then
    log_message "等待一段时间再启动下一个容器..."
    sleep 10  # 在启动下一个容器之前加入延迟
  fi
done

# 输出部署完成的消息以及节点列表
log_message "部署完成,节点列表:"
cat "$NODE_NAME_FILE" | while read line; do
  log_message "$line"
done
