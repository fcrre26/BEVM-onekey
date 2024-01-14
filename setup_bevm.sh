#!/bin/bash

# 定义变量
NODE_DOWNLOAD_URL="https://github.com/btclayer2/BEVM/releases/download/testnet-v0.1.1/bevm-v0.1.1-ubuntu20.04"
NODE_PROCESS_NAME="bevm-v0.1.1-ubuntu20.04"   
NODE_NAME_FILE="node_name.txt"
NODE_LOG_FILE="node.log"

# 获取节点名称
function get_node_name() {

  read -p "请选择节点名称方式:
  1. 随机节点名称(回车默认)
  2. 手工输入节点名称:" option

  if [ "$option" = "2" ]; then
    read -p "请输入节点名称: " node_name
    node_name=${node_name// /}
  else  
    node_name=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 10-15)
    echo "随机生成的节点名称为: $node_name"
  fi

  echo $node_name > $NODE_NAME_FILE

}

# 下载节点程序
function download_node() {

  echo "开始下载节点程序..."

  wget -O /root/$NODE_PROCESS_NAME $NODE_DOWNLOAD_URL

  if [ $? -ne 0 ]; then
    echo "下载失败,请检查网络或下载地址是否可用"
    exit 1
  fi

  echo "下载完成"

}

# 配置并启动节点
function start_node() {

  chmod +x /root/$NODE_PROCESS_NAME

  echo "开始启动节点..."

  nohup /root/$NODE_PROCESS_NAME --chain=testnet --name="$(cat $NODE_NAME_FILE)" --pruning=archive > $NODE_LOG_FILE 2>&1 &disown

  pid=$!

  echo "节点进程启动,PID为:$pid"

}

# 检查节点状态
function check_node() {

  echo "检查节点状态..."

  if pgrep -f $NODE_PROCESS_NAME; then
    echo "节点运行正常"
  else
    echo "节点进程异常,请检查日志或重启节点"
    exit 1
  fi

}

# 查看日志
function view_log() {
  tail -f $NODE_LOG_FILE &
}

# 主程序
get_node_name
download_node
start_node
check_node

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
