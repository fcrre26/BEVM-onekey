#!/bin/bash

# 检查是否具有root权限
if [[ $EUID -ne 0 ]]; then
   echo "该脚本需要以root权限运行，请使用sudo或者以root用户身份执行。"
   exit 1
fi

# 查找已连接的USB硬盘设备
USB_DEVICES=$(esxcli storage core device list | grep USB | awk '{print $1}')

# 如果没有找到任何USB设备，则退出脚本
if [ -z "$USB_DEVICES" ]; then
  echo "未找到已连接的USB硬盘设备。"
  exit 1
fi

# 创建存储目录（如果不存在）
STORAGE_MOUNT="/vmfs/volumes/usb_storage"
mkdir -p $STORAGE_MOUNT

# 遍历所有USB设备并将其挂载到存储目录
for DEVICE in $USB_DEVICES; do
  # 检查设备是否已经挂载
  MOUNTED=$(esxcli storage filesystem list | grep -i $DEVICE | awk '{print $1}')
  if [ -n "$MOUNTED" ]; then
    echo "设备 $DEVICE 已经挂载到 $MOUNTED"
  else
    # 挂载设备到存储目录
    esxcli storage filesystem mount -d $DEVICE -l $STORAGE_MOUNT
    if [ $? -eq 0 ]; then
      echo "设备 $DEVICE 成功挂载到 $STORAGE_MOUNT"
    else
      echo "无法挂载设备 $DEVICE"
    fi
  fi
done
