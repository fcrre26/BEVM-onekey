一、官方节点教程：https://documents.bevm.io/build/run-a-node/archive-node/binary

二、脚本使用：

1、节点搭建命令：wget https://raw.githubusercontent.com/fcrre26/BEVM-onekey/main/setup_bevm.sh && chmod +x setup_bevm.sh && ./setup_bevm.sh


2、进程守护命令：wget https://raw.githubusercontent.com/fcrre26/BEVM-onekey/main/process_monitor.sh && chmod +x process_monitor.sh && ./process_monitor.sh


三、VPS的选用：
    官方建议  ubuntu20.04;2核2G，硬盘300G
    
    实际测试，1核心1G勉强能跑，硬盘用不到这么大，用1+1跑的时候，记得使用进程守护命令，不然有时候资源不够会被kill掉进程。
