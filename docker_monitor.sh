#!/bin/bash

# 定义日志文件路径
LOG_FILE="/root/docker_status.log"

# 打印提示信息
echo "docker守护已经成功开启，可以随时查看日志！"

# 检查容器状态并记录日志函数
check_container_status() {
  echo "$(date) - Current container status:" >> "$LOG_FILE"
  docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}" >> "$LOG_FILE"
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

# 每分钟自动检查容器状态
# 这里使用while循环，每隔60秒执行一次检查
while true; do
  check_container_status
  start_stopped_containers
  sleep 60
done
