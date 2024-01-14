#!/bin/bash

# 定义保存节点名称的文件路径
NODE_NAME_FILE=/root/node_names.txt

# 生成一个随机的节点名称
function generateNodeName(){
  name=$(head /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 10)
  echo $name
}

# 检查容器的资源使用情况
function checkResourceUsage(){
  container_id=$1
  usage=$(docker stats --no-stream "$container_id" | grep "CPU%" | awk '{print $2}')

  if [[ "$usage" -lt 50 ]]; then
    return 0
  else
    return 1 
  fi
}

# 运行指定数量的容器
function runContainers(){

  # 询问用户要运行的节点数量
  read -p "请输入节点数量: " count

  # 从Docker Hub拉取镜像
  docker pull btclayer2/bevm:latest

  # 循环运行指定数量的容器
  for i in $(seq 1 $count); do

    # 生成节点名称
    name=$(generateNodeName)   

    # 运行容器并指定节点名称
    docker run -d --name $name btclayer2/bevm:latest bevm --chain=testnet

    # 将节点名称写入文件
    echo $name >> $NODE_NAME_FILE

    # 检查资源使用情况，直到满足条件
    while checkResourceUsage $name; do
      sleep 10
    done

  done

}

# 检查docker命令是否可用
docker_cmd=$(which docker)

if ! command -v $docker_cmd &> /dev/null; then
  echo "请先安装docker"
  exit 1
fi

# 赋予脚本执行权限
chmod +x $0

# 运行容器
runContainers

# 输出部署完成的消息以及节点列表
name=$(tail -n 1 $NODE_NAME_FILE)
echo "部署完成,最后一个节点:$name"
echo "节点列表:"
cat $NODE_NAME_FILE
