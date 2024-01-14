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

# 运行 Docker 容器
function run_docker_containers() {
  read -p "请输入要运行的 Docker 容器数量: " container_count
  for ((i=1; i<=$container_count; i++)); do
    sudo docker run -d btclayer2/bevm:v0.1.1 bevm --chain=testnet --name="$node_name-$i" --pruning=archive --telemetry-url "wss://telemetry.bevm.io/submit 0"
  done
}

# 更新软件包
sudo apt update

# 安装 Docker
sudo apt install docker.io

# 获取 BEVM 测试网节点镜像
sudo docker pull btclayer2/bevm:v0.1.1

# 运行节点（你可以自己命名节点）
get_node_name
run_docker_containers

# 输出部署完成信息
echo "部署完成,节点名称:$node_name,并且保存在$NODE_NAME_FILE文件中"

# 选择是否查看日志
read -p "是否需要查看日志?
1. 查看
2. 退出
回车键默认查看:" input

if [ "$input" == "1" ]; then
  view_log
elif [ "$input" == "2" ]; then
  exit 0
else
  view_log
fi

echo "部署完成!"
