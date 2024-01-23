#!/bin/bash

# 定义日志文件路径
LOG_FILE="/root/docker_status.log"

# 定义容器状态检查间隔
CHECK_INTERVAL="1m"

# 检查容器状态并记录日志函数
check_container_status() {
  container_status=$(docker ps --format "{{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}" 2>/dev/null)
  if [ -z "$container_status" ]; then
    echo "$(date) - No running containers found" >> "$LOG_FILE"
  else
    echo "$(date) - Running containers: $container_status" >> "$LOG_FILE"
    exit 0
  fi
}

# 启动停止的容器并记录日志函数
start_stopped_containers() {
  all_containers=$(docker ps -a --format "{{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}" 2>/dev/null)
  echo "$(date) - All containers: $all_containers" >> "$LOG_FILE"
  stopped_containers=$(docker ps -a --format "{{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}" --filter "status=exited" 2>/dev/null)
  if [ -n "$stopped_containers" ]; then
    echo "$(date) - Starting stopped containers: $stopped_containers" >> "$LOG_FILE"
    start_result=$(docker start $stopped_containers 2>&1)
    echo "$(date) - Start result: $start_result" >> "$LOG_FILE"
  fi
}

# 检查容器状态
check_container_status

# 启动停止的容器
start_stopped_containers

# 创建systemd服务文件
cat <<EOF > /etc/systemd/system/docker_monitor.service
[Unit]
Description=Docker Monitor Service
After=docker.service

[Service]
Type=simple
ExecStart=/root/docker_monitor.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# 启用并启动服务
systemctl enable docker_monitor.service
systemctl start docker_monitor.service

# 打印提示信息
echo "docker守护已经成功开启，可以随时查看日志！"
