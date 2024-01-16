#!/bin/bash

# 定义保存节点名称的文件路径
NODE_NAME_FILE=/root/node_names.txt

# 获取节点名称并写入文件
> "$NODE_NAME_FILE"  # 清空节点名称文件
read -p "请输入节点数量: " NODE_COUNT
for ((i=1; i<=$NODE_COUNT; i++)); do
  read -p "请输入第 $i 个节点的名称: " node_name
  node_name=${node_name// /}  # 移除空格
  echo "$node_name" >> "$NODE_NAME_FILE"
  echo "添加节点名称: $node_name"
done

# 打开防火墙端口
sudo ufw allow 20222
sudo ufw allow 8086
sudo ufw allow 8087
sudo ufw allow 30333
sudo ufw allow 30334
sudo ufw status

# 检查容器的资源使用情况
function checkResourceUsage() {
  usage=$(docker stats --no-stream "$1" | grep "CPU%" | awk '{print $2}' | cut -d. -f1)
  if [[ $usage -lt 50 ]]; then
    return 0
  else
    return 1
  fi
}

# 运行指定数量的容器
function runContainers() {
  sudo apt update
  sudo apt install docker.io -y
  sudo docker pull btclayer2/bevm:v0.1.1
  for ((i = 1; i <= NODE_COUNT; i++)); do
    name="node$i"
    echo "启动容器 $name 中..."
    sudo docker run -d --name $name btclayer2/bevm:v0.1.1 bevm --chain=testnet --name="$name" --pruning=archive --telemetry-url "wss://telemetry.bevm.io/submit 0"
    echo "容器 $name 启动完成"
    echo "容器 $name CPU 占比信息:"
    docker stats --no-stream $name | grep "CPU%"
    echo $name >>$NODE_NAME_FILE
    while true; do
      all_below_threshold=true
      for container in $(sudo docker ps --format "{{.Names}}"); do
        if ! checkResourceUsage $container; then
          all_below_threshold=false
          break
        fi
      done
      if $all_below_threshold; then
        break
      fi
      echo "容器 $name CPU 占比超过50%，等待中..."
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
echo "部署完成,最后一个节点: node$NODE_COUNT"
echo "节点列表:"
cat $NODE_NAME_FILE
