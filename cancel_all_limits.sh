#!/bin/bash

# 询问用户是否确定取消所有容器的内存和交换空间限制
read -p "你确定要取消所有容器的内存以及交换空间限制吗？(Y继续): " confirm
if [ "$confirm" != "Y" ]; then
  echo "取消操作已取消。"
  exit 0
fi

# 检索所有的容器
echo "正在检索所有的容器..."
if ! docker ps -a; then
  echo "无法检索容器，请检查Docker是否正确安装。"
  exit 1
fi

# 取消所有容器的内存和交换空间限制
echo "正在取消所有容器的内存和交换空间限制..."
container_ids=$(docker ps -aq)
for container_id in $container_ids; do
  if ! docker update --memory="" --memory-swap="" $container_id; then
    echo "无法取消容器的内存和交换空间限制，请检查Docker是否正确安装。"
    exit 1
  fi
done

echo "所有容器的内存和交换空间限制已成功取消。"
