#!/bin/bash

# 定义节点名称文件
NODE_NAME_FILE=/path/to/node_name.txt

# 生成随机节点名称
function generate_node_name() {
  node_name=$(head /dev/urandom | tr -dc 'a-z0-9' | head -c 10)  
  echo $node_name
}

# 运行Docker容器
function run_docker_containers() {

  read -p "请输入要运行的Docker容器数量:" container_count

  for ((i=1; i<=$container_count; i++)); do

    node_name=$(generate_node_name)

    sudo docker run -d btclayer2/bevm:v0.1.1 bevm --chain=testnet --name="$node_name" --pruning=archive --telemetry-url "wss://telemetry.bevm.io/submit 0"

    echo $node_name > $NODE_NAME_FILE

  done

}

# 更新软件包
sudo apt update

# 安装Docker
sudo apt install docker.io

# 获取BEVM测试网镜像  
sudo docker pull btclayer2/bevm:v0.1.1

# 运行节点
run_docker_containers

# 输出结果
node_name=$(cat $NODE_NAME_FILE)
echo "部署完成,节点名称:$node_name,并且保存在$NODE_NAME_FILE文件中"

echo "部署完成!"
