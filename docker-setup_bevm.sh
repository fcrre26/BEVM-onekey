#!/bin/bash

# 定义保存节点名称的文件路径
NODE_NAME_FILE=/root/node_names.txt

# 打开防火墙端口
sudo ufw allow 20222
sudo ufw allow 8086
sudo ufw allow 8087
sudo ufw status

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

# 运行指定数量的容器
function runContainers(){
  # 询问用户要运行的节点数量
  read -p "请输入节点数量: " count

  # 获取 BEVM 测试网节点镜像
  sudo docker pull btclayer2/bevm:v0.1.1

  # 循环运行指定数量的容器
  for i in $(seq 1 $count); do
    name=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 10)   
    echo "启动容器 $name 中..."
    sudo docker run -d -v /var/lib/node_bevm_test_storage:/root/.local/share/bevm --name $name btclayer2/bevm:v0.1.1 bevm --chain=testnet --name="$name" --pruning=archive --telemetry-url "wss://telemetry.bevm.io/submit 0"
    echo "容器 $name 启动完成"
  done
}

# 安装 Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

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
echo "部署完成,节点列表:"
cat $NODE_NAME_FILE
