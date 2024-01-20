#!/bin/bash

# 手工录入限制内存和交换空间大小
read -p "你想限制容器内存是多少MB？" memory_limit_mb
memory_limit=${memory_limit_mb}  # 使用手工录入的内存限制
read -p "你想限制交换空间是多少MB？" swap_limit_mb
swap_limit=${swap_limit_mb}  # 使用手工录入的交换空间限制

# 检索所有的容器
echo "正在检索所有的容器..."
if ! docker ps -a; then
  echo "无法检索容器，请检查Docker是否正确安装。"
  exit 1
fi

# 打印容器列表详情
echo "容器列表详情："
docker ps -a

# 停止所有容器
echo "正在停止所有容器..."
if ! docker stop $(docker ps -aq); then
  echo "无法停止容器，请检查Docker是否正确安装。"
  exit 1
fi
echo "所有容器已停止。"

# 限制容器内存和交换空间
echo "正在设置容器内存和交换空间限制..."
if ! docker update --memory=${memory_limit}M --memory-swap=${swap_limit}M $(docker ps -aq); then
  echo "无法设置容器内存和交换空间限制，请检查Docker是否正确安装。"
  exit 1
fi
echo "容器内存限制为${memory_limit}MB，交换空间限制为${swap_limit}MB。"

# 逐个开启所有容器
echo "正在逐个开启所有容器..."
if ! docker start $(docker ps -aq); then
  echo "无法开启容器，请检查Docker是否正确安装。"
  exit 1
fi
echo "所有容器已成功开启。"

# 检查内存限制是否起效并打印容器列表详情
echo "正在检查内存限制是否起效并打印容器列表详情..."
docker stats --no-stream $(docker ps -aq)

# 打印结果
echo "所有容器内存限制${memory_limit}MB，交换空间限制${swap_limit}MB设置成功，并且成功启动！"
