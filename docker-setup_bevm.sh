#!/bin/bash

# 获取节点名称
function get_node_name() {

  read -p "请选择节点名称方式:
  1. 随机节点名称(回车默认)
  2. 手工输入节点名称:" option

  if [ "$option" = "2" ]; then
    read -p "请输入节点名称: " node_name
    node_name=${node_name// /}
  else  
    node_name=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 10)
    echo "随机生成的节点名称为: $node_name"
  fi

  echo $node_name > $NODE_NAME_FILE
}

# 更新软件包
sudo apt update

# 安装 Docker
sudo apt install docker.io

# 获取 BEVM 测试网节点镜像
sudo docker pull btclayer2/bevm:v0.1.1

# 运行节点（你可以自己命名节点）
get_node_name
sudo docker run -d btclayer2/bevm:v0.1.1 bevm --chain=testnet --name="$node_name" --pruning=archive --telemetry-url "wss://telemetry.bevm.io/submit 0"
