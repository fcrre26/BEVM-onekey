#!/bin/bash

# 从文件中获取节点名称
node_name=$(cat /root/node_name.txt)

# 安装supervisord
sudo apt-get update
sudo apt-get install supervisor

# 创建supervisord配置文件
cat <<EOT >> /etc/supervisor/conf.d/process_monitor.conf
[program:bevm]
command=/root/bevm-v0.1.1-ubuntu20.04 --chain=testnet --name="$node_name" --pruning=archive --telemetry-url "wss://telemetry.bevm.io/submit 0"
autostart=true
autorestart=true
stderr_logfile=/root/bevm.err.log
stdout_logfile=/root/bevm.out.log
EOT

# 重新加载supervisord配置
sudo supervisorctl reread
sudo supervisorctl update

# 设置supervisord开机自启
sudo ln -s /etc/supervisor/supervisord.conf /etc/init.d/supervisord
sudo systemctl enable supervisord
