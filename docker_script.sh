#!/bin/bash

# 检索所有的容器
echo "正在检索所有的容器..."
docker ps -a

# 停止所有容器
echo "正在停止所有容器..."
docker stop $(docker ps -aq)

# 限制容器内存=500M，交换空间800M
echo "正在设置容器内存限制..."
docker update --memory=500M --memory-swap=1G $(docker ps -aq)

# 逐个开启所有容器
echo "正在逐个开启所有容器..."
docker start $(docker ps -aq)

# 检查内存限制是否起效
echo "正在检查内存限制是否起效..."
docker stats --no-stream

# 打印结果
echo "所有容器内存限制500M设置成功，并且成功启动！"
