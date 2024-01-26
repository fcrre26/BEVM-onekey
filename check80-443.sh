#!/bin/bash

# 检查端口443
echo "Checking port 443..."
sudo netstat -tuln | grep 443

# 尝试释放端口443
echo "Releasing port 443 if it's in use..."
sudo fuser -k 443/tcp

# 检查端口80
echo "Checking port 80..."
sudo netstat -tuln | grep 80

# 尝试释放端口80
echo "Releasing port 80 if it's in use..."
sudo fuser -k 80/tcp

echo "Port check and release complete."
