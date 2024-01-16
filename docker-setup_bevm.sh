#!/bin/bash

# 定义保存节点名称的文件路径
NODE_NAME_FILE=/root/node_names.txt

# 获取节点数量
read -p "请输入节点数量: " NODE_COUNT

# 清空节点名称文件
> "$NODE_NAME_FILE"

# 获取节点名称并写入文件
for ((i=1; i<=$NODE_COUNT; i++)); do
  read -p "请输入第 $i 个节点的名称: " node_name
  node_name=${node_name// /}  # 移除空格
  echo "$node_name" >> "$NODE_NAME_FILE"
  echo "添加节点名称: $node_name"
done

# 更新软件包
sudo apt update

# 打开防火墙端口
sudo ufw allow 20222
sudo ufw allow 8086
sudo ufw allow 8087
sudo ufw allow 30333
sudo ufw allow 30334
sudo ufw status

# 安装docker并拉取镜像
sudo apt update
sudo apt install docker.io -y
sudo docker pull btclayer2/bevm:v0.1.1

# 运行容器
for ((i = 1; i <= NODE_COUNT; i++)); do
  name="node$i"
  echo "启动容器 $name 中..."
  sudo docker run -d --name $name btclayer2/bevm:v0.1.1 bevm --chain=testnet --name="$name" --pruning=archive --telemetry-url "wss://telemetry.bevm.io/submit 0"
  echo "容器 $name 启动完成"
  echo "容器 $name CPU 占比信息:"
  docker stats --no-stream $name | grep "CPU%"
  echo $name >> $NODE_NAME_FILE  # 只将用户输入的节点名称写入节点列表文件中
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

# 输出部署完成的消息以及节点列表
echo "部署完成,最后一个节点: node$NODE_COUNT"
echo "节点列表:"
cat $NODE_NAME_FILE
