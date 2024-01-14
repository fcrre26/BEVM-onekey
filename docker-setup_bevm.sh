#!/bin/bash

NODE_NAME_FILE=/root/node_names.txt

function generateNodeName(){
  name=$(head /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 10)
  echo $name
}

function checkResourceUsage(){
  container_id=$1
  usage=$(docker stats --no-stream "$container_id" | grep "CPU%" | awk '{print $2}')

  if [[ "$usage" -lt 50 ]]; then
    return 0
  else
    return 1 
  fi
}

function runContainers(){

  read -p "请输入节点数量: " count

  docker pull btclayer2/bevm:latest

  for i in $(seq 1 $count); do

    name=$(generateNodeName)   

    docker run -d --name $name btclayer2/bevm:latest bevm --chain=testnet

    echo $name >> $NODE_NAME_FILE

    while checkResourceUsage $name; do
      sleep 10
    done

  done

}

docker_cmd=$(which docker)

if ! command -v $docker_cmd &> /dev/null; then
  echo "请先安装docker"
  exit 1
fi

chmod +x $0

runContainers

name=$(tail -n 1 $NODE_NAME_FILE)
echo "部署完成,最后一个节点:$name"
echo "节点列表:"
cat $NODE_NAME_FILE
