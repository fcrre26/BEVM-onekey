#!/bin/bash

# 定义日志文件路径
LOG_FILE="/root/docker_status.log"

# 检查容器状态并记录日志函数
check_container_status() {
  container_status=$(docker ps -q | xargs docker inspect -f '{{.State.Running}}' 2>/dev/null)
  if [ -z "$container_status" ]; then
    echo "$(date) - No running containers found" >> "$LOG_FILE"
  else
    echo "$(date) - Running containers: $container_status" >> "$LOG_FILE"
  fi
}

# 启动停止的容器并记录日志函数
start_stopped_containers() {
  stopped_containers=$(docker ps -a -q --filter "status=exited" 2>/dev/null)
  if [ -n "$stopped_containers" ]; then
    echo "$(date) - Starting stopped containers: $stopped_containers" >> "$LOG_FILE"
    docker start $stopped_containers
  fi
}

# 检查容器状态
check_container_status

# 启动停止的容器
start_stopped_containers

# 将脚本加入systemd服务
# 这里假设脚本名为docker_monitor.sh，你需要根据实际情况修改
cp /path/to/your/docker_monitor.sh /etc/systemd/system/
systemctl enable docker_monitor.sh

# 每分钟自动检查容器状态
# 这里使用while循环，每隔60秒执行一次检查
while true; do
  check_container_status
  start_stopped_containers
  sleep 60
done
