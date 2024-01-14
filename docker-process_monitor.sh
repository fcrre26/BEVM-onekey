#!/bin/bash

# 获取所有容器的 ID
containers=$(docker ps -q)

# 遍历每个容器并检查其状态
for container in $containers; do
  if [ "$(docker inspect -f '{{.State.Running}}' $container 2>/dev/null)" = "true" ]; then
    echo "容器 $container 正在运行."
  else
    echo "容器 $container 已停止，正在重新启动..."
    docker start $container
  fi
done

# 添加定时任务到 crontab
(crontab -l ; echo "*/1 * * * * /path/to/your/script.sh") | crontab -
