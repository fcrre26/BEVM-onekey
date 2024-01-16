#!/bin/bash

# 定义保存节点名称的文件路径
NODE_NAME_FILE=/root/node_names.txt

# 打开防火墙端口
sudo ufw allow 2022
sudo ufw allow 8086
sudo ufw allow 8087
sudo ufw status

# 生成一个随机的节点名称
function generateNodeName(){
  name=$(head /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 10)
  echo $name
}

# 检查容器的资源使用情况
function checkResourceUsage(){
  usage=$(docker stats --no-stream "$1" | grep "CPU%" | awk '{print $2}')
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

  # 更新软件包
  sudo apt update

  # 安装 Docker
  sudo apt install docker.io

  # 获取 BEVM 测试网节点镜像
  sudo docker pull btclayer2/bevm:v0.1.1

  # 循环运行指定数量的容器
  for i in $(seq 1 $count); do
    name=$(generateNodeName)   
    echo "启动容器 $name 中..."
    sudo docker run -d --name $name btclayer2/bevm:v0.1.1 bevm --chain=testnet --name="$name" --pruning=archive --telemetry-url "wss://telemetry.bevm.io/submit 0"
    echo "容器 $name 启动完成"

    # 输出 CPU 占比信息
    echo "容器 $name CPU 占比信息:"
    docker stats --no-stream $name | grep "CPU%"

    echo $name >> $NODE_NAME_FILE

    # 检查资源使用情况，直到满足条件
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
name=$(tail -n 1 $NODE_NAME_FILE)
echo "部署完成,最后一个节点:$name"
echo "节点列表:"
cat $NODE_NAME_FILE
