#!/bin/bash

# 定义进程名称
PROCESS_NAME="bevm-v0.1.1-ubuntu20.04"

# 监控进程并自动重启
while true; do
  if pgrep -x "$PROCESS_NAME" > /dev/null
  then
    echo "$PROCESS_NAME is running"
  else
    echo "$PROCESS_NAME is not running, restarting..."
    nohup /root/bevm-v0.1.1-ubuntu20.04 --chain=testnet --name="woniu4" --pruning=archive &
  fi
  sleep 60  # 每隔60秒检查一次进程状态
done
