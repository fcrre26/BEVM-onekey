#!/bin/bash

# 从文件中获取节点名称
node_name=$(cat /root/node_name.txt)

# 定义进程名称
process_name="bevm-v0.1.1-ubuntu20.04"

# 定义日志文件路径
log_file="/root/process_monitor.log"

# 监控进程并自动重启
while true; do
  if pgrep -x "$process_name" > /dev/null
  then
    echo "$(date): $process_name is running" >> $log_file
  else
    echo "$(date): $process_name is not running, restarting..." >> $log_file
    nohup /root/bevm-v0.1.1-ubuntu20.04 --chain=testnet --name="$node_name" --pruning=archive --telemetry-url "wss://telemetry.bevm.io/submit 0" >> $log_file 2>&1 &
  fi
  sleep 60  # 每隔60秒检查一次进程状态
done
