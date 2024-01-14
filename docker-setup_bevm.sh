#!/bin/bash

# 节点名称文件路径
NODE_NAME_FILE=/root/node_name.txt

# 生成随机节点名称
function generate_node_name(){
  node_name=$(head /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 10)
  echo $node_name
}

# 检查容器资源使用情况
function check_resource_usage(){
  container_id=$1
  usage=$(docker stats --no-stream "$container_id" | grep "CPU%" | awk '{print $2}')

  if [[ "$usage" -lt 50 ]]; then
    return 0
  else
    return 1
  fi
}

# 运行Docker容器
function run_docker_containers(){

  read -p "请输入要运行的Docker容器数量:" container_count

  sudo docker pull btclayer2/bevm:v0.1.1

  for ((i=1;i<=container_count;i++)); do

    node_name=$(generate_node_name)

    sudo docker run -d btclayer2/bevm:v0.1.1 bevm --chain=testnet --name="$node_name" --pruning=archive --telemetry-url "wss://telemetry.bevm.io/submit 0"

    echo "$node_name" >> "$NODE_NAME_FILE"

    if [[ "$i" -eq 1 ]]; then
      while ! check_resource_usage "$node_name"; do
        sleep 10  
      done
    fi

    if [[ "$i" -gt 1 ]]; then
      sleep 10
    fi

  done

}

run_docker_containers

node_name=$(tail -n 1 "$NODE_NAME_FILE")

echo "部署完成,最后一个节点名称:$node_name"

echo
echo "部署的节点名称列表:"
cat "$NODE_NAME_FILE"
echo
