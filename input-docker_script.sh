#!/bin/bash

# 手工录入限制内存和交换空间大小
read -p "你想限制容器内存是多少M？" memory_limit
read -p "你想限制交换空间是多少M？" swap_limit

# 检索所有的容器
echo "正在检索所有的容器..."
if ! containers=$(docker ps -aq); then
  echo "无法检索容器，请检查Docker是否正确安装。"
  exit 1
fi

# 停止所有容器
echo "正在停止所有容器..."
if ! docker stop $containers; then
  echo "无法停止容器，请检查Docker是否正确安装。"
  exit 1
fi

# 限制容器内存和交换空间
echo "正在设置容器内存和交换空间限制..."
if ! docker update --memory=$memory_limit --memory-swap=$swap_limit $containers; then
  echo "无法设置容器内存和交换空间限制，请检查Docker是否正确安装。"
  exit 1
fi

# 逐个开启所有容器
echo "正在逐个开启所有容器..."
if ! docker start $containers; then
  echo "无法开启容器，请检查Docker是否正确安装。"
  exit 1
fi

# 检查内存限制是否起效
echo "正在检查内存限制是否起效..."
docker stats --no-stream

# 打印结果
echo "所有容器内存限制$memory_limit，交换空间限制$swap_limit设置成功，并且成功启动！"
