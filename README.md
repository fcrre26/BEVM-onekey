一、官方节点教程：

    https://documents.bevm.io/build/run-a-node/archive-node/binary

二、脚本使用：

1、节点搭建命令：

    wget https://raw.githubusercontent.com/fcrre26/BEVM-onekey/main/setup_bevm.sh && chmod +x setup_bevm.sh && ./setup_bevm.sh

2、 docker节点搭建命令：

    wget https://raw.githubusercontent.com/fcrre26/BEVM-onekey/main/docker-setup_bevm.sh && chmod +x docker-setup_bevm.sh && ./docker-setup_bevm.sh


3、进程守护命令：

    wget https://raw.githubusercontent.com/fcrre26/BEVM-onekey/main/process_monitor.sh && chmod +x process_monitor.sh && ./process_monitor.sh


三、VPS的选用：
    官方建议ubuntu20.04;2核2G，硬盘300G。
    实际测试1核心1G勉强能跑，硬盘用不到300G。用1+1配置记得使用进程守护命令，防止资源不够会被kill掉进程。
