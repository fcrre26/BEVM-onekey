#!/bin/bash

# 从文件中获取节点名称
node_name=$(cat /root/node_name.txt)

# 定义进程名称
process_name="bevm-v0.1.1-ubuntu20.04"

# 检查服务文件是否已经存在
if [ ! -f "/etc/systemd/system/$process_name.service" ]; then
    # 创建systemd服务文件
    cat <<EOT >> /etc/systemd/system/$process_name.service
[Unit]
Description=BEVM Process
After=network.target

[Service]
User=root
WorkingDirectory=/root
ExecStart=/root/bevm-v0.1.1-ubuntu20.04 --chain=testnet ... ... ... --name="$node_name" --pruning=archive --telemetry-url "wss://telemetry.bevm.io/submit ... ... ... 0"
Restart=always
StandardOutput=file:/root/bevm.out.log
StandardError=file:/root/bevm.err.log

[Install]
WantedBy=multi-user.target
EOT
fi

while true
do
    # 检查进程是否在运行
    if pgrep -x "$process_name" > /dev/null
    then
        echo "进程 $process_name 已经在运行，无需启动新的进程。"
    else
        # 检查服务是否已经启动
        if sudo systemctl is-active --quiet $process_name; then
            echo "进程 $process_name 已经启动，无需重复启动。"
        else
            # 启动服务并设置开机自启
            if sudo systemctl start $process_name
            then
                sudo systemctl enable $process_name
                echo "进程 $process_name 启动成功！"
            else
                echo "进程 $process_name 启动失败！"
                echo "失败详情：" | tee /root/startup_error.log
                sudo journalctl -xe | tee -a /root/startup_error.log
            fi
        fi
    fi
    sleep 60
done
