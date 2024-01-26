#!/bin/bash

# 检查系统类型
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
elif type lsb_release >/dev/null 2>&1; then
    OS=$(lsb_release -si)
else
    OS=$(uname -s)
fi

# 根据系统类型执行不同的命令
case $OS in
    "Ubuntu")
        echo "Detected Ubuntu"
        # Ubuntu的命令
        sudo netstat -tuln | grep 443
        sudo fuser -k 443/tcp
        sudo netstat -tuln | grep 80
        sudo fuser -k 80/tcp
        ;;
    "CentOS Linux")
        echo "Detected CentOS"
        # CentOS的命令
        sudo netstat -tuln | grep 443
        sudo fuser -k 443/tcp
        sudo netstat -tuln | grep 80
        sudo fuser -k 80/tcp
        ;;
    "Debian GNU/Linux")
        echo "Detected Debian"
        # Debian的命令
        sudo netstat -tuln | grep 443
        sudo fuser -k 443/tcp
        sudo netstat -tuln | grep 80
        sudo fuser -k 80/tcp
        ;;
    *)
        echo "Unsupported OS"
        ;;
esac
