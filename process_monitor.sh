#!/bin/bash

# 从文件中获取节点名称
node_name=$(cat /root/node_name.txt)

# 定义进程名称
process_name="bevm-v0.1.1-ubuntu20.04"

# 创建systemd服务文件
cat <<EOT >> /etc/systemd/system/$process_name.service
[Unit]
Description=BEVM Process
After=network.target

[Service]
User=root
WorkingDirectory=/root
ExecStart=/root/bevm-v0.1.1-ubuntu20.04 --chain=testnet --name="$node_name" --pruning=archive --telemetry-url "wss://telemetry.bevm.io/submit 0"
Restart=always
StandardOutput=file:/root/bevm.out.log
StandardError=file:/root/bevm.err.log

[Install]
WantedBy=multi-user.target
EOT

# 重新加载systemd配置
sudo systemctl daemon-reload

# 启动服务并设置开机自启
sudo systemctl start $process_name
sudo systemctl enable $process_name

echo "进程守护已经成功开启！"
