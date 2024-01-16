#!/bin/bash

# 定义保存节点名称的文件路径
NODE_NAME_FILE=/root/node_names.txt

# 获取节点数量
read -p "请输入节点数量: " count

# 获取节点名称并写入文件
for ((i=1; i<=$count; i++)); do
  read -p "请输入节点名称 $i: " node_name
  node_name=${node_name// /}
  echo $node_name >> $NODE_NAME_FILE  # 以追加方式写入文件
done

# 打开防火墙端口
sudo ufw allow 20222
sudo ufw allow 8086
sudo ufw allow 8087
sudo ufw allow 30333
sudo ufw allow 30334
sudo ufw status

# 安装 Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 检查docker命令是否可用
docker_cmd=$(which docker)

if ! command -v $docker_cmd &> /dev/null; then
  echo "请先安装docker"
  exit 1
fi

# 等待一段时间，确保Docker安装完成
sleep 10

# 循环运行指定数量的容器
for ((i=1; i<=$count; i++)); do
  name=$(sed -n "${i}p" $NODE_NAME_FILE)  # 从文件中读取节点名称
  echo "启动容器 $name 中..."
  sudo docker pull btclayer2/bevm:v0.1.1
  sudo docker run -d -v /var/lib/node_bevm_test_storage:/root/.local/share/bevm --name $name btclayer2/bevm:v0.1.1 bevm --chain=testnet --name="$name" --pruning=archive --telemetry-url "wss://telemetry.bevm.io/submit 0"
  echo "容器 $name 启动完成"
done

# 输出部署完成的消息以及节点列表
echo "部署完成,节点列表:"
cat $NODE_NAME_FILE
